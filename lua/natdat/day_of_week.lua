local M = {}

local natdat_prefix = require("natdat.prefix")
local natdat_date = require("natdat.date")

local pcharacter = require("pcomb.character")
local pcombinator = require("pcomb.combinator")
local psequence = require("pcomb.sequence")
local pnil = require("pcomb.nil")

local days_of_week_names = {
	"Monday",
	"Tuesday",
	"Wednesday",
	"Thursday",
	"Friday",
	"Saturday",
	"Sunday",
}

---@type pcomb.Parser<integer[]>
local raw_day_of_week = pcombinator.map_res(pcharacter.alpha1, natdat_prefix.prefix_indices(days_of_week_names))

---@alias natdat.DayOfWeekModifier "next" | "last"

---@type natdat.DayOfWeekModifier[]
local day_of_week_modifiers = {
	"next",
	"last",
}

---@type pcomb.Parser<natdat.DayOfWeekModifier>
local day_of_week_modifier = pcombinator.map(
	pcombinator.map_res(pcharacter.alpha1, natdat_prefix.prefixes(day_of_week_modifiers)),
	function(modifiers)
		assert(
			#modifiers == 1,
			"There is no shared prefix in day_of_week_modifiers. There cannot be more than 1 matching modifiers."
		)

		return modifiers[1]
	end
)

---@class natdat.DayOfWeek
---@field day_of_week integer
---@field modifier natdat.DayOfWeekModifier?
M.DayOfWeek = {}
M.DayOfWeek.__index = M.DayOfWeek

---@param day_of_week integer
---@param modifier natdat.DayOfWeekModifier?
---@return natdat.DayOfWeek
function M.DayOfWeek.new(day_of_week, modifier)
	---@type natdat.DayOfWeek
	local d = {
		day_of_week = day_of_week,
		modifier = modifier,
	}
	return setmetatable(d, M.DayOfWeek)
end

function M.DayOfWeek:format_original()
	local modifier_part = ""
	if self.modifier ~= nil then
		modifier_part = self.modifier .. " "
	end

	return modifier_part .. days_of_week_names[self.day_of_week]
end

---@param current_date_time natdat.CurrentDateTime
local function get_current_weekday(current_date_time)
	---1 is Sunday
	---We need to convert it back to 1 being Monday
	local osdate_weekday = os.date(
		"*t",
		os.time({ year = current_date_time.year, month = current_date_time.month, day = current_date_time.day_of_month })
	).wday

	if osdate_weekday == 1 then
		return #days_of_week_names
	else
		return osdate_weekday - 1
	end
end

---@param current_date_time natdat.CurrentDateTime
function M.DayOfWeek:format_iso(current_date_time)
	local current_weekday = get_current_weekday(current_date_time)

	local days_difference = self.day_of_week - current_weekday
	if self.modifier == "last" then
		days_difference = days_difference - #days_of_week_names
	elseif self.modifier == "next" then
		days_difference = days_difference + #days_of_week_names
	end

	local current_absolute_date = natdat_date.AbsoluteDate.from_current_date_time(current_date_time)
	local target_absolute_date = natdat_date.AbsoluteDate.add_days(current_absolute_date, days_difference)

	return target_absolute_date:format_iso(current_date_time)
end

---@type pcomb.Parser<natdat.DayOfWeek[]>
M.day_of_week = pcombinator.map(
	psequence.sequence({
		pcombinator.opt(psequence.terminated(day_of_week_modifier, pcharacter.multispace1)),
		raw_day_of_week,
	}),
	---@param results { [1]: natdat.DayOfWeekModifier | pcomb.NIL, [2]: integer[] }
	---@return natdat.DayOfWeek[]
	function(results)
		local modifier = pnil.NIL_to_nil(results[1])
		local days_of_week_indices = results[2]

		return vim.tbl_map(function(day_of_week)
			return M.DayOfWeek.new(day_of_week, modifier)
		end, days_of_week_indices)
	end
)

return M
