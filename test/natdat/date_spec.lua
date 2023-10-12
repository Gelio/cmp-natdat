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

describe("absolute_date", function()
	it("matches '10 2023'", function()
		local text = "10 2023"
		local month = natdat_date.Month.new(10)
		local result = natdat_date.absolute_date({ month })({
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
					natdat_date.AbsoluteDate.new(10, month, 2023),
				},
			}),
			result
		)
	end)

	it("matches '10'", function()
		local text = "10"
		local month = natdat_date.Month.new(10)
		local result = natdat_date.absolute_date({ month })({
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
					natdat_date.AbsoluteDate.new(10, month, nil),
				},
			}),
			result
		)
	end)

	it("matches '10 14:' without parsing the '14:' as part of year", function()
		local text = "10 14:"
		local month = natdat_date.Month.new(10)
		local result = natdat_date.absolute_date({ month })({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 3,
				},
				output = {
					natdat_date.AbsoluteDate.new(10, month, nil),
				},
			}),
			result
		)
	end)

	it("matches '10 14p' without parsing the '14p' as part of year", function()
		local text = "10 14p"
		local month = natdat_date.Month.new(10)
		local result = natdat_date.absolute_date({ month })({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 3,
				},
				output = {
					natdat_date.AbsoluteDate.new(10, month, nil),
				},
			}),
			result
		)
	end)

	it("matches '10'", function()
		local text = "10"
		local month = natdat_date.Month.new(10)
		local result = natdat_date.absolute_date({ month })({
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
					natdat_date.AbsoluteDate.new(10, month, nil),
				},
			}),
			result
		)
	end)

	it("does not match '14:'", function()
		local text = "14:"
		local month = natdat_date.Month.new(10)
		local result = natdat_date.absolute_date({ month })({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)
