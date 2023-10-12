local natdat_now = require("natdat.now")
local Result = require("tluser")

describe("now", function()
	it("matches 'no '", function()
		local text = "no "
		local result = natdat_now.now({
			text = text,
			offset = 1,
		})

		assert.are.same(
			Result.ok({
				input = {
					text = text,
					offset = text:len(),
				},
				output = natdat_now.Now.new(),
			}),
			result
		)
	end)
end)
