local M = {}
local natdat_prefix = require("natdat.prefix")
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
