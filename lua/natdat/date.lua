local M = {}

local natdat_prefix = require("natdat.prefix")
local pcharacter = require("pcomb.character")
local pcombinator = require("pcomb.combinator")

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

M.month = pcombinator.map(
	pcombinator.map_res(pcharacter.alpha1, natdat_prefix.prefix_indices(month_names)),
	---@param month_indices integer[]
	---@return natdat.Month[]
	function(month_indices)
		return vim.tbl_map(M.Month.new, month_indices)
	end
)

return M
