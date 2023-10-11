local pcomb = require("pcomb")
local Result = require("tluser")

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
