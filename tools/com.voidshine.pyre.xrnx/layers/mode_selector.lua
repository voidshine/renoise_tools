--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____mode_line_note = require("layers.mode_line_note")
local ModeLineNote = ____mode_line_note.ModeLineNote
local ____mode_mixer = require("layers.mode_mixer")
local ModeMixer = ____mode_mixer.ModeMixer
local ____mode_note = require("layers.mode_note")
local ModeNote = ____mode_note.ModeNote
local ____mode_step_edit = require("layers.mode_step_edit")
local ModeStepEdit = ____mode_step_edit.ModeStepEdit
local defs = require("engine.fire_defs")
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____color = require("engine.color")
local Color = ____color.Color
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local ____mode_generate_euclidean = require("layers.mode_generate_euclidean")
local ModeGenerateEuclidean = ____mode_generate_euclidean.ModeGenerateEuclidean
local ____mode_toys = require("layers.mode_toys")
local ModeToys = ____mode_toys.ModeToys
local MODES = {["Line & Note"] = ModeLineNote, Mixer = ModeMixer, Note = ModeNote, ["Step Edit"] = ModeStepEdit, ["Generate Euclidean"] = ModeGenerateEuclidean, Toys = ModeToys}
local ModelModeSelector = __TS__Class()
ModelModeSelector.name = "ModelModeSelector"
__TS__ClassExtends(ModelModeSelector, ModelLayer)
function ModelModeSelector.prototype.____constructor(self, ...)
    ModelLayer.prototype.____constructor(self, ...)
    self.current_mode_light = -1
end
function ModelModeSelector.prototype.__eq(self, rhs)
    return ModelLayer.prototype.__eq(self, rhs)
end
____exports.ModeSelector = __TS__Class()
local ModeSelector = ____exports.ModeSelector
ModeSelector.name = "ModeSelector"
__TS__ClassExtends(ModeSelector, Layer)
function ModeSelector.prototype.____constructor(self, mode_bindings, fire_device_index)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelModeSelector),
        "Mode Selector"
    )
    self.fire_device_index = fire_device_index
    self.button_lights = {}
    for button_name in pairs(mode_bindings) do
        local mode_list = mode_bindings[button_name]
        local button = defs.FIRE_BUTTON[button_name]
        __TS__ArrayPush(self.button_lights, defs.FIRE_BUTTON_TO_LIGHT[button])
        local modes = {}
        __TS__ArrayForEach(
            mode_list,
            function(____, mode_name, i)
                local mode = __TS__New(MODES[mode_name])
                __TS__ArrayPush(modes, mode)
            end
        )
        self:bind_modes(button, modes)
    end
end
function ModeSelector.prototype.bind_modes(self, button, modes)
    local light = defs.FIRE_BUTTON_TO_LIGHT[button]
    assert(light ~= nil)
    local index = 0
    self:set_note_on_handlers(
        {
            [button] = function()
                if self.model.current_mode_light == light then
                    index = index + 1
                    if not modes[index + 1] then
                        index = 0
                    end
                end
                self.model.current_mode_light = light
                self:set_mode(modes[index + 1])
            end
        }
    )
end
function ModeSelector.prototype.set_mode(self, mode)
    oprint(
        (("Fire #" .. tostring(self.fire_device_index)) .. " set mode: ") .. tostring(mode.name)
    )
    self:mount({mode})
end
function ModeSelector.prototype.render(self, rc, m)
    rc:clear()
    rc:quad_light_select(self.fire_device_index)
    __TS__ArrayForEach(
        self.button_lights,
        function(____, button_light, _)
            if m.current_mode_light == button_light then
                rc:light(button_light, defs.LIGHT_DARK_RED)
            else
                rc:light(button_light, defs.LIGHT_DARK_ORANGE)
            end
        end
    )
    do
        local y = 0
        while y < defs.FIRE_GRID_HEIGHT do
            do
                local x = 0
                while x < defs.FIRE_GRID_WIDTH do
                    rc:pad(
                        x,
                        y,
                        Color:hsv({x / defs.FIRE_GRID_WIDTH, (defs.FIRE_GRID_HEIGHT - y) / defs.FIRE_GRID_HEIGHT, 1})
                    )
                    x = x + 1
                end
            end
            y = y + 1
        end
    end
end
return ____exports
