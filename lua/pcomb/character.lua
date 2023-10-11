local M = {}

local Result = require("tluser")
local combinator = require("pcomb.combinator")

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

---Parses the string `tag`
---@param tag string
---@return pcomb.Parser<string>
function M.tag(tag)
	---@param input pcomb.Input
	---@return tluser.Result<pcomb.Result<string>, string>
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

---Matches using a regexp.
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

---Parses a single digit
M.digit = M.regexp("%d")

---Parses 1 or more digits
M.digit1 = M.regexp("%d+")

---Parses 1 or more digits and converts that to an `integer`.
M.integer = combinator.map_res(
	M.digit1,
	---@param integer_str string
	function(integer_str)
		local integer = tonumber(integer_str)
		if type(integer) == "nil" then
			-- NOTE: this is very unlikely, since we only parsed digits
			return Result.err("Could not parse digits " .. integer)
		else
			return Result.ok(integer)
		end
	end
)

---Parses 0 or more whitespace characters
M.multispace0 = M.regexp("%s*")

---Parses 1 or more whitespace characters
M.multispace1 = M.regexp("%s+")

---Parses 1 or more letters
M.alpha1 = M.regexp("%a+")

return M
