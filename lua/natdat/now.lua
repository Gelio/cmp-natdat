local M = {}

local natdat_prefix = require("natdat.prefix")
local natdat_date = require("natdat.date")

local pcharacter = require("pcomb.character")
local pcombinator = require("pcomb.combinator")

local now_stringified = "now"

---@class natdat.Now
---@field type "now"
M.Now = {}
M.Now.__index = M.Now

---@return natdat.Now
function M.Now.new()
	---@type natdat.Now
	local now = {
		type = now_stringified,
	}
	return setmetatable(now, M.Now)
end

function M.Now:format_original()
	return now_stringified
end

---@param current_date_time natdat.CurrentDateTime
function M.Now:format_iso(current_date_time)
	return natdat_date.AbsoluteDate.from_current_date_time(current_date_time):format_iso(current_date_time)
end

---@type pcomb.Parser<natdat.Now>
M.now = pcombinator.map(
	pcombinator.map_res(pcharacter.alpha1, natdat_prefix.prefix_indices({ now_stringified })),
	function(matches)
		assert(#matches == 1, "'now' is a single-value parser. There cannot be more than 1 match")

		return M.Now.new()
	end
)

return M
