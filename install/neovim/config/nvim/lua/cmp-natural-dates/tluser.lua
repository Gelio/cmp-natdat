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

---@generic T
---@param self tluser.Result<T, unknown>
---@return T
function M.get_ok(self)
	return coroutine.yield(self)
end

---@param f function
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

return M
