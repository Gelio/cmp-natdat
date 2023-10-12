local M = {}
local Result = require("tluser")
local pcombinator = require("pcomb.combinator")

---Invokes `parsers` one-by-one and collects all results.
---
---@param parsers pcomb.Parser<unknown>[]
---@return pcomb.Parser<unknown[]>
function M.sequence(parsers)
	return function(input)
		---@type unknown[]
		local results = {}

		for _, parser in ipairs(parsers) do
			local result = parser(input)
			if result:is_ok() then
				---@type pcomb.Result<unknown>
				local pcomb_res = result.value
				input = pcomb_res.input
				table.insert(results, pcomb_res.output)
			else
				return Result.err({ message = "Could not match a sequence of parsers", cause = result.error })
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

---Invokes the `first` and `second` parsers, but discards the result of the
---`first` parser.
---
---@generic Output
---@param first pcomb.Parser<unknown>
---@param second pcomb.Parser<Output>
---@return pcomb.Parser<Output>
function M.preceded(first, second)
	return pcombinator.map(M.sequence({ first, second }), function(results)
		return results[2]
	end)
end

---Invokes the `first` and `second` parsers, but discards the result of the
---`second` parser.
---
---@generic Output
---@param first pcomb.Parser<Output>
---@param second pcomb.Parser<unknown>
---@return pcomb.Parser<Output>
function M.terminated(first, second)
	return pcombinator.map(M.sequence({ first, second }), function(results)
		return results[1]
	end)
end

---Invokes the `first`, `second`, and `third` parsers, but only keeps the
---result of the `second` parser.
---
---@generic Output
---@param first pcomb.Parser<unknown>
---@param second pcomb.Parser<Output>
---@param third pcomb.Parser<Output>
---@return pcomb.Parser<Output>
function M.delimited(first, second, third)
	return M.preceded(first, M.terminated(second, third))
end

return M
