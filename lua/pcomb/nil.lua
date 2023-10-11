local M = {}

---An artificial replacement for `nil` to allow storing `NIL` in tables.
---Useful in `pcomb.sequence`
---@alias pcomb.NIL "pcomb.NIL"[]

---@type pcomb.NIL
M.NIL = {
	"pcomb.NIL",
}

---@param value unknown
---@return boolean
function M.is_NIL(value)
	return type(value) == "table" and value[1] == "pcomb.NIL"
end

---@generic T
---@param value T | pcomb.NIL
---@return T | nil
function M.NIL_to_nil(value)
	if M.is_NIL(value) then
		return nil
	else
		return value
	end
end

return M
