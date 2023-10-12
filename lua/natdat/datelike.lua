local M = {}

local natdat_date = require("natdat.date")
local natdat_day_of_week = require("natdat.day_of_week")
local natdat_time = require("natdat.time")

local pcharacter = require("pcomb.character")
local pcombinator = require("pcomb.combinator")
local pnil = require("pcomb.nil")
local psequence = require("pcomb.sequence")

---@alias natdat.Datelike
--- | natdat.AbsoluteDate
--- | natdat.DayOfWeek
--- | natdat.RelativeDay

---@class natdat.DatelikeAndTime
---@field datelike natdat.Datelike
---@field time natdat.Time
M.DatelikeAndTime = {}
M.DatelikeAndTime.__index = M.DatelikeAndTime

---@param datelike natdat.Datelike
---@param time natdat.Time
function M.DatelikeAndTime.new(datelike, time)
	---@type natdat.DatelikeAndTime
	local datelike_and_time = {
		datelike = datelike,
		time = time,
	}
	return setmetatable(datelike_and_time, M.DatelikeAndTime)
end

---Month -> (AbsoluteDate + Time?)
---@type pcomb.Parser<natdat.Month[] | natdat.AbsoluteDate[] | natdat.DatelikeAndTime[]>
M.starting_with_month = pcombinator.flat_map(
	natdat_date.month,
	---@param months natdat.Month[]
	function(months)
		return pcombinator.map(
			pcombinator.opt(psequence.sequence({
				natdat_date.absolute_date(months),
				pcombinator.opt(psequence.preceded(pcharacter.multispace1, natdat_time.time)),
			})),
			---@param results pcomb.NIL | { [1]: natdat.AbsoluteDate[], [2]: pcomb.NIL | natdat.Time }
			---@return natdat.Month[] | natdat.AbsoluteDate[] | natdat.DatelikeAndTime[]
			function(results)
				if pnil.is_NIL(results) then
					return months
				end

				local absolute_dates = results[1]
				local time = results[2]

				if pnil.is_NIL(time) then
					return absolute_dates
				end

				return vim.tbl_map(function(absolute_date)
					return M.DatelikeAndTime.new(absolute_date, time)
				end, absolute_dates)
			end
		)
	end
)

--- DayOfWeek + Time?
---@type pcomb.Parser<natdat.DayOfWeek[] | natdat.DatelikeAndTime[]>
M.day_of_week_and_time = pcombinator.map(
	psequence.sequence({
		natdat_day_of_week.day_of_week,
		pcombinator.opt(psequence.preceded(pcharacter.multispace0, natdat_time.time)),
	}),
	---@param results { [1]: natdat.DayOfWeek[], [2]: pcomb.NIL | natdat.Time }
	---@return natdat.DayOfWeek[] | natdat.DatelikeAndTime[]
	function(results)
		local days_of_week = results[1]
		local time = results[2]

		if pnil.is_NIL(time) then
			return days_of_week
		end

		return vim.tbl_map(
			---@param day_of_week natdat.DayOfWeek
			---@return natdat.DatelikeAndTime
			function(day_of_week)
				return M.DatelikeAndTime.new(day_of_week, time)
			end,
			days_of_week
		)
	end
)

return M
