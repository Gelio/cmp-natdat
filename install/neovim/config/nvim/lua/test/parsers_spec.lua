local parsers = require("cmp-natural-dates.parsers")

describe("get_suggested_months", function()
	it("returns all months for an empty input", function()
		assert.are.same(parsers.get_suggested_months(""), {
			{
				name = "January",
				value = 1,
			},
			{
				name = "February",
				value = 2,
			},
			{
				name = "March",
				value = 3,
			},
			{
				name = "April",
				value = 4,
			},
			{
				name = "May",
				value = 5,
			},
			{
				name = "June",
				value = 6,
			},
			{
				name = "July",
				value = 7,
			},
			{
				name = "August",
				value = 8,
			},
			{
				name = "September",
				value = 9,
			},
			{
				name = "October",
				value = 10,
			},
			{
				name = "November",
				value = 11,
			},
			{
				name = "December",
				value = 12,
			},
		})
	end)

	describe("returns months that start with the input", function()
		it("for 'jan'", function()
			assert.are.same({
				{
					name = "January",
					value = 1,
				},
			}, parsers.get_suggested_months("jan"))
		end)

		it("for 'j'", function()
			assert.are.same({
				{
					name = "January",
					value = 1,
				},
				{
					name = "June",
					value = 6,
				},
				{
					name = "July",
					value = 7,
				},
			}, parsers.get_suggested_months("j"))
		end)

		it("for 'J'", function()
			assert.are.same({
				{
					name = "January",
					value = 1,
				},
				{
					name = "June",
					value = 6,
				},
				{
					name = "July",
					value = 7,
				},
			}, parsers.get_suggested_months("J"))
		end)

		it("for 'October'", function()
			assert.are.same({
				{
					name = "October",
					value = 10,
				},
			}, parsers.get_suggested_months("October"))
		end)
	end)
end)

-- describe("parse_time", function()
-- 	it("parses '14:00'", function()
-- 		assert.are.same({
-- 			hours = 14,
-- 			minutes = 0,
-- 		}, parsers.parse_time("14:00"))
-- 	end)
--
-- 	it("parses '14'", function()
-- 		assert.are.same({
-- 			hours = 14,
-- 			minutes = 0,
-- 		}, parsers.parse_time("14"))
-- 	end)
--
-- 	it("parses '14:'", function()
-- 		assert.are.same({
-- 			hours = 14,
-- 			minutes = 0,
-- 		}, parsers.parse_time("14:"))
-- 	end)
--
-- 	it("parses '6:01'", function()
-- 		assert.are.same({
-- 			hours = 6,
-- 			minutes = 1,
-- 		}, parsers.parse_time("6:01"))
-- 	end)
--
-- 	it("parses '6:01pm'", function()
-- 		assert.are.same({
-- 			hours = 18,
-- 			minutes = 1,
-- 		}, parsers.parse_time("6:01pm"))
-- 	end)
--
-- 	it("parses '12:01pm'", function()
-- 		assert.are.same({
-- 			hours = 12,
-- 			minutes = 1,
-- 		}, parsers.parse_time("12:01pm"))
-- 	end)
--
-- 	it("parses '12am'", function()
-- 		assert.are.same({
-- 			hours = 12,
-- 			minutes = 0,
-- 		}, parsers.parse_time("12am"))
-- 	end)
-- end)

local Result = require("cmp-natural-dates.tluser")

describe("hour_pcomb", function()
	it("parses a valid hour", function()
		local result = parsers.hour_pcomb({
			text = "12",
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = "12",
					offset = 3,
				},
				output = {
					value = 12,
					suggestions = { "12" },
				},
			}),
			result
		)
	end)

	it("returns an error if the number is greater than 23", function()
		local result = parsers.hour_pcomb({
			text = "24",
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)

	it("returns an error if the input is not a number", function()
		local result = parsers.hour_pcomb({
			text = "am",
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("minute_pcomb", function()
	it("parses valid minutes", function()
		local result = parsers.minutes_pcomb({
			text = "32",
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = "32",
					offset = 3,
				},
				output = {
					value = 32,
					suggestions = { "32" },
				},
			}),
			result
		)
	end)

	it("pads suggested minutes to 2 places", function()
		local result = parsers.minutes_pcomb({
			text = "3",
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = "3",
					offset = 2,
				},
				output = {
					value = 3,
					suggestions = { "03" },
				},
			}),
			result
		)
	end)

	it("returns an error if the number is greater than 59", function()
		local result = parsers.minutes_pcomb({
			text = "60",
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)

	it("returns an error if the input is not a number", function()
		local result = parsers.minutes_pcomb({
			text = "am",
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("am_pm_pcomb", function()
	it("parses 'am'", function()
		local text = "am"
		local result = parsers.am_pm_pcomb({
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
					value = "am",
					suggestions = { "am" },
				},
			}),
			result
		)
	end)

	it("parses 'p'", function()
		local text = "p"
		local result = parsers.am_pm_pcomb({
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
					value = "p",
					suggestions = { "pm" },
				},
			}),
			result
		)
	end)
end)

describe("parse_time_pcomb", function()
	it("parses '14:00'", function()
		local text = "14:00"
		local result = parsers.parse_time_pcomb({
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
					value = {
						hour = 14,
						minutes = 0,
					},
					suggestions = { "14:00" },
				},
			}),
			result
		)
	end)

	it("parses '14'", function()
		local text = "14"
		local result = parsers.parse_time_pcomb({
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
					value = {
						hour = 14,
						minutes = 0,
					},
					suggestions = { "14:00" },
				},
			}),
			result
		)
	end)

	it("parses '14:'", function()
		local text = "14:"
		local result = parsers.parse_time_pcomb({
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
					value = {
						hour = 14,
						minutes = 0,
					},
					suggestions = { "14:00" },
				},
			}),
			result
		)
	end)

	it("parses '6:01'", function()
		local text = "6:01"
		local result = parsers.parse_time_pcomb({
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
					value = {
						hour = 6,
						minutes = 1,
					},
					suggestions = { "6:01" },
				},
			}),
			result
		)
	end)

	it("parses '6:01pm'", function()
		local text = "6:01pm"
		local result = parsers.parse_time_pcomb({
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
					value = {
						hour = 18,
						minutes = 1,
					},
					suggestions = { "6:01pm" },
				},
			}),
			result
		)
	end)

	it("parses '12:01pm'", function()
		local text = "12:01pm"
		local result = parsers.parse_time_pcomb({
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
					value = {
						hour = 12,
						minutes = 1,
					},
					suggestions = { "12:01pm" },
				},
			}),
			result
		)
	end)

	it("parses '12am'", function()
		local text = "12am"
		local result = parsers.parse_time_pcomb({
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
					value = {
						hour = 0,
						minutes = 0,
					},
					suggestions = { "12:00am" },
				},
			}),
			result
		)
	end)

	it("parses '12a'", function()
		local text = "12a"
		local result = parsers.parse_time_pcomb({
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
					value = {
						hour = 0,
						minutes = 0,
					},
					suggestions = { "12:00am" },
				},
			}),
			result
		)
	end)

	it("parses '12:1p'", function()
		local text = "12:1p"
		local result = parsers.parse_time_pcomb({
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
					value = {
						hour = 12,
						minutes = 1,
					},
					suggestions = { "12:01pm" },
				},
			}),
			result
		)
	end)
end)
