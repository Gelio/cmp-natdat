local branch = require("pcomb.branch")
local character = require("pcomb.character")
local combinator = require("pcomb.combinator")
local multi = require("pcomb.multi")
local pcomb_nil = require("pcomb.nil")
local sequence = require("pcomb.sequence")

return vim.tbl_extend("error", branch, character, combinator, multi, pcomb_nil, sequence)
