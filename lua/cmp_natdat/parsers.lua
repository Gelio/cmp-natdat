local M = {}

local Result = require("tluser")

local pbranch = require("pcomb.branch")
local pcharacter = require("pcomb.character")
local pcombinator = require("pcomb.combinator")
local psequence = require("pcomb.sequence")
local pnil = require("pcomb.nil")

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

M.day_of_month_pcomb = pcombinator.map(pcharacter.integer, function(day_of_month)
	-- NOTE: checking if day_of_month is a valid month day happens in a consuming
	-- parser

	---@type natdat.Match<integer>
	local match = {
		value = day_of_month,
		suggestions = { tostring(day_of_month) },
	}
	return match
end)

M.year_pcomb = pcombinator.map(pcharacter.integer, function(year)
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

M.date_pcomb = pcombinator.map_res(
	psequence.sequence({
		M.month_pcomb,
		pcombinator.opt(psequence.sequence({
			psequence.preceded(pcharacter.multispace0, M.day_of_month_pcomb),
			pcombinator.opt(
				psequence.preceded(
					pcharacter.multispace1,
					psequence.terminated(
						M.year_pcomb,

						pcombinator.peek(pbranch.alt({
							pcombinator.end_of_input,
							pcharacter.multispace1,
						}))
					)
				)
			),
		})),
	}),
	function(results)
		---@type natdat.Match<natdat.MatchedMonth>
		local month_result = results[1]

		if pnil.is_NIL(results[2]) then
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
		if pnil.is_NIL(year_result) then
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

M.date_time_pcomb = pcombinator.map(
	psequence.sequence({
		pcombinator.opt(M.date_pcomb),
		pcharacter.multispace0,
		pcombinator.opt(M.time_pcomb),
	}),
	function(results)
		---@type natdat.Match<natdat.MatchedDate> | pcomb.NIL
		local date_result = results[1]

		---@type natdat.Match<natdat.MatchedTime> | pcomb.NIL
		local time_result = results[3]

		---@type natdat.MatchedDateTime
		local matched_date_time = {
			matched_date = pnil.is_NIL(date_result) and nil or date_result.value,
			matched_time = pnil.is_NIL(time_result) and nil or time_result.value,
		}

		---@type natdat.Match<natdat.MatchedDateTime>
		local match = {
			value = matched_date_time,
			suggestions = concat_suggestions(
				pnil.is_NIL(date_result) and nil or date_result.suggestions,
				pnil.is_NIL(time_result) and nil or time_result.suggestions
			),
		}
		return match
	end
)

---@generic A
---@generic B
---@generic Output
---@param as A[]
---@param bs B[]
---@param f function(a: A, b: B): Output
---@return Output[]
local function cartesian_product(as, bs, f)
	---@type Output[]
	local outputs = {}

	for _, a in ipairs(as) do
		for _, b in ipairs(bs) do
			table.insert(outputs, f(a, b))
		end
	end

	return outputs
end

return M
