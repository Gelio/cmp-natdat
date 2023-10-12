local Result = require("tluser")

local natdat_date = require("natdat.date")
local natdat_datelike = require("natdat.datelike")
local natdat_time = require("natdat.time")

describe("starting_with_month", function()
	it("matches 'Oct 10 4p'", function()
		local text = "Oct 10 4p"
		local result = natdat_datelike.starting_with_month({
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
					natdat_datelike.DatelikeAndTime.new(
						natdat_date.AbsoluteDate.new(10, natdat_date.Month.new(10), nil),
						natdat_time.TimeAMPM.new(4, nil, "pm")
					),
				},
			}),
			result
		)
	end)

	it("matches 'Oct 10 2023 14:00'", function()
		local text = "Oct 10 2023 14:00"
		local result = natdat_datelike.starting_with_month({
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
					natdat_datelike.DatelikeAndTime.new(
						natdat_date.AbsoluteDate.new(10, natdat_date.Month.new(10), 2023),
						natdat_time.Time24H.new(14, 0)
					),
				},
			}),
			result
		)
	end)

	it("matches 'Oct'", function()
		local text = "Oct"
		local result = natdat_datelike.starting_with_month({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 4,
				},
				output = {
					natdat_date.Month.new(10),
				},
			}),
			result
		)
	end)

	it("matches 'Oct '", function()
		local text = "Oct "
		local result = natdat_datelike.starting_with_month({
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
					natdat_date.Month.new(10),
				},
			}),
			result
		)
	end)
end)
