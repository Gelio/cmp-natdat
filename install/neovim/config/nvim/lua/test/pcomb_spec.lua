local pcomb = require("cmp-natural-dates.pcomb")
local Result = require("cmp-natural-dates.tluser")

describe("tag", function()
	it("parses a literal and moves the input along", function()
		local text = "hey! you!"
		local result = pcomb.tag("hey!")({
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

	it("returns an error when the literal cannot be matched", function()
		local text = "hey! you!"
		local result = pcomb.tag("you!")({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

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

describe("many0", function()
	it("aggregates as many matches as possible", function()
		local parser = pcomb.many0(pcomb.tag("hey"))
		local text = "heyheyyouyou"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 7,
				},
				output = { "hey", "hey" },
			}),
			result
		)
	end)

	it("returns an empty array when no matches were found", function()
		local parser = pcomb.many0(pcomb.tag("hey"))
		local text = "are you hey or no?"
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
				output = {},
			}),
			result
		)
	end)
end)

describe("many1", function()
	it("aggregates as many matches as possible", function()
		local parser = pcomb.many1(pcomb.tag("hey"))
		local text = "heyheyyouyou"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 7,
				},
				output = { "hey", "hey" },
			}),
			result
		)
	end)

	it("returns an error when no matches were found", function()
		local parser = pcomb.many1(pcomb.tag("hey"))
		local text = "are you hey or no?"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("regexp", function()
	it("matches a pattern at the beginning of the input", function()
		local text = "hey! hey! you!"
		local result = pcomb.regexp("%l+! %l")({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 7,
				},
				output = "hey! h",
			}),
			result
		)
	end)

	it("returns an error when there is no match", function()
		local text = "nope"
		local result = pcomb.regexp("%l+! %l")({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)

	it("returns an error when the match is not at the beginning of the input", function()
		local text = "nope but hey!"
		local result = pcomb.regexp("%l+!")({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
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

describe("integer", function()
	it("parses an integer", function()
		local text = "1234.1234 5678"
		local result = pcomb.integer({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 5,
				},
				output = 1234,
			}),
			result
		)
	end)

	it("returns an error when there is no integer", function()
		local text = "no int :/ 5678"
		local result = pcomb.integer({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("alt", function()
	it("returns the result of the first parser when it matched", function()
		local word = pcomb.regexp("%a+")
		local parser = pcomb.alt({
			word,
			pcomb.number,
		})
		local text = "hello world"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 6,
				},
				output = "hello",
			}),
			result
		)
	end)

	it("returns the result of the second parser when the first did not match", function()
		local word = pcomb.regexp("%a+")
		local parser = pcomb.alt({
			word,
			pcomb.integer,
		})
		local text = "12345 world"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 6,
				},
				output = 12345,
			}),
			result
		)
	end)

	it("returns an error when no parsers matched input", function()
		local word = pcomb.regexp("%a+")
		local parser = pcomb.alt({
			word,
			pcomb.integer,
		})
		local text = "[1234]"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("sequence", function()
	it("returns the results of all parsers", function()
		local word = pcomb.regexp("%a+")
		local parser = pcomb.sequence({
			word,
			pcomb.tag(" "),
			word,
		})
		local text = "hello world"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 12,
				},
				output = { "hello", " ", "world" },
			}),
			result
		)
	end)

	it("returns the results of all parsers even if some return NIL", function()
		local word = pcomb.regexp("%a+")
		local parser = pcomb.sequence({
			word,
			pcomb.opt(pcomb.tag(" ")),
			pcomb.tag("-"),
			word,
		})
		local text = "hello-world"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 12,
				},
				output = { "hello", pcomb.NIL, "-", "world" },
			}),
			result
		)
	end)

	it("returns an error when some parser failed to match input", function()
		local word = pcomb.regexp("%a+")
		local parser = pcomb.sequence({
			word,
			pcomb.opt(pcomb.tag(" ")),
			word,
		})
		local text = "hello :<"
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
