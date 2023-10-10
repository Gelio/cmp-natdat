local source = {}

function source.new()
	return setmetatable({}, { __index = source })
end

function source:get_debug_name()
	return "natural-dates"
end

local prefix = "@"

---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
	local input = string.sub(params.context.cursor_before_line, params.offset)
	vim.print({ input })
	if not vim.startswith(input, prefix) then
		callback({ isIncomplete = true })
	end
	local input_without_prefix = string.sub(input, string.len(prefix) + 1)

	callback({
		items = {
			{
				label = prefix .. "now",
				-- data = { variant = "fixed", type = "now" },
				kind = require("cmp.types.lsp").CompletionItemKind.Value,
			},
			{
				label = prefix .. "now or sth",
				kind = require("cmp.types.lsp").CompletionItemKind.Value,
			},
		},
		isIncomplete = true,
	})
end

---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
	vim.print(completion_item)
	callback(vim.tbl_extend("force", completion_item, {
		insertText = os.date("%Y-%m-%d %#H:%M", os.time()),
		documentation = "yes",
	}))
end

function source:get_trigger_characters()
	return { prefix }
end

function source:get_keyword_pattern()
	-- NOTE: allow spaces in completed text
	return string.gsub([[PREFIX\(\k\| \|:\)*]], "PREFIX", prefix)
end

return source
