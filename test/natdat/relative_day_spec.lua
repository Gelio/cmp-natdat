local natdat_relative_day = require("natdat.relative_day")
local Result = require("tluser")

describe("relative_day_pcomb", function()
	it("matches 'yesterday'", function()
		local text = "yesterday"
		local result = natdat_relative_day.relative_day({
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
					natdat_relative_day.RelativeDay.new("yesterday"),
				},
			}),
			result
		)
	end)

	it("matches 'to '", function()
		local text = "to "
		local result = natdat_relative_day.relative_day({
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
					natdat_relative_day.RelativeDay.new("today"),
					natdat_relative_day.RelativeDay.new("tomorrow"),
				},
			}),
			result
		)
	end)
end)
