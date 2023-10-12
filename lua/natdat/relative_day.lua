local M = {}

local natdat_prefix = require("natdat.prefix")
local natdat_date = require("natdat.date")

local pcharacter = require("pcomb.character")
local pcombinator = require("pcomb.combinator")

---@alias natdat.RelativeDayVariant "today" | "yesterday" | "tomorrow"

---@class natdat.RelativeDay
---@field variant natdat.RelativeDayVariant
M.RelativeDay = {}
M.RelativeDay.__index = M.RelativeDay

---@param variant natdat.RelativeDayVariant
---@return natdat.RelativeDay
function M.RelativeDay.new(variant)
	---@type natdat.RelativeDay
	local relative_day = {
		variant = variant,
	}
	return setmetatable(relative_day, M.RelativeDay)
end

function M.RelativeDay:format_original()
	return self.variant
end

---@param current_date_time natdat.CurrentDateTime
function M.RelativeDay:format_iso(current_date_time)
	local current_absolute_date = natdat_date.AbsoluteDate.from_current_date_time(current_date_time)

	if self.variant == "today" then
		return current_absolute_date:format_iso(current_date_time)
	end

	local days_to_add = 0
	if self.variant == "yesterday" then
		days_to_add = -1
	elseif self.variant == "tomorrow" then
		days_to_add = 1
	end

	return natdat_date.AbsoluteDate.add_days(current_absolute_date, days_to_add):format_iso(current_date_time)
end

---@type natdat.RelativeDayVariant[]
local relative_day_variants = {
	"yesterday",
	"today",
	"tomorrow",
}

---@type pcomb.Parser<natdat.RelativeDay[]>
M.relative_day = pcombinator.map(
	pcombinator.map_res(pcharacter.alpha1, natdat_prefix.prefixes(relative_day_variants)),
	---@param matched_relative_day_variants natdat.RelativeDayVariant[]
	---@return natdat.RelativeDay[]
	function(matched_relative_day_variants)
		return vim.tbl_map(M.RelativeDay.new, matched_relative_day_variants)
	end
)

return M
