local M = {}

local Result = require("tluser")

local natdat_prefix = require("natdat.prefix")
local pbranch = require("pcomb.branch")
local pcharacter = require("pcomb.character")
local pcombinator = require("pcomb.combinator")
local pnil = require("pcomb.nil")
local psequence = require("pcomb.sequence")

---@class natdat.Month
---@field index integer From 1 to 12
M.Month = {}
M.Month.__index = M.Month

---@param month_index integer From 1 to 12
---@return natdat.Month
function M.Month.new(month_index)
	---@type natdat.Month
	local month = {
		index = month_index,
	}
	return setmetatable(month, M.Month)
end

local month_names = {
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

---@type pcomb.Parser<natdat.Month[]>
M.month = pcombinator.map(
	pcombinator.map_res(pcharacter.alpha1, natdat_prefix.prefix_indices(month_names)),
	---@param month_indices integer[]
	---@return natdat.Month[]
	function(month_indices)
		return vim.tbl_map(M.Month.new, month_indices)
	end
)

---@class natdat.AbsoluteDate
---@field day_of_month integer
---@field month natdat.Month
---@field year integer?
M.AbsoluteDate = {}
M.AbsoluteDate.__index = M.AbsoluteDate

---@param day_of_month integer
---@param month natdat.Month
---@param year integer?
---@return natdat.AbsoluteDate
function M.AbsoluteDate.new(day_of_month, month, year)
	---@type natdat.AbsoluteDate
	local absolute_date = {
		day_of_month = day_of_month,
		month = month,
		year = year,
	}
	return setmetatable(absolute_date, M.AbsoluteDate)
end

local end_of_input_or_whitespace = pcombinator.peek(pbranch.alt({
	pcombinator.end_of_input,
	pcharacter.multispace1,
}))

---Parser to run right after parsing the month to see
---if the input is an absolute date.
---@param months natdat.Month[] Months parsed by M.month
---@return pcomb.Parser<natdat.AbsoluteDate[]>
function M.absolute_date(months)
	return pcombinator.map_res(
		psequence.sequence({
			psequence.delimited(
				pcharacter.multispace0,
				-- Day of month
				pcharacter.integer,

				-- Ensure the day of month is not part of time
				-- (e.g. "14" from "14:00")
				end_of_input_or_whitespace
			),
			pcombinator.opt(psequence.delimited(
				pcharacter.multispace1,
				-- Year
				pcharacter.integer,

				-- Ensure the year is not part of time
				-- (e.g. "14" from "14:00")
				end_of_input_or_whitespace
			)),
		}),
		---@param results { [2]: integer, [3]: integer? }
		---@return tluser.Result<natdat.AbsoluteDate[]>
		function(results)
			local day_of_month = results[1]
			local year = pnil.NIL_to_nil(results[2])

			-- TODO: verify if day_of_month is a valid day for these months

			return Result.ok(vim.tbl_map(function(month)
				return M.AbsoluteDate.new(day_of_month, month, year)
			end, months))
		end
	)
end

return M
