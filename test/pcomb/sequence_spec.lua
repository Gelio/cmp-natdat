local pcharacter = require("pcomb.character")
local pcombinator = require("pcomb.combinator")
local psequence = require("pcomb.sequence")
local pnil = require("pcomb.nil")

local Result = require("tluser")

describe("sequence", function()
	it("returns the results of all parsers", function()
		local parser = psequence.sequence({
			pcharacter.alpha1,
			pcharacter.tag(" "),
			pcharacter.alpha1,
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
		local parser = psequence.sequence({
			pcharacter.alpha1,
			pcombinator.opt(pcharacter.tag(" ")),
			pcharacter.tag("-"),
			pcharacter.alpha1,
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
				output = { "hello", pnil.NIL, "-", "world" },
			}),
			result
		)
	end)

	it("returns an error when some parser failed to match input", function()
		local parser = psequence.sequence({
			pcharacter.alpha1,
			pcombinator.opt(pcharacter.tag(" ")),
			pcharacter.alpha1,
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
		local result = psequence.preceded(pcharacter.tag(" "), pcharacter.tag("some"))({
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
		local result = psequence.terminated(pcharacter.tag("some"), pcharacter.tag(" "))({
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

describe("delimited", function()
	it("returns the result of the second parser", function()
		local text = " some "
		local result = psequence.delimited(pcharacter.tag(" "), pcharacter.tag("some"), pcharacter.tag(" "))({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = text:len() + 1,
				},
				output = "some",
			}),
			result
		)
	end)
end)
