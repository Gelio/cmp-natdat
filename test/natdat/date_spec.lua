local natdat_date = require("natdat.date")
local Result = require("tluser")

describe("month", function()
	it("matches 'January'", function()
		local text = "January"
		local result = natdat_date.month({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = text:len() + 1,
				},
				output = {
					natdat_date.Month.new(1),
				},
			}),
			result
		)
	end)

	it("matches 'Jan'", function()
		local text = "Jan"
		local result = natdat_date.month({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = text:len() + 1,
				},
				output = {
					natdat_date.Month.new(1),
				},
			}),
			result
		)
	end)

	it("matches 'J and some more'", function()
		local text = "J and some more"
		local result = natdat_date.month({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 2,
				},
				output = {
					natdat_date.Month.new(1),
					natdat_date.Month.new(6),
					natdat_date.Month.new(7),
				},
			}),
			result
		)
	end)

	it("returns an error when no month can be matched", function()
		local text = "and some more"
		local result = natdat_date.month({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)
