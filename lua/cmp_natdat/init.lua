local M = {}

function M.setup()
	require("cmp").register_source("natural_dates", require("cmp_natdat.source").new())
end

return M
