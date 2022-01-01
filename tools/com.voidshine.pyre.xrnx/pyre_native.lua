--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
_G.package.cpath = (tostring(
    renoise.tool().bundle_path
) .. "/?.dll;") .. tostring(_G.package.cpath)
--CUTOLED require("pyre")
--CUTOLED require("pyre.led")
____exports.PyreFonts = {FontTiny1 = {handle = 0, height = 6}, FontTiny2 = {handle = 1, height = 12}, MegamanMono = {handle = 2, height = 10}, Megaman = {handle = 3, height = 10}}
____exports.LedRenderModel = __TS__Class()
local LedRenderModel = ____exports.LedRenderModel
LedRenderModel.name = "LedRenderModel"
function LedRenderModel.prototype.____constructor(self)
    self.draw_commands = {}
end
function LedRenderModel.prototype.clone(self)
    return self
end
____exports.PyreNative = __TS__Class()
local PyreNative = ____exports.PyreNative
PyreNative.name = "PyreNative"
function PyreNative.prototype.____constructor(self)
    self.t_sum = 0
end
function PyreNative.prototype.shutdown(self)
    --CUTOLED print("pyre_led.shutdown()")
    --CUTOLED pyre_led.shutdown()
end
function PyreNative.prototype.load_image_sysex(self, filename)
    --CUTOLED local t = os.clock()
    --CUTOLED local data = pyre_led.load_image_sysex(filename)
    --CUTOLED self.t_sum = self.t_sum + (os.clock() - t)
    --CUTOLED if not data then
        return nil
    --CUTOLED end
    --CUTOLED local copy = __TS__ArraySlice(data)
    --CUTOLED return copy
end
function PyreNative.prototype.get_led_update_sysex(self, fire_index, model)
    --CUTOLED local t = os.clock()
    --CUTOLED local data = pyre_led.get_led_update_sysex(fire_index, model)
    --CUTOLED self.t_sum = self.t_sum + (os.clock() - t)
    --CUTOLED if not data then
        return nil
    --CUTOLED end
    --CUTOLED return __TS__ArraySlice(data)
end
function PyreNative.prototype.get_time(self)
    local t = self.t_sum
    self.t_sum = 0
    return t
end
function PyreNative.prototype.get_version(self)
    --CUTOLED return pyre_led.get_version(".")
    return "0"
end
return ____exports
