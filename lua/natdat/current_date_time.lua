local M = {}

---Current date and time.
---
---Used to fill in the missing pieces in partial
---dates, like `October 10`, or determine relative dates,
---like `tomorrow`
---
---@class natdat.CurrentDateTime
---@field year integer
---@field month integer
---@field day_of_month integer
---@field hour integer
---@field minutes integer

function M.get_current_date_time()
	local os_date = os.date("*t")

	---@type natdat.CurrentDateTime
	local current_date_time = {
		year = os_date.year,
		month = os_date.month,
		day_of_month = os_date.day,

		hour = os_date.hour,
		minutes = os_date.min,
	}

	return current_date_time
end

return M
