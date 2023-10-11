local M = {}
local Result = require("tluser")

---Tries `parsers` one-by-one until one of them succeeds.
---If not, returns an error.
---
---@generic Output
---@param parsers pcomb.Parser<Output>[]
---@return pcomb.Parser<Output>
function M.alt(parsers)
	---@param input pcomb.Input
	return function(input)
		for _, parser in ipairs(parsers) do
			local result = parser(input)
			if result:is_ok() then
				return result
			end
		end

		return Result.err("No parser matched the input")
	end
end

return M
