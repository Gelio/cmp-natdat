local M = {}
local Result = require("cmp-natural-dates.tluser")

---@class pcomb.Input
---@field text string
---@field offset number 1-based index of the next token to parse from text

---@param input pcomb.Input
---@param length number
---@return pcomb.Input
local function advance_input(input, length)
	---@type pcomb.Input
	local next_input = {
		text = input.text,
		offset = input.offset + length,
	}
	return next_input
end

---@alias pcomb.Parser<Output> function(input: pcomb.Input): tluser.Result<pcomb.Result<Output>, string>

---@class pcomb.Result<Output>: { input: pcomb.Input, output: Output }

---@param tag string
---@return pcomb.Parser<string>
function M.tag(tag)
	---@param input pcomb.Input
	---@return tluser.Result
	return function(input)
		local next_part = input.text:sub(input.offset, input.offset + tag:len() - 1)

		if next_part == tag then
			---@type pcomb.Result<string>
			local pcomb_res = {
				input = advance_input(input, tag:len()),
				output = tag,
			}
			return Result.ok(pcomb_res)
		else
			return Result.err("Could not match tag '" .. tag .. "'")
		end
	end
end

---@alias pcomb.NIL {}

---An artificial replacement for `nil` to allow storing `NIL` in tables.
---Useful in `sequence`
---@type pcomb.NIL
M.NIL = {
	"pcomb.NIL",
}

function M.is_NIL(value)
	return type(value) == "table" and value[1] == "pcomb.NIL"
end

---@generic Output
---@param parser pcomb.Parser<Output>
---@param default_value Output
---@return pcomb.Parser<Output>
function M.opt_with_default(parser, default_value)
	return function(input)
		local result = parser(input)
		if result:is_err() then
			---@type pcomb.Result<pcomb.NIL>
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

---@generic Output
---@param parser pcomb.Parser<Output>
---@return pcomb.Parser<Output | pcomb.NIL>
function M.opt(parser)
	return M.opt_with_default(parser, M.NIL)
end

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

---@param pattern string
---@return pcomb.Parser<string>
function M.regexp(pattern)
	---@param input pcomb.Input
	return function(input)
		local from_index, to_index = string.find(input.text, pattern, input.offset)
		if from_index ~= nil then
			if from_index == input.offset then
				local matched_text = input.text:sub(from_index, to_index)

				---@type pcomb.Result<string>
				local pcomb_res = {
					input = {
						text = input.text,
						offset = to_index + 1,
					},
					output = matched_text,
				}
				return Result.ok(pcomb_res)
			else
				return Result.err("Pattern " .. pattern .. " found later, but not at the beginning of input text")
			end
		else
			return Result.err("Could not find pattern " .. pattern)
		end
	end
end

M.digit = M.regexp("%d")

---@generic InnerOutput
---@generic MapperOutput
---@param parser pcomb.Parser<InnerOutput>
---@param mapper function(innerOutput: InnerOutput): tluser.Result<MapperOutput, any>
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

M.integer = M.map_res(
	-- TODO: try using regexp instead
	M.many1(M.digit),
	function(digits)
		local integer_str = table.concat(digits, "")
		local integer = tonumber(integer_str)
		if type(integer) == "nil" then
			-- NOTE: this is very unlikely, since we only parsed digits
			return Result.err("Could not parse digits " .. integer)
		else
			return Result.ok(integer)
		end
	end
)

---@generic InnerOutput
---@generic MapperOutput
---@param parser pcomb.Parser<InnerOutput>
---@param mapper function(innerOutput: InnerOutput): MapperOutput
---@return pcomb.Parser<MapperOutput>
function M.map(parser, mapper)
	return M.map_res(parser, function(value)
		return Result.ok(mapper(value))
	end)
end

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
				return Result.err("Could not match a sequence of parsers")
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

return M
