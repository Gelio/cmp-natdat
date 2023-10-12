local natdat_prefix = require("natdat.prefix")
local Result = require("tluser")

describe("prefix_indices", function()
	it("returns indices of matching words", function()
		local text = "y"
		local result = natdat_prefix.prefix_indices({ "yesterday", "yes", "something else" })(text)

		assert.are.same(Result.ok({ 1, 2 }), result)
	end)

	it("returns an error if no words match", function()
		local text = "y"
		local result = natdat_prefix.prefix_indices({ "something else", "again" })(text)

		assert.is_true(result:is_err())
	end)
end)

describe("prefixes", function()
	it("returns matching words", function()
		local text = "y"
		local result = natdat_prefix.prefixes({ "yesterday", "yes", "something else" })(text)

		assert.are.same(Result.ok({ "yesterday", "yes" }), result)
	end)

	it("returns an error if no words match", function()
		local text = "y"
		local result = natdat_prefix.prefixes({ "something else", "again" })(text)

		assert.is_true(result:is_err())
	end)
end)
