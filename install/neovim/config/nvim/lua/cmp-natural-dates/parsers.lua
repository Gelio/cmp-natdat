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

local pcomb_word = pcomb.regexp("%a+")

M.month_pcomb = pcomb.map_res(
	pcomb_word,
	---@param word string
	function(word)
		local matching_months = M.get_suggested_months(word)

		if #matching_months == 0 then
			return Result.err("No month match " .. word)
		end

		---@type natdat.Match<{ word: string, matched_month: SuggestedMonth | nil }>
		local match = {
			value = {
				word = word,
				matched_month = #matching_months == 1 and matching_months[1] or nil,
			},
			suggestions = vim.tbl_map(function(suggested_month)
				return suggested_month.name
			end, matching_months),
		}
		return Result.ok(match)
	end
)

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
		pcomb.opt(M.am_pm_pcomb),
	}),
	function(sequence_match)
		---@type natdat.Match<integer>
		local hour_match = sequence_match[1]
		---@type natdat.Match<integer>
		local minutes_match = sequence_match[2]
		---@type natdat.Match<"am" | "pm"> | pcomb.NIL
		local am_pm_match = sequence_match[4]

		if not pcomb.is_NIL(am_pm_match) then
			if hour_match.value > 12 then
				return Result.err("Hour must be less than or equal 12 when using am/pm")
			end

			local hour_converter = am_pm_match.value:sub(1, 1) == "a" and to_am_hour or to_pm_hour

			---@type natdat.Match<{ hour: integer; minutes: integer; }>
			local match = {
				value = {
					hour = hour_converter(hour_match.value),
					minutes = minutes_match.value,
				},
				suggestions = { hour_match.suggestions[1] .. ":" .. minutes_match.suggestions[1] .. am_pm_match.suggestions[1] },
			}
			return Result.ok(match)
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

return M
