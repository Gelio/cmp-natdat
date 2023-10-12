local M = {}

local natdat_datelike = require("natdat.datelike")
local natdat_now = require("natdat.now")
local natdat_time = require("natdat.time")

local pcombinator = require("pcomb.combinator")

local Result = require("tluser")

local parsers = {
	natdat_datelike.starting_with_month,
	natdat_datelike.day_of_week_and_opt_time,
	natdat_datelike.relative_day_and_opt_time,

	-- NOTE: convert individual outputs to arrays for a uniform parser interface

	pcombinator.map(
		natdat_now.now,
		---@param now natdat.Now
		function(now)
			return { now }
		end
	),
	pcombinator.map(
		natdat_time.time,
		---@param time natdat.Time
		function(time)
			return { time }
		end
	),
}

---@alias natdat.Item
--- | natdat.Month
--- | natdat.DatelikeAndTime
--- | natdat.AbsoluteDate
--- | natdat.DayOfWeek
--- | natdat.RelativeDay
--- | natdat.Now
--- | natdat.Time

---@generic T
---@param list T[][]
---@return T[]
local function flatten_single_level(list)
	---@type T[]
	local result = {}

	for _, nested_list in ipairs(list) do
		for _, item in ipairs(nested_list) do
			table.insert(result, item)
		end
	end

	return result
end

---@param text string
---@return natdat.Item[]
function M.parse(text)
	---@type pcomb.Input
	local input = {
		text = text,
		offset = 1,
	}

	---@type tluser.Result<pcomb.Result<natdat.Item[]>, string>[]
	local results = vim.tbl_map(function(parser)
		return parser(input)
	end, parsers)

	-- NOTE: errors are discarded

	--- @type pcomb.Result<natdat.Item[]>[], unknown
	local successfully_parsed, _ = Result.partition_list(results)

	-- NOTE: cannot use vim.tbl_flatten, because it flattens recursively,
	-- and we only need to flatten a single level.
	return flatten_single_level(vim.tbl_map(
		---@param result pcomb.Result<natdat.Item[]>
		function(result)
			return result.output
		end,
		successfully_parsed
	))
end

return M
