local M = {}

local cmp_natdat_common = require("cmp_natdat.common")
local cmp_natdat_config = require("cmp_natdat.config")

---@param highlight_group string
local function set_completion_highlight_group(highlight_group)
	local GLOBAL_HIGHLIGHT_NAMESPACE = 0

	vim.api.nvim_set_hl(
		GLOBAL_HIGHLIGHT_NAMESPACE,
		cmp_natdat_common.COMPLETION_HIGHLIGHT_GROUP,
		{ link = highlight_group }
	)
end

---@param config cmp_natdat.Config?
function M.setup(config)
	config = config or {}

	---@type cmp_natdat.FullConfig
	local full_config = vim.tbl_extend("force", cmp_natdat_config.default, config)

	set_completion_highlight_group(full_config.highlight_group)

	---@type lsp.internal.CmpCompletionExtension
	local cmp_completion_extension = {
		kind_text = full_config.cmp_kind_text,
		kind_hl_group = cmp_natdat_common.COMPLETION_HIGHLIGHT_GROUP,
	}

	require("cmp").register_source("natdat", require("cmp_natdat.source").new(cmp_completion_extension))
end

return M
