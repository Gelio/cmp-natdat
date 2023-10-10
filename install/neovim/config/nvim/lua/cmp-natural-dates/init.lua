local M = {}

function M.setup()
	require("cmp").register_source("natural_dates", require("cmp-natural-dates.source").new())
end

return M
