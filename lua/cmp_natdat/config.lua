---cmp_natdat configuration accepted by the .setup() function.
---@class cmp_natdat.Config
---An existing highlight group to use for the cmp_natdat completions in the
---nvim-cmp popup
---@field highlight_group string?
---Text to use for the labels of cmp_natdat completions in the nvim-cmp popup
---@field cmp_kind_text string?

---Full cmp_natdat configuration
---@class cmp_natdat.FullConfig
---@field highlight_group string
---@field cmp_kind_text string

---@type cmp_natdat.FullConfig
local default_config = {
	highlight_group = "CmpItemKindText",
	cmp_kind_text = "Text",
}

return {
	default = default_config,
}
