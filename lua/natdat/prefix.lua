local M = {}

local Result = require("tluser")

---@param words string[]
---@param prefix string
---@return integer[] `words` indices for which `prefix` is a prefix
local function get_prefix_indices_case_insensitive(words, prefix)
	local lowercase_prefix = prefix:lower()

	---@type integer[]
	local indices = {}

	for index, word in ipairs(words) do
		if vim.startswith(word:lower(), lowercase_prefix) then
			table.insert(indices, index)
		end
	end

	return indices
end

---Returns these `words` indices for which the `word` is a prefix.
---@param words string[]
---@return fun(word: string): tluser.Result<integer[], string>
function M.prefix_indices(words)
	return function(word)
		local word_indices = get_prefix_indices_case_insensitive(words, word)

		if #word_indices == 0 then
			return Result.err("No word matched prefix '" .. word .. "'")
		end

		return Result.ok(word_indices)
	end
end

---Returns these `words` for which the `word` is a prefix.
---@param words string[]
---@return fun(word: string): tluser.Result<string[], string>
function M.prefixes(words)
	return function(word)
		return M.prefix_indices(words)(word):map(function(indices)
			return vim.tbl_map(function(index)
				return words[index]
			end, indices)
		end)
	end
end

return M
