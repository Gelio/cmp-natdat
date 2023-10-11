local M = {}

local Result = require("tluser")

---Invokes `parser` 0 or more times and collects the results.
---
---@generic Output
---@param parser pcomb.Parser<Output>
---@return pcomb.Parser<Output[]>
function M.many0(parser)
	return function(input)
		---@type unknown[]
		local results = {}

		while true do
			local result = parser(input)
			if result:is_ok() then
				---@type pcomb.Result<unknown>
				local pcomb_res = result.value
				input = pcomb_res.input
				table.insert(results, pcomb_res.output)
			else
				break
			end
		end

		---@type pcomb.Result<unknown[]>
		local pcomb_res = {
			input = input,
			output = results,
		}
		return Result.ok(pcomb_res)
	end
end

---Invokes `parser` 1 or more times and collects the results.
---Returns an error if there are 0 matches.
---
---@generic Output
---@param parser pcomb.Parser<Output>
---@return pcomb.Parser<Output[]>
function M.many1(parser)
	return function(input)
		local result = M.many0(parser)(input)

		if result:is_ok() and #result.value.output == 0 then
			return Result.err("Could not parse anything in many1 parser")
		else
			return result
		end
	end
end

return M
