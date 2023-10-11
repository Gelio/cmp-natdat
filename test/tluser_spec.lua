local Result = require("cmp_natdat.tluser")

describe("constructors and basic predicates", function()
	it("constructs an Ok", function()
		local value = Result.ok("yup")
		assert.is_true(value:is_ok())
	end)
	it("constructs an Error", function()
		local value = Result.err("yup")
		assert.is_true(value:is_err())
	end)
end)

describe("run", function()
	it("extracts Ok values and resumes the inner function", function()
		local result = Result.run(function()
			local inner_ok = Result.ok("yes")
			local inner_value = inner_ok:get_ok()
			assert.are.equals("yes", inner_value)
			return inner_value
		end)

		assert.are.same(Result.ok("yes"), result)
	end)

	it("returns the inner Err value", function()
		local result = Result.run(function()
			local inner_ok = Result.err("some error here")
			inner_ok:get_ok()
			error("this should never run")
		end)

		assert.are.same(Result.err("some error here"), result)
	end)
end)

describe("ok_or_nil", function()
	it("returns the value if successful", function()
		assert.are.equals("yes", Result.ok("yes"):ok_or_nil())
	end)

	it("returns nil if error", function()
		assert.are.equals(nil, Result.err("error"):ok_or_nil())
	end)
end)

describe("partition_list", function()
	it("returns a list of oks and a list of errors", function()
		local oks, errors = Result.partition_list({
			Result.ok(1),
			Result.err("err1"),
			Result.err("err2"),
			Result.ok(2),
		})

		assert.are.same({ 1, 2 }, oks)
		assert.are.same({ "err1", "err2" }, errors)
	end)
end)

describe("map", function()
	it("modifies the ok value", function()
		local result = Result.ok(1):map(function(x)
			return x + 1
		end)

		assert.are.same(Result.ok(2), result)
	end)

	it("leaves the error intact", function()
		local result = Result.err("err")

		assert.are.same(
			Result.err("err"),
			result:map(function(x)
				return x + 1
			end)
		)
	end)
end)
