local natdat_day_of_week = require("natdat.day_of_week")
local Result = require("tluser")

describe("day_of_week", function()
	it("matches 'last thu '", function()
		local text = "last thu "
		local result = natdat_day_of_week.day_of_week({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = text:len(),
				},
				output = {
					natdat_day_of_week.DayOfWeek.new(4, "last"),
				},
			}),
			result
		)
	end)

	it("matches 'next t'", function()
		local text = "next t"
		local result = natdat_day_of_week.day_of_week({
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
					natdat_day_of_week.DayOfWeek.new(2, "next"),
					natdat_day_of_week.DayOfWeek.new(4, "next"),
				},
			}),
			result
		)
	end)
	it("matches 'thursday'", function()
		local text = "thursday"
		local result = natdat_day_of_week.day_of_week({
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
					natdat_day_of_week.DayOfWeek.new(4, nil),
				},
			}),
			result
		)
	end)
end)
