local parsers = require("cmp_natdat.parsers")

local Result = require("tluser")

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

	it("matches 'Oct 10 14:' without parsing the '14:' as part of year", function()
		local text = "Oct 10 14:"
		local result = parsers.date_pcomb({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 7,
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

	it("matches 'Oct 10 14p' without parsing the '14:' as part of year", function()
		local text = "Oct 10 14p"
		local result = parsers.date_pcomb({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 7,
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

describe("date_time_pcomb", function()
	it("matches 'Oct 10 4p'", function()
		local text = "Oct 10 4p"
		local result = parsers.date_time_pcomb({
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
						matched_date = {
							month = 10,
							year = nil,
							day_of_month = 10,
						},
						matched_time = {
							hour = 16,
							minutes = 0,
						},
					},
					suggestions = { "October 10 4:00pm" },
				},
			}),
			result
		)
	end)

	it("matches 'Oct 10 2023 14:00'", function()
		local text = "Oct 10 2023 14:00"
		local result = parsers.date_time_pcomb({
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
						matched_date = {
							month = 10,
							year = 2023,
							day_of_month = 10,
						},
						matched_time = {
							hour = 14,
							minutes = 0,
						},
					},
					suggestions = { "October 10 2023 14:00" },
				},
			}),
			result
		)
	end)

	it("matches 'Oct'", function()
		local text = "Oct"
		local result = parsers.date_time_pcomb({
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
					value = {
						matched_date = {
							month = 10,
							year = nil,
							day_of_month = nil,
						},
						matched_time = nil,
					},
					suggestions = { "October" },
				},
			}),
			result
		)
	end)

	it("matches 'Oct '", function()
		local text = "Oct "
		local result = parsers.date_time_pcomb({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = 5,
				},
				output = {
					value = {
						matched_date = {
							month = 10,
							year = nil,
							day_of_month = nil,
						},
						matched_time = nil,
					},
					suggestions = { "October" },
				},
			}),
			result
		)
	end)
end)
