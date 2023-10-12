local Result = require("tluser")
local natdat_time = require("natdat.time")

describe("am_pm", function()
	it("parses 'am'", function()
		local text = "am"
		local result = natdat_time.am_pm({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = text:len() + 1,
				},
				output = "am",
			}),
			result
		)
	end)

	it("parses 'p'", function()
		local text = "p"
		local result = natdat_time.am_pm({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = text:len() + 1,
				},
				output = "pm",
			}),
			result
		)
	end)
end)

describe("Time24H", function()
	describe("format", function()
		it("uses full numbers when hours and minutes are passed", function()
			assert.equals("9:12", natdat_time.Time24H.new(9, 12):format())
		end)

		it("uses 00 for minutes when not specified", function()
			assert.equals("14:00", natdat_time.Time24H.new(14, nil):format())
		end)

		it("pads minutes to two zeros", function()
			assert.equals("14:01", natdat_time.Time24H.new(14, 1):format())
		end)
	end)
end)

describe("TimeAMPM", function()
	describe("format", function()
		it("uses full numbers when hours and minutes are passed", function()
			assert.equals("9:12am", natdat_time.TimeAMPM.new(9, 12, "am"):format())
		end)

		it("skips minutes when not specified", function()
			assert.equals("12pm", natdat_time.TimeAMPM.new(12, nil, "pm"):format())
		end)

		it("pads minutes to two zeros", function()
			assert.equals("12:01pm", natdat_time.TimeAMPM.new(12, 1, "pm"):format())
		end)
	end)

	describe("to_24h_time", function()
		it("converts 12:01am to 0:01", function()
			assert.are.same(natdat_time.Time24H.new(0, 1), natdat_time.TimeAMPM.new(12, 1, "am"):to_24h_time())
		end)

		it("converts 12am to 0:00", function()
			assert.are.same(natdat_time.Time24H.new(0, nil), natdat_time.TimeAMPM.new(12, nil, "am"):to_24h_time())
		end)

		it("converts 12:01pm to 12:01", function()
			assert.are.same(natdat_time.Time24H.new(12, 1), natdat_time.TimeAMPM.new(12, 1, "pm"):to_24h_time())
		end)
	end)
end)

describe("time", function()
	it("parses '14:00'", function()
		local text = "14:00"
		local result = natdat_time.time({
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
					type = "24h",
					hour = 14,
					minutes = 0,
				},
			}),
			result
		)
	end)

	it("parses '14'", function()
		local text = "14"
		local result = natdat_time.time({
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
					type = "24h",
					hour = 14,
					minutes = nil,
				},
			}),
			result
		)
	end)

	it("parses '14:'", function()
		local text = "14:"
		local result = natdat_time.time({
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
					type = "24h",
					hour = 14,
					mintues = nil,
				},
			}),
			result
		)
	end)

	it("parses '6:01'", function()
		local text = "6:01"
		local result = natdat_time.time({
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
					type = "24h",
					hour = 6,
					minutes = 1,
				},
			}),
			result
		)
	end)

	it("parses '6:01pm'", function()
		local text = "6:01pm"
		local result = natdat_time.time({
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
					type = "am/pm",
					hour = 6,
					minutes = 1,
					am_pm = "pm",
				},
			}),
			result
		)
	end)

	it("parses '12:01pm'", function()
		local text = "12:01pm"
		local result = natdat_time.time({
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
					type = "am/pm",
					hour = 12,
					minutes = 1,
					am_pm = "pm",
				},
			}),
			result
		)
	end)

	it("parses '12am'", function()
		local text = "12am"
		local result = natdat_time.time({
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
					type = "am/pm",
					hour = 12,
					minutes = nil,
					am_pm = "am",
				},
			}),
			result
		)
	end)

	it("parses '12a'", function()
		local text = "12a"
		local result = natdat_time.time({
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
					type = "am/pm",
					hour = 12,
					minutes = nil,
					am_pm = "am",
				},
			}),
			result
		)
	end)

	it("parses '12:1p'", function()
		local text = "12:1p"
		local result = natdat_time.time({
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
					type = "am/pm",
					hour = 12,
					minutes = 1,
					am_pm = "pm",
				},
			}),
			result
		)
	end)

	it("parses 'Oct 10 4p' starting from '4p'", function()
		local text = "Oct 10 4p"
		local result = natdat_time.time({
			text = text,
			offset = 8,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = text:len() + 1,
				},
				output = {
					type = "am/pm",
					hour = 4,
					minutes = nil,
					am_pm = "pm",
				},
			}),
			result
		)
	end)
end)
