local pcomb = require("pcomb")
local Result = require("tluser")

describe("opt", function()
	it("returns the parsed value unchanged when successful", function()
		local parser = pcomb.opt(pcomb.tag("hey!"))
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
		local parser = pcomb.opt(pcomb.tag("you!"))
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
				output = pcomb.NIL,
			}),
			result
		)
	end)
end)

describe("map_res", function()
	it("returns the mapper result when it returned an ok", function()
		local parser = pcomb.map_res(pcomb.many1(pcomb.digit), function(digits)
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
		local parser = pcomb.map_res(pcomb.many1(pcomb.digit), function(digits)
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
		local parser = pcomb.map_res(pcomb.many1(pcomb.digit), function()
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
		local parser = pcomb.map(pcomb.many1(pcomb.digit), function(digits)
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
		local parser = pcomb.map(pcomb.many1(pcomb.digit), function()
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
		local parser = pcomb.peek(pcomb.tag("hey"))
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
		local parser = pcomb.peek(pcomb.tag("hey"))
		local text = "nope"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("flat_map", function()
	local am_pm_parser = pcomb.flat_map(
		pcomb.peek(pcomb.alt({
			pcomb.tag("a"),
			pcomb.tag("p"),
		})),
		function(letter)
			assert(letter == "a" or letter == "p", "Unexpected letter " .. letter .. ". It should be 'a' or 'p'")

			return pcomb.sequence({
				pcomb.tag(letter),
				pcomb.opt(pcomb.tag("m")),
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
		local result = pcomb.end_of_input({
			text = "hello",
			offset = 6,
		})

		assert.is_true(result:is_ok())
	end)

	it("returns an error if end of input is not reached", function()
		local result = pcomb.end_of_input({
			text = "hello",
			offset = 2,
		})

		assert.is_true(result:is_err())
	end)
end)
