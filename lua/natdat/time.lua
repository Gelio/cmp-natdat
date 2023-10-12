local pcombinator = require("pcomb.combinator")
local psequence = require("pcomb.sequence")
local pcharacter = require("pcomb.character")
local pnil = require("pcomb.nil")

local natdat_prefix = require("natdat.prefix")

local Result = require("tluser")

local M = {}

---@alias natdat.AMPM
---| "am"
---| "pm"

---@type pcomb.Parser<natdat.AMPM>
M.am_pm = pcombinator.map(
	pcombinator.map_res(pcharacter.alpha1, natdat_prefix.prefixes({ "am", "pm" })),
	---@param am_or_pm (natdat.AMPM)[]
	function(am_or_pm)
		assert(#am_or_pm == 1, "There is no shared prefix between 'am' and 'pm', so only one should be matched.")

		return am_or_pm[1]
	end
)

---@alias natdat.Time natdat.Time24H | natdat.TimeAMPM

---@class natdat.Time24H
---@field type "24h"
---@field hour integer Between 0 and 24
---@field minutes integer?
M.Time24H = {}
M.Time24H.__index = M.Time24H

---@param hour integer
---@param minutes integer?
function M.Time24H.new(hour, minutes)
	---@type natdat.Time24H
	local time = {
		type = "24h",
		hour = hour,
		minutes = minutes,
	}
	return setmetatable(time, M.Time24H)
end

function M.Time24H:format()
	return string.format("%d:%02d", self.hour, self.minutes or 0)
end

function M.Time24H:to_24h_time()
	return self
end

---@class natdat.TimeAMPM
---@field type "am/pm"
---@field hour integer Between 0 and 12
---@field minutes integer?
---@field am_pm natdat.AMPM
M.TimeAMPM = {}
M.TimeAMPM.__index = M.TimeAMPM

---@param hour integer
---@param minutes integer?
---@param am_pm natdat.AMPM
function M.TimeAMPM.new(hour, minutes, am_pm)
	---@type natdat.TimeAMPM
	local time = {
		type = "am/pm",
		hour = hour,
		minutes = minutes,
		am_pm = am_pm,
	}
	return setmetatable(time, M.TimeAMPM)
end

function M.TimeAMPM:format()
	local minutes_part = self.minutes ~= nil and string.format(":%02d", self.minutes) or ""

	return self.hour .. minutes_part .. self.am_pm
end

---@param hour number
---@return number
local function to_pm_hour(hour)
	if hour == 12 then
		return 12
	else
		return hour + 12
	end
end

---@param hour number
---@return number
local function to_am_hour(hour)
	if hour == 12 then
		return 0
	else
		return hour
	end
end

function M.TimeAMPM:to_24h_time()
	local hour_24h = self.am_pm == "am" and to_am_hour(self.hour) or to_pm_hour(self.hour)

	return M.Time24H.new(hour_24h, self.minutes)
end

---@type pcomb.Parser<natdat.Time24H | natdat.TimeAMPM>
M.time = pcombinator.map_res(
	psequence.sequence({
		pcharacter.integer,
		pcombinator.opt(psequence.preceded(pcharacter.tag(":"), pcharacter.integer)),
		pcombinator.opt(psequence.preceded(pcharacter.multispace0, M.am_pm)),
	}),
	---@param sequence_matches { [1]: integer, [2]: integer | pcomb.NIL, [3]: natdat.AMPM | pcomb.NIL }
	---@return tluser.Result<natdat.Time24H | natdat.TimeAMPM>
	function(sequence_matches)
		local hour = sequence_matches[1]
		if hour >= 24 then
			return Result.err("Hour " .. hour .. " is too large. It must be less than 24")
		end

		local minutes = sequence_matches[2]

		if not pnil.is_NIL(minutes) and minutes >= 60 then
			return Result.err("Minutes " .. minutes .. " is too large. It must be less than 60")
		end

		local am_pm = sequence_matches[3]

		if pnil.is_NIL(am_pm) then
			local time_24h = M.Time24H.new(hour, pnil.NIL_to_nil(minutes))
			return Result.ok(time_24h)
		end

		if hour > 12 then
			return Result.err("Hour " .. hour .. " is too large for an AM/PM hour. It must be at most 12")
		end

		---@type natdat.TimeAMPM
		local time_am_pm = {
			type = "am/pm",
			hour = hour,
			minutes = pnil.NIL_to_nil(minutes),
			am_pm = am_pm,
		}
		return Result.ok(time_am_pm)
	end
)

return M
