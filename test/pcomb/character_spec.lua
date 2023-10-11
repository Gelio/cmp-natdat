local pcharacter = require("pcomb.character")
local Result = require("tluser")

describe("tag", function()
	it("parses a literal and moves the input along", function()
		local text = "hey! you!"
		local result = pcharacter.tag("hey!")({
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
		local result = pcharacter.tag("you!")({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("regexp", function()
	it("matches a pattern at the beginning of the input", function()
		local text = "hey! hey! you!"
		local result = pcharacter.regexp("%l+! %l")({
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
		local result = pcharacter.regexp("%l+! %l")({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)

	it("returns an error when the match is not at the beginning of the input", function()
		local text = "nope but hey!"
		local result = pcharacter.regexp("%l+!")({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("integer", function()
	it("parses an integer", function()
		local text = "1234.1234 5678"
		local result = pcharacter.integer({
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
		local result = pcharacter.integer({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)
