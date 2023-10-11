local M = {}

function M.setup()
	require("cmp").register_source("natdat", require("cmp_natdat.source").new())
end

return M
