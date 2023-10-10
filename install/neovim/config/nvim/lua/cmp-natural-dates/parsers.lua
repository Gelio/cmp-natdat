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

---@class natdat.SuggestedMonth
---@field name string
---@field value integer Month number, starting from 1

---@param input string
---@return natdat.SuggestedMonth[]
function M.get_suggested_months(input)
	local lowercase_input = string.lower(input)

	---@type natdat.SuggestedMonth[]
	local suggestions = {}
	for index, month_name in ipairs(months) do
		if vim.startswith(month_name:lower(), lowercase_input) then
			---@type natdat.SuggestedMonth
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

---@class natdat.MatchedMonth
---@field word string
---@field matched_month natdat.SuggestedMonth | nil

M.month_pcomb = pcomb.map_res(
	pcomb_word,
	---@param word string
	function(word)
		local matching_months = M.get_suggested_months(word)

		if #matching_months == 0 then
			return Result.err("No month match " .. word)
		end

		---@type natdat.Match<natdat.MatchedMonth>
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

M.day_of_month_pcomb = pcomb.map(pcomb.integer, function(day_of_month)
	-- NOTE: checking if day_of_month is a valid month day happens in a consuming
	-- parser

	---@type natdat.Match<integer>
	local match = {
		value = day_of_month,
		suggestions = { tostring(day_of_month) },
	}
	return match
end)

M.year_pcomb = pcomb.map(pcomb.integer, function(year)
	---@type natdat.Match<integer>
	local match = {
		value = year,
		suggestions = { tostring(year) },
	}
	return match
end)

---@class natdat.MatchedDate
---@field day_of_month integer?
---@field month integer?
---@field year integer?

M.date_pcomb = pcomb.map_res(
	pcomb.sequence({
		M.month_pcomb,
		pcomb.opt(pcomb.sequence({
			pcomb.preceded(pcomb.multispace0, M.day_of_month_pcomb),
			pcomb.opt(pcomb.preceded(
				pcomb.multispace1,
				pcomb.terminated(
					M.year_pcomb,

					pcomb.peek(pcomb.alt({
						pcomb.end_of_input,
						pcomb.multispace1,
					}))
				)
			)),
		})),
	}),
	function(results)
		---@type natdat.Match<natdat.MatchedMonth>
		local month_result = results[1]

		if pcomb.is_NIL(results[2]) then
			---@type natdat.Match<natdat.MatchedDate?>
			local pcomb_res = {
				value = month_result.value.matched_month and {
					month = month_result.value.matched_month.value,
					day_of_month = nil,
					year = nil,
				},
				suggestions = month_result.suggestions,
			}
			return Result.ok(pcomb_res)
		end

		---@type natdat.Match<integer>
		local day_of_month_result = results[2][1]
		local day_of_month = day_of_month_result.value

		-- TODO: verify if day_of_month is valid within the month

		---@type natdat.Match<integer> | pcomb.NIL
		local year_result = results[2][2]
		if pcomb.is_NIL(year_result) then
			---@type natdat.Match<natdat.MatchedDate>
			local pcomb_res = {
				value = {
					month = month_result.value.matched_month and month_result.value.matched_month.value,
					day_of_month = day_of_month,
					year = nil,
				},
				suggestions = vim.tbl_map(function(month_name)
					return month_name .. " " .. day_of_month
				end, month_result.suggestions),
			}

			return Result.ok(pcomb_res)
		end

		local year = year_result.value

		---@type natdat.Match<natdat.MatchedDate>
		local pcomb_res = {
			value = {
				month = month_result.value.matched_month and month_result.value.matched_month.value,
				day_of_month = day_of_month,
				year = year,
			},
			suggestions = vim.tbl_map(function(month_name)
				return month_name .. " " .. day_of_month_result.value .. " " .. year
			end, month_result.suggestions),
		}

		return Result.ok(pcomb_res)
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

---@class natdat.MatchedTime
---@field hour integer
---@field minutes integer

M.time_pcomb = pcomb.map_res(
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

			---@type natdat.Match<natdat.MatchedTime>
			local match = {
				value = {
					hour = hour_converter(hour_match.value),
					minutes = minutes_match.value,
				},
				suggestions = { hour_match.suggestions[1] .. ":" .. minutes_match.suggestions[1] .. am_pm_match.suggestions[1] },
			}
			return Result.ok(match)
		end

		---@type natdat.Match<natdat.MatchedTime>
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

---@param first_suggestions string[]?
---@param second_suggestions string[]?
---@return string[]
local function concat_suggestions(first_suggestions, second_suggestions)
	if first_suggestions == nil then
		if second_suggestions == nil then
			return {}
		end

		return second_suggestions
	elseif second_suggestions == nil then
		return first_suggestions
	end

	---@type string[]
	local concatenated_suggestions = {}
	for _, first in ipairs(first_suggestions) do
		for _, second in ipairs(second_suggestions) do
			table.insert(concatenated_suggestions, first .. " " .. second)
		end
	end

	return concatenated_suggestions
end

---@class natdat.MatchedDateTime
---@field matched_date natdat.MatchedDate?
---@field matched_time natdat.MatchedTime?

M.date_time_pcomb = pcomb.map(
	pcomb.sequence({
		pcomb.opt(M.date_pcomb),
		pcomb.multispace0,
		pcomb.opt(M.time_pcomb),
	}),
	function(results)
		---@type natdat.Match<natdat.MatchedDate> | pcomb.NIL
		local date_result = results[1]

		---@type natdat.Match<natdat.MatchedTime> | pcomb.NIL
		local time_result = results[3]

		---@type natdat.MatchedDateTime
		local matched_date_time = {
			matched_date = pcomb.is_NIL(date_result) and nil or date_result.value,
			matched_time = pcomb.is_NIL(time_result) and nil or time_result.value,
		}

		---@type natdat.Match<natdat.MatchedDateTime>
		local match = {
			value = matched_date_time,
			suggestions = concat_suggestions(
				pcomb.is_NIL(date_result) and nil or date_result.suggestions,
				pcomb.is_NIL(time_result) and nil or time_result.suggestions
			),
		}
		return match
	end
)

return M
