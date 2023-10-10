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

---@param hour number
---@return number
local function get_pm_hour(hour)
	if hour == 12 then
		return 12
	else
		return hour + 12
	end
end

---@param hour number
---@return number
local function get_am_hour(hour)
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
