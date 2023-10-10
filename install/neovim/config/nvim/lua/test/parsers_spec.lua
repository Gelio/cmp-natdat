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

local Result = require("cmp-natural-dates.tluser")

describe("month_pcomb", function()
	it("matches 'January'", function()
		local text = "January"
		local result = parsers.month_pcomb({
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
						word = text,
						matched_month = {
							name = "January",
							value = 1,
						},
					},
					suggestions = { "January" },
				},
			}),
			result
		)
	end)

	it("matches 'Jan'", function()
		local text = "Jan"
		local result = parsers.month_pcomb({
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
						word = text,
						matched_month = {
							name = "January",
							value = 1,
						},
					},
					suggestions = { "January" },
				},
			}),
			result
		)
	end)

	it("matches 'J and some more'", function()
		local text = "J and some more"
		local result = parsers.month_pcomb({
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
					value = {
						word = "J",
						matched_month = nil,
					},
					suggestions = { "January", "June", "July" },
				},
			}),
			result
		)
	end)

	it("returns an error when no month can be matched", function()
		local text = "and some more"
		local result = parsers.month_pcomb({
			text = text,
			offset = 1,
		})

		assert.is_true(result:is_err())
	end)
end)

describe("date_pcomb", function()
	it("matches 'Oct 10 2023'", function()
		local text = "Oct 10 2023"
		local result = parsers.date_pcomb({
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
						month = 10,
						year = 2023,
						day_of_month = 10,
					},
					suggestions = { "October 10 2023" },
				},
			}),
			result
		)
	end)

	it("matches 'Oct 10'", function()
		local text = "Oct 10"
		local result = parsers.date_pcomb({
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
						month = 10,
						year = nil,
						day_of_month = 10,
					},
					suggestions = { "October 10" },
				},
			}),
			result
		)
	end)

	it("matches 'J 10'", function()
		local text = "J 10"
		local result = parsers.date_pcomb({
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
						month = nil,
						year = nil,
						day_of_month = 10,
					},
					suggestions = { "January 10", "June 10", "July 10" },
				},
			}),
			result
		)
	end)

	it("matches 'Jan'", function()
		local text = "Jan"
		local result = parsers.date_pcomb({
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
						month = 1,
						year = nil,
						day_of_month = nil,
					},
					suggestions = { "January" },
				},
			}),
			result
		)
	end)
end)

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
