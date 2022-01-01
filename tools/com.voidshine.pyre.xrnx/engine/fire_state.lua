--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local defs = require("engine.fire_defs")
local ____fire_grid_state = require("engine.fire_grid_state")
local FireGridState = ____fire_grid_state.FireGridState
local ____fire_led_state = require("engine.fire_led_state")
local FireLedState = ____fire_led_state.FireLedState
local ____color = require("engine.color")
local Color = ____color.Color
local ____pyre_native = require("pyre_native")
local LedRenderModel = ____pyre_native.LedRenderModel
local ____draw = require("engine.draw")
local DrawClear = ____draw.DrawClear
____exports.FireState = __TS__Class()
local FireState = ____exports.FireState
FireState.name = "FireState"
function FireState.prototype.____constructor(self, copy_from)
    if copy_from then
        self.grid = copy_from.grid:clone()
        self.lights = table.rcopy(copy_from.lights)
        self.quad_light = copy_from.quad_light
        self.led_lua = copy_from.led_lua:clone()
        self.led_model = copy_from.led_model:clone()
    else
        self.grid = __TS__New(FireGridState, nil)
        self.lights = {}
        self.quad_light = 0
        self.led_lua = __TS__New(FireLedState, nil)
        self.led_model = __TS__New(LedRenderModel)
        self:clear()
    end
end
function FireState.prototype.clone(self)
    return __TS__New(____exports.FireState, self)
end
function FireState.prototype.__eq(self, rhs)
    return self.grid == rhs.grid
end
function FireState.prototype.clear(self)
    self.grid:clear()
    for key in pairs(defs.FIRE_LIGHT) do
        local note = defs.FIRE_LIGHT[key]
        self.lights[note] = Color:black()
    end
    self.quad_light = 0
    self.led_model.draw_commands = {DrawClear.INSTANCE}
end
function FireState.prototype.get_midi_messages(self, fire_index, state_on_device, quick)
    local messages = {}
    local add
    add = function(e)
        if e then
            __TS__ArrayPush(messages, e)
        end
    end
    if state_on_device then
        add(
            self.grid:get_sysex(state_on_device.grid)
        )
        if state_on_device.quad_light ~= self.quad_light then
            add(
                defs.get_midi_quad_light(self.quad_light)
            )
        end
    else
        add(
            self.grid:get_sysex(nil)
        )
        add(
            defs.get_midi_quad_light(self.quad_light)
        )
    end
    for key in pairs(defs.FIRE_LIGHT) do
        local note = defs.FIRE_LIGHT[key]
        local color = self.lights[note]
        if (not state_on_device) or (state_on_device.lights[note] ~= color) then
            add(
                defs.get_midi_light(note, color)
            )
        end
    end
    if not quick then
        add(
            self.led_lua:get_sysex()
        )
        add(
            pyre_native:get_led_update_sysex(fire_index, self.led_model)
        )
    end
    return messages
end
return ____exports
