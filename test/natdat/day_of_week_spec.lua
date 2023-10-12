local natdat_day_of_week = require("natdat.day_of_week")
local Result = require("tluser")

describe("DayOfWeek", function()
	describe("format_iso", function()
		---A Thursday
		---@type natdat.CurrentDateTime
		local current_date_time = {
			year = 2023,
			month = 10,
			day_of_month = 12,
			hour = 20,
			minutes = 14,
		}
		local thursday_index = 4

		it("correctly resolves the current day", function()
			assert.are.equals(
				"2023-10-12",
				natdat_day_of_week.DayOfWeek.new(thursday_index, nil):format_iso(current_date_time)
			)
		end)

		it("correctly resolves the next day", function()
			assert.are.equals(
				"2023-10-13",
				natdat_day_of_week.DayOfWeek.new(thursday_index + 1, nil):format_iso(current_date_time)
			)
		end)

		it("correctly resolves the Monday in the next week", function()
			assert.are.equals("2023-10-16", natdat_day_of_week.DayOfWeek.new(1, "next"):format_iso(current_date_time))
		end)

		it("correctly resolves the Friday last week", function()
			assert.are.equals("2023-10-08", natdat_day_of_week.DayOfWeek.new(7, "last"):format_iso(current_date_time))
		end)

		it("resolves in the previous month", function()
			---A Sunday
			local date_time_close_to_end_of_month = vim.tbl_extend("force", {}, current_date_time, {
				day_of_month = 1,
			})

			assert.are.equals(
				"2023-09-25",
				natdat_day_of_week.DayOfWeek.new(1, nil):format_iso(date_time_close_to_end_of_month)
			)
		end)

		it("resolves in the next month and year", function()
			---A Sunday
			local date_time_close_to_end_of_year = vim.tbl_extend("force", {}, current_date_time, {
				month = 12,
				day_of_month = 29,
			})

			assert.are.equals(
				"2024-01-03",
				natdat_day_of_week.DayOfWeek.new(3, "next"):format_iso(date_time_close_to_end_of_year)
			)
		end)
	end)
end)

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
