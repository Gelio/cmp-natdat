local pcharacter = require("pcomb.character")
local pbranch = require("pcomb.branch")
local Result = require("tluser")

describe("alt", function()
	it("returns the result of the first parser when it matched", function()
		local word = pcharacter.regexp("%a+")
		local parser = pbranch.alt({
			word,
			pcharacter.integer,
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
		local word = pcharacter.regexp("%a+")
		local parser = pbranch.alt({
			word,
			pcharacter.integer,
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
		local word = pcharacter.regexp("%a+")
		local parser = pbranch.alt({
			word,
			pcharacter.integer,
		})
		local text = "[1234]"
		local result = parser({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)
