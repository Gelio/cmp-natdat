---@param first_suggestions string[]?
---@param second_suggestions string[]?
---@return string[]
local function concat_suggestions(first_suggestions, second_suggestions)
	if first_suggestions == nil then
		if second_suggestions == nil then
			return {}
		end

		return second_suggestions
	elseif second_suggestions == nil then
		return first_suggestions
	end

	---@type string[]
	local concatenated_suggestions = {}
	for _, first in ipairs(first_suggestions) do
		for _, second in ipairs(second_suggestions) do
			table.insert(concatenated_suggestions, first .. " " .. second)
		end
	end

	return concatenated_suggestions
end

---@generic A
---@generic B
---@generic Output
---@param as A[]
---@param bs B[]
---@param f function(a: A, b: B): Output
---@return Output[]
local function cartesian_product(as, bs, f)
	---@type Output[]
	local outputs = {}

	for _, a in ipairs(as) do
		for _, b in ipairs(bs) do
			table.insert(outputs, f(a, b))
		end
	end

	return outputs
end
