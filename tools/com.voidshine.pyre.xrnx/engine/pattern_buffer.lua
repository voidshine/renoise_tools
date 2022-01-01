--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
require("engine/selection")
____exports.PatternBuffer = __TS__Class()
local PatternBuffer = ____exports.PatternBuffer
PatternBuffer.name = "PatternBuffer"
function PatternBuffer.prototype.____constructor(self, selection)
    self.selection = selection:clone()
    self:read()
end
function PatternBuffer.prototype.read(self)
end
function PatternBuffer.prototype.write_to(self, pattern_pos)
end
return ____exports
