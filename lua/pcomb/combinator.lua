local M = {}

local Result = require("tluser")
local pcomb_nil = require("pcomb.nil")

---Invokes the `parser`, and if it fails, returns a `default_value` instead.
---@generic Output
---@param parser pcomb.Parser<Output>
---@param default_value Output
---@return pcomb.Parser<Output>
function M.opt_with_default(parser, default_value)
	---@param input pcomb.Input
	return function(input)
		local result = parser(input)
		if result:is_err() then
			---@type pcomb.Result<Output>
			local pcomb_res = {
				input = input,
				output = default_value,
			}
			return Result.ok(pcomb_res)
		else
			return result
		end
	end
end

---Invokes the `parser`, and if it fails, returns `pcomb.NIL`.
---
---Does not use the regular `nil` to avoid accidentally omitting values
---when inserting the parser result into tables.
---
---@generic Output
---@param parser pcomb.Parser<Output>
---@return pcomb.Parser<Output | pcomb.NIL>
function M.opt(parser)
	return M.opt_with_default(parser, pcomb_nil.NIL)
end

---Invokes the `parser`, and if it was successful, calls
---`mapper` on the result, and propagates its return value.
---
---@generic InnerOutput
---@generic MapperOutput
---@param parser pcomb.Parser<InnerOutput>
---@param mapper fun(innerOutput: InnerOutput): tluser.Result<MapperOutput, any>
---@return pcomb.Parser<MapperOutput>
function M.map_res(parser, mapper)
	return function(input)
		local result = parser(input)
		if result:is_err() then
			return result
		else
			---@type pcomb.Result<InnerOutput>
			local pcomb_res = result.value
			local mapper_result = mapper(pcomb_res.output)
			if mapper_result:is_err() then
				return mapper_result
			end

			---@type pcomb.Result<MapperOutput>
			local new_pcomb_res = {
				input = pcomb_res.input,
				output = mapper_result.value,
			}
			return Result.ok(new_pcomb_res)
		end
	end
end

---Invokes the `parser`, and if it was successful, calls
---`mapper` on the result, and propagates its return value.
---
---@generic InnerOutput
---@generic MapperOutput
---@param parser pcomb.Parser<InnerOutput>
---@param mapper fun(innerOutput: InnerOutput): MapperOutput
---@return pcomb.Parser<MapperOutput>
function M.map(parser, mapper)
	return M.map_res(parser, function(value)
		return Result.ok(mapper(value))
	end)
end

---Invokes the `parser` without consuming the input.
---
---@generic Output
---@param parser pcomb.Parser<Output>
---@return pcomb.Parser<Output>
function M.peek(parser)
	---@param input pcomb.Input
	return function(input)
		local result = parser(input)
		if result:is_err() then
			return result
		end

		---@type pcomb.Result<Output>
		local pcomb_res = {
			-- NOTE: do not consume the peeked part
			input = input,
			output = result.value.output,
		}
		return Result.ok(pcomb_res)
	end
end

---Invokes the `parser`, and passes the result into `get_next_parser` to
---determine the parser to use on the rest of the input.
---
---@generic InnerOutput
---@generic OuterOutput
---@param parser pcomb.Parser<InnerOutput>
---@param get_next_parser fun(inner_output: InnerOutput): pcomb.Parser<OuterOutput>
---@return pcomb.Parser<OuterOutput>
function M.flat_map(parser, get_next_parser)
	---@param input pcomb.Input
	return function(input)
		local inner_result = parser(input)
		if inner_result:is_err() then
			return inner_result
		end

		---@type pcomb.Result<InnerOutput>
		local inner_pcomb_result = inner_result.value

		local next_parser = get_next_parser(inner_pcomb_result.output)
		return next_parser(inner_pcomb_result.input)
	end
end

---Matches the end of input
---
---@param input pcomb.Input
---@return tluser.Result<pcomb.Result<nil>, string>
function M.end_of_input(input)
	if input.offset ~= input.text:len() + 1 then
		return Result.err("End of input is not matched yet")
	end

	---@type pcomb.Result<nil>
	local pcomb_res = {
		input = input,
		output = nil,
	}
	return Result.ok(pcomb_res)
end

return M
