local M = {}
local natdat_prefix = require("natdat.prefix")
local pcharacter = require("pcomb.character")
local pcombinator = require("pcomb.combinator")

---@class natdat.Now
---@field type "now"
M.Now = {}
M.Now.__index = M.Now

---@return natdat.Now
function M.Now.new()
	---@type natdat.Now
	local now = {
		type = "now",
	}
	return setmetatable(now, M.Now)
end

---@type pcomb.Parser<natdat.Now>
M.now = pcombinator.map(
	pcombinator.map_res(pcharacter.alpha1, natdat_prefix.prefix_indices({ "now" })),
	function(matches)
		assert(#matches == 1, "'now' is a single-value parser. There cannot be more than 1 match")

		return M.Now.new()
	end
)

return M
