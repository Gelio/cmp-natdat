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

describe("parse_time", function()
	it("parses '14:00'", function()
		assert.are.same({
			hours = 14,
			minutes = 0,
		}, parsers.parse_time("14:00"))
	end)

	it("parses '14'", function()
		assert.are.same({
			hours = 14,
			minutes = 0,
		}, parsers.parse_time("14"))
	end)

	it("parses '14:'", function()
		assert.are.same({
			hours = 14,
			minutes = 0,
		}, parsers.parse_time("14:"))
	end)

	it("parses '6:01'", function()
		assert.are.same({
			hours = 6,
			minutes = 1,
		}, parsers.parse_time("6:01"))
	end)

	it("parses '6:01pm'", function()
		assert.are.same({
			hours = 18,
			minutes = 1,
		}, parsers.parse_time("6:01pm"))
	end)

	it("parses '12:01pm'", function()
		assert.are.same({
			hours = 12,
			minutes = 1,
		}, parsers.parse_time("12:01pm"))
	end)

	it("parses '12am'", function()
		assert.are.same({
			hours = 12,
			minutes = 0,
		}, parsers.parse_time("12am"))
	end)
end)
