---Parser input
---@class pcomb.Input
---@field text string
---@field offset number 1-based index of the next token to parse from text

---@alias pcomb.Parser<Output> fun(input: pcomb.Input): tluser.Result<pcomb.Result<Output>, string>

---Successful parsing result
---@class pcomb.Result<Output>: { input: pcomb.Input, output: Output }
