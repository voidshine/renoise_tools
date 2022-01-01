--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
____exports.ModelLayer = __TS__Class()
local ModelLayer = ____exports.ModelLayer
ModelLayer.name = "ModelLayer"
function ModelLayer.prototype.____constructor(self)
end
function ModelLayer.prototype.__eq(self, rhs)
    for key in pairs(self) do
        local v = self[key]
        if rhs[key] ~= v then
            return false
        end
    end
    for key in pairs(rhs) do
        local v = rhs[key]
        if self[key] ~= v then
            return false
        end
    end
    return true
end
function ModelLayer.prototype.clone(self)
    return table.rcopy(self)
end
return ____exports
