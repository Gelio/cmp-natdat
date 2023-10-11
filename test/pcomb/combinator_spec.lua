local pcombinator = require("pcomb.combinator")
local pcharacter = require("pcomb.character")
local pmulti = require("pcomb.multi")
local pbranch = require("pcomb.branch")
local psequence = require("pcomb.sequence")
local pnil = require("pcomb.nil")

local Result = require("tluser")

describe("opt", function()
	it("returns the parsed value unchanged when successful", function()
		local parser = pcombinator.opt(pcharacter.tag("hey!"))
		local text = "hey! you!"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 5,
				},
				output = "hey!",
			}),
			result
		)
	end)

	it("returns NIL when the inner parser was not successful", function()
		local parser = pcombinator.opt(pcharacter.tag("you!"))
		local text = "hey! you!"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 1,
				},
				output = pnil.NIL,
			}),
			result
		)
	end)
end)

describe("map_res", function()
	it("returns the mapper result when it returned an ok", function()
		local parser = pcombinator.map_res(pmulti.many1(pcharacter.digit), function(digits)
			local num_digits = #digits
			if num_digits >= 2 then
				return Result.ok(#digits)
			else
				return Result.err("Parsed less than 2 digits")
			end
		end)

		local text = "1111 and some more"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 5,
				},
				output = 4,
			}),
			result
		)
	end)

	it("returns the mapper result when it returned an error", function()
		local parser = pcombinator.map_res(pmulti.many1(pcharacter.digit), function(digits)
			local num_digits = #digits
			if num_digits >= 2 then
				return Result.ok(#digits)
			else
				return Result.err("Parsed less than 2 digits")
			end
		end)

		local text = "1 and some more"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)

	it("does not call the mapper when the parser failed", function()
		local parser = pcombinator.map_res(pmulti.many1(pcharacter.digit), function()
			error("The mapper should not be called")
		end)

		local text = "and some more"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("map", function()
	it("returns the mapper result", function()
		local parser = pcombinator.map(pmulti.many1(pcharacter.digit), function(digits)
			local num_digits = #digits
			return num_digits
		end)

		local text = "1111 and some more"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 5,
				},
				output = 4,
			}),
			result
		)
	end)

	it("does not call the mapper when the parser failed", function()
		local parser = pcombinator.map(pmulti.many1(pcharacter.digit), function()
			error("The mapper should not be called")
		end)

		local text = "and some more"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("peek", function()
	it("parses but does not consume the parsed part in the output", function()
		local parser = pcombinator.peek(pcharacter.tag("hey"))
		local text = "hey you"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 1,
				},
				output = "hey",
			}),
			result
		)
	end)

	it("propagates errors", function()
		local parser = pcombinator.peek(pcharacter.tag("hey"))
		local text = "nope"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("flat_map", function()
	local am_pm_parser = pcombinator.flat_map(
		pcombinator.peek(pbranch.alt({
			pcharacter.tag("a"),
			pcharacter.tag("p"),
		})),
		function(letter)
			assert(letter == "a" or letter == "p", "Unexpected letter " .. letter .. ". It should be 'a' or 'p'")

			return psequence.sequence({
				pcharacter.tag(letter),
				pcombinator.opt(pcharacter.tag("m")),
			})
		end
	)

	it("gets the next parser based on the output of the first parser", function()
		local text = "am"
		local result = am_pm_parser({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 3,
				},
				output = { "a", "m" },
			}),
			result
		)
	end)

	it("propagates errors", function()
		local text = "hello"
		local result = am_pm_parser({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("end_of_input", function()
	it("matches end of input", function()
		local result = pcombinator.end_of_input({
			text = "hello",
			offset = 6,
		})

		assert.is_true(result:is_ok())
	end)

	it("returns an error if end of input is not reached", function()
		local result = pcombinator.end_of_input({
			text = "hello",
			offset = 2,
		})

		assert.is_true(result:is_err())
	end)
end)
