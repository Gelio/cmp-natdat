local pcomb = require("pcomb")
local Result = require("tluser")

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

describe("preceded", function()
	it("returns the result of the second parser", function()
		local text = " some word"
		local result = pcomb.preceded(pcomb.tag(" "), pcomb.tag("some"))({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 6,
				},
				output = "some",
			}),
			result
		)
	end)
end)

describe("terminated", function()
	it("returns the result of the first parser", function()
		local text = "some "
		local result = pcomb.terminated(pcomb.tag("some"), pcomb.tag(" "))({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 6,
				},
				output = "some",
			}),
			result
		)
	end)
end)
