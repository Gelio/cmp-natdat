local Result = require("tluser")

local natdat_date = require("natdat.date")
local natdat_datelike = require("natdat.datelike")
local natdat_day_of_week = require("natdat.day_of_week")
local natdat_relative_day = require("natdat.relative_day")
local natdat_time = require("natdat.time")

describe("DatelikeAndTime", function()
	describe("format_original", function()
		it("formats relative day and time", function()
			assert.are.equal(
				"tomorrow 2pm",
				natdat_datelike.DatelikeAndTime
					.new(natdat_relative_day.RelativeDay.new("tomorrow"), natdat_time.TimeAMPM.new(2, nil, "pm"))
					:format_original()
			)
		end)

		it("formats absolute date and time", function()
			assert.are.equal(
				"October 10 2pm",
				natdat_datelike.DatelikeAndTime
					.new(
						natdat_date.AbsoluteDate.new(10, natdat_date.Month.new(10), nil),
						natdat_time.TimeAMPM.new(2, nil, "pm")
					)
					:format_original()
			)
		end)

		it("formats day of week and time", function()
			assert.are.equal(
				"last Monday 14:02",
				natdat_datelike.DatelikeAndTime
					.new(natdat_day_of_week.DayOfWeek.new(1, "last"), natdat_time.Time24H.new(14, 2))
					:format_original()
			)
		end)
	end)
end)

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

describe("day_of_week_and_opt_time", function()
	it("matches 'last mon 2pm'", function()
		local text = "las mon 2pm"
		local result = natdat_datelike.day_of_week_and_opt_time({
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
						natdat_day_of_week.DayOfWeek.new(1, "last"),
						natdat_time.TimeAMPM.new(2, nil, "pm")
					),
				},
			}),
			result
		)
	end)

	it("matches 'th'", function()
		local text = "th"
		local result = natdat_datelike.day_of_week_and_opt_time({
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

describe("relative_day_and_opt_time", function()
	it("matches 'to 2pm'", function()
		local text = "to 2pm"
		local result = natdat_datelike.relative_day_and_opt_time({
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
						natdat_relative_day.RelativeDay.new("today"),
						natdat_time.TimeAMPM.new(2, nil, "pm")
					),
					natdat_datelike.DatelikeAndTime.new(
						natdat_relative_day.RelativeDay.new("tomorrow"),
						natdat_time.TimeAMPM.new(2, nil, "pm")
					),
				},
			}),
			result
		)
	end)

	it("matches 'toda'", function()
		local text = "toda"
		local result = natdat_datelike.relative_day_and_opt_time({
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
					natdat_relative_day.RelativeDay.new("today"),
				},
			}),
			result
		)
	end)
end)
