local parsers = require("cmp_natdat.parsers")

local Result = require("tluser")

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
