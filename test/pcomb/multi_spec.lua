local pcharacter = require("pcomb.character")
local pmulti = require("pcomb.multi")
local Result = require("tluser")

describe("many0", function()
	it("aggregates as many matches as possible", function()
		local parser = pmulti.many0(pcharacter.tag("hey"))
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
		local parser = pmulti.many0(pcharacter.tag("hey"))
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
		local parser = pmulti.many1(pcharacter.tag("hey"))
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
		local parser = pmulti.many1(pcharacter.tag("hey"))
		local text = "are you hey or no?"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)
