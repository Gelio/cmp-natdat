local source = {}

function source.new()
	return setmetatable({}, { __index = source })
end

function source:get_debug_name()
	return "natdat"
end

local prefix = "@"

local natdat = require("natdat")
local natdat_date = require("natdat.date")
local natdat_current_date_time = require("natdat.current_date_time")

---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
	local input = string.sub(params.context.cursor_before_line, params.offset)

	if not vim.startswith(input, prefix) then
		callback({ isIncomplete = true })
	end

	local input_without_prefix = string.sub(input, string.len(prefix) + 1)

	local results = natdat.parse(input_without_prefix)
	if #results == 0 then
		callback({ isIncomplete = true })
	end
	local current_date_time = natdat_current_date_time.get_current_date_time()

	callback({
		isIncomplete = true,
		items = vim.tbl_map(function(item)
			---@type string?
			local iso_date_time = nil

			-- NOTE: just `Month`s do not resolve to any ISO date time, because the date is not clear
			if getmetatable(item) ~= natdat_date.Month then
				iso_date_time = item:format_iso(current_date_time)
			end

			return { label = prefix .. item:format_original(), data = iso_date_time }
		end, results),
	})
end

---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
	callback(vim.tbl_extend("force", completion_item, {
		insertText = completion_item.data,
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
