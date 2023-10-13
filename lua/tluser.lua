---A Result type, inspired by Rust's Result
---@see https://doc.rust-lang.org/std/result/
---
---Generics are not well supported by Lua-LS,
---which is why it is not as expressive as the Rust counterpart.
---@see https://github.com/LuaLS/lua-language-server/issues/1861
---
---@class tluser.Result<T, E>: { variant: "ok" | "error", value: T?, error: E? }
local M = {}
M.__index = M

---@generic T
---@param value T
---@return tluser.Result<T, nil>
function M.ok(value)
	local result = setmetatable({ variant = "ok", value = value, error = nil }, M)
	return result
end

---@generic E
---@param error E
---@return tluser.Result<nil, E>
function M.err(error)
	local result = setmetatable({ variant = "error", error = error, value = nil }, M)

	return result
end

---@param self tluser.Result<unknown, unknown>
---@return boolean
function M.is_ok(self)
	return self.variant == "ok"
end

---@param self tluser.Result<unknown, unknown>
---@return boolean
function M.is_err(self)
	return self.variant == "error"
end

---Yields the current Result to the parent `M.run` context.
---The function is resumed with the Result's "ok" value.
---@see M.run
---
---@generic T
---@param self tluser.Result<T, unknown>
---@return T
function M.get_ok(self)
	return coroutine.yield(self)
end

---Runs the `f` function until it completes.
---Each time `f` yields a Result, `f` is resumed only when the yielded Result
---was "ok".
---@see M.get_ok
---
---@param f fun(): unknown
---@return tluser.Result<unknown, unknown>
function M.run(f)
	local co = coroutine.create(f)

	---@type tluser.Result<unknown, unknown> | nil
	local last_result = nil

	while coroutine.status(co) == "suspended" and (last_result == nil or last_result:is_ok()) do
		local success
		success, last_result = coroutine.resume(co, last_result ~= nil and last_result.value or nil)

		if not success then
			-- NOTE: propagate errors
			error(last_result)
		end

		if last_result == nil then
			break
		elseif getmetatable(last_result) ~= M then
			last_result = M.ok(last_result)
		end
	end

	return last_result
end

---@generic T
---@param self tluser.Result<T, unknown>
---@return T?
function M.ok_or_nil(self)
	if M.is_ok(self) then
		return self.value
	else
		return nil
	end
end

---Separates successful values and errors into two lists.
---
---@generic T
---@generic E
---@param results tluser.Result<T, E>[]
---@return T[], E[]
function M.partition_list(results)
	---@type T[]
	local oks = {}
	---@type E[]
	local errors = {}

	for _, result in ipairs(results) do
		if result:is_ok() then
			table.insert(oks, result.value)
		else
			table.insert(errors, result.error)
		end
	end

	return oks, errors
end

---@generic T
---@generic U
---@generic E
---@param result tluser.Result<T, E>
---@param f function(t: T): U
---@return tluser.Result<U, E>
function M.map(result, f)
	if result:is_ok() then
		return M.ok(f(result.value))
	else
		return result
	end
end

return M
