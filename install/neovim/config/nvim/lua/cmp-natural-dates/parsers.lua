local M = {}

local months = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December",
}

---@class SuggestedMonth
---@field name string
---@field value number Month number, starting from 1

---@param input string
---@return SuggestedMonth[]
function M.get_suggested_months(input)
	local lowercase_input = string.lower(input)

	---@type SuggestedMonth[]
	local suggestions = {}
	for index, month_name in ipairs(months) do
		if vim.startswith(month_name:lower(), lowercase_input) then
			---@type SuggestedMonth
			local month = {
				name = month_name,
				value = index,
			}
			table.insert(suggestions, month)
		end
	end

	return suggestions
end

---@class ParsedTime
---@field hours number
---@field minutes number

---@param input string
---@return ParsedTime?
function M.parse_time(input)
	local lowercase_input = string.lower(input)

	local hours = string.match(lowercase_input, "^(%d+)")
	-- TODO: check if hour is reasonable
	if hours == nil then
		return nil
	end
	-- TODO: verify if parsed_hours are not nil
	local parsed_hours = tonumber(hours, 10)
	local offset = string.len(hours) + 1
	vim.print({ offset = offset, parsed_hours = parsed_hours })

	if lowercase_input:sub(offset, offset) == ":" then
		offset = offset + 1
		local minutes = string.match(lowercase_input, "(%d+)", offset) or "0"
		-- TODO: verify if parsed_minutes are not nil
		local parsed_minutes = tonumber(minutes, 10)
		vim.print({ minutes = minutes })

		-- TODO: parse am/pm at the end
		if minutes ~= nil then
			-- TODO: check if minutes is reasonable

			---@type ParsedTime
			return {
				hours = parsed_hours,
				minutes = parsed_minutes,
			}
		else
			---@type ParsedTime
			return {
				hours = parsed_hours,
				minutes = 0,
			}
		end
	else
		-- NOTE: parse am/pm part
		local nonspace_index = string.find(lowercase_input, "[^%s]", offset)
		if nonspace_index == nil then
			---@type ParsedTime
			return {
				hours = parsed_hours,
				minutes = 0,
			}
		else
			offset = nonspace_index
			if lowercase_input:sub(offset, offset) == "a" then
				-- NOTE: assume am

				-- TODO: handle 12am being 0:00

				---@type ParsedTime
				return {
					hours = parsed_hours,
					minutes = 0,
				}
			elseif lowercase_input:sub(offset, offset) == "p" then
				-- NOTE: assume pm

				-- TODO: handle 12pm being 12:00

				---@type ParsedTime
				return {
					hours = parsed_hours + 12,
					minutes = 0,
				}
			else
				-- NOTE: neither am nor pm. Assume am
				-- TODO: handle 12am being 0:00

				---@type ParsedTime
				return {
					hours = parsed_hours,
					minutes = 0,
				}
			end
		end
	end
end

local pcomb = require("cmp-natural-dates.pcomb")
local Result = require("cmp-natural-dates.tluser")

---@class natdat.Match<T>: { value: T, suggestions: string[] }
local Match = {}

---@param value string
---@return natdat.Match<string>
function Match.from_string(value)
	---@type natdat.Match<string>
	local match = {
		value = value,
		suggestions = { value },
	}
	return match
end

M.hour_pcomb = pcomb.map_res(pcomb.integer, function(integer)
	if integer >= 24 then
		return Result.err("Hour " .. integer .. " is too large")
	end

	---@type natdat.Match<integer>
	local match = {
		value = integer,
		suggestions = { tostring(integer) },
	}
	return Result.ok(match)
end)

M.minutes_pcomb = pcomb.map_res(pcomb.integer, function(integer)
	if integer >= 59 then
		return Result.err("Minutes " .. integer .. " is too large")
	end

	---@type natdat.Match<integer>
	local match = {
		value = integer,
		suggestions = { string.format("%02d", integer) },
	}
	return Result.ok(match)
end)

M.am_pm_pcomb = pcomb.map(
	pcomb.sequence({
		pcomb.alt({ pcomb.tag("a"), pcomb.tag("p") }),
		pcomb.opt(pcomb.tag("m")),
	}),
	---@param letters string[]
	---@return natdat.Match<"am" | "a" | "pm" | "p">
	function(letters)
		local matched_text = letters[1]
		if not pcomb.is_NIL(letters[2]) then
			matched_text = matched_text .. letters[2]
		end

		---@type natdat.Match<"am" | "a" | "pm" | "p">
		local match = {
			value = matched_text,
			suggestions = {
				letters[1] == "a" and "am" or "pm",
			},
		}
		return match
	end
)

-- integer
-- (:integer) (optional)
-- optional whitespace
-- (am|pm) (optional)
M.parse_time_pcomb = pcomb.map_res(
	pcomb.sequence({
		M.hour_pcomb,
		pcomb.opt_with_default(
			pcomb.map(
				pcomb.sequence({
					pcomb.tag(":"),
					M.minutes_pcomb,
				}),
				function(sequence_match)
					---@type natdat.Match<integer>
					local minutes_match = sequence_match[2]
					return minutes_match
				end
			),
			---@type natdat.Match<integer>
			{
				value = 0,
				suggestions = { "00" },
			}
		),
		pcomb.regexp("%s*"),
		pcomb.opt(pcomb.alt({
			-- TODO: improve matching am/pm:
			-- * add suggestions
			-- * match only "a" or "p"
			pcomb.tag("am"),
			pcomb.tag("pm"),
		})),
	}),
	function(sequence_match)
		---@type natdat.Match<integer>
		local hour_match = sequence_match[1]
		---@type natdat.Match<integer>
		local minutes_match = sequence_match[2]
		---@type natdat.Match<"am" | "pm">
		local am_pm_match = sequence_match[4]

		if not pcomb.is_NIL(am_pm_match) then
			-- TODO: adjust hour based on am/pm
		end

		---@type natdat.Match<{ hour: integer; minutes: integer; }>
		local match = {
			value = {
				hour = hour_match.value,
				minutes = minutes_match.value,
			},
			suggestions = { hour_match.suggestions[1] .. ":" .. minutes_match.suggestions[1] },
		}
		return Result.ok(match)
	end
)

---@param hour number
---@return number
local function to_pm_hour(hour)
	if hour == 12 then
		return 12
	else
		return hour + 12
	end
end

---@param hour number
---@return number
local function to_am_hour(hour)
	if hour == 12 then
		return 0
	else
		return hour
	end
end

---@param input_parts string[]
function M.parse_month(input_parts)
	local month_part = input_parts[1]
	local month_suggestions = M.get_suggested_months(month_part)
	if #month_suggestions == 0 then
		return {}
	elseif #month_suggestions == 1 then
		local day_part = input_parts[2]
		local parsed_day = tonumber(day_part, 10)
		if type(parsed_day) == "number" then
			return {
				month = month_suggestions[1],
				day = parsed_day,
			}
		end
	else
		return month_suggestions
	end
end

return M
