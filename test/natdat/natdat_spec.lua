local natdat = require("natdat")

local natdat_date = require("natdat.date")
local natdat_datelike = require("natdat.datelike")
local natdat_day_of_week = require("natdat.day_of_week")
local natdat_now = require("natdat.now")
local natdat_relative_day = require("natdat.relative_day")
local natdat_time = require("natdat.time")

describe("parse", function()
	it("matches 'no '", function()
		local result = natdat.parse("no ")

		assert.are.same({
			natdat_date.Month.new(11),
			natdat_now.Now.new(),
		}, result)
	end)

	it("matches 'today 4:22'", function()
		local result = natdat.parse("today 4:22")

		assert.are.same({
			natdat_datelike.DatelikeAndTime.new(
				natdat_relative_day.RelativeDay.new("today"),
				natdat_time.Time24H.new(4, 22)
			),
		}, result)
	end)

	it("matches 'next t'", function()
		local result = natdat.parse("next t")

		assert.are.same({
			natdat_day_of_week.DayOfWeek.new(2, "next"),
			natdat_day_of_week.DayOfWeek.new(4, "next"),
		}, result)
	end)

	it("matches '5pm'", function()
		local result = natdat.parse("5pm")

		assert.are.same({
			natdat_time.TimeAMPM.new(5, nil, "pm"),
		}, result)
	end)
end)
