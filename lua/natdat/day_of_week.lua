local M = {}
local natdat_prefix = require("natdat.prefix")
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
