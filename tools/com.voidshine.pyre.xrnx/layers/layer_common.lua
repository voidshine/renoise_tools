--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local defs = require("engine.fire_defs")
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local ____palette = require("palette")
local PALETTE = ____palette.PALETTE
local ____utility = require("engine.utility")
local step_track_column = ____utility.step_track_column
local palette = PALETTE.COMMON
____exports.ModelCommon = __TS__Class()
local ModelCommon = ____exports.ModelCommon
ModelCommon.name = "ModelCommon"
__TS__ClassExtends(ModelCommon, ModelLayer)
function ModelCommon.prototype.____constructor(self, ...)
    ModelLayer.prototype.____constructor(self, ...)
    self.shift = false
    self.alt = false
end
function ModelCommon.prototype.__eq(self, rhs)
    return ModelLayer.prototype.__eq(self, rhs)
end
____exports.LayerCommon = __TS__Class()
local LayerCommon = ____exports.LayerCommon
LayerCommon.name = "LayerCommon"
__TS__ClassExtends(LayerCommon, Layer)
function LayerCommon.prototype.____constructor(self, model, name)
    Layer.prototype.____constructor(self, model, name)
    self:set_note_on_handlers(
        {
            [defs.FIRE_BUTTON.Shift] = function()
                self.model.shift = true
                return true
            end,
            [defs.FIRE_BUTTON.Alt] = function()
                self.model.alt = true
                return true
            end,
            [defs.FIRE_BUTTON.PatternUp] = function()
                local n = #rns.sequencer.pattern_sequence
                rns.selected_sequence_index = ((((rns.selected_sequence_index - 1) + n) - 1) % n) + 1
            end,
            [defs.FIRE_BUTTON.PatternDown] = function()
                rns.selected_sequence_index = (((rns.selected_sequence_index - 1) + 1) % #rns.sequencer.pattern_sequence) + 1
            end,
            [defs.FIRE_BUTTON.GridLeft] = function()
                if self.model.shift then
                    if rns.selected_track.visible_note_columns > 1 then
                        local ____obj, ____index = rns.selected_track, "visible_note_columns"
                        ____obj[____index] = ____obj[____index] - 1
                    end
                elseif self.model.alt then
                    step_track_column(-1, true, true, true)
                else
                    step_track_column(-1, false, false, true)
                end
            end,
            [defs.FIRE_BUTTON.GridRight] = function()
                if self.model.shift then
                    local note_columns = rns.selected_track.visible_note_columns
                    if (note_columns > 0) and (note_columns < 12) then
                        local ____obj, ____index = rns.selected_track, "visible_note_columns"
                        ____obj[____index] = ____obj[____index] + 1
                    end
                elseif self.model.alt then
                    step_track_column(1, true, true, true)
                else
                    step_track_column(1, false, false, true)
                end
            end
        }
    )
    self:set_note_off_handlers(
        {
            [defs.FIRE_BUTTON.Shift] = function()
                self.model.shift = false
                return true
            end,
            [defs.FIRE_BUTTON.Alt] = function()
                self.model.alt = false
                return true
            end
        }
    )
end
function LayerCommon.prototype.render(self, rc, m)
    rc:light(defs.FIRE_LIGHT.Shift, (m.shift and palette.MODIFIER_PRESSED) or palette.OFF)
    rc:light(defs.FIRE_LIGHT.Alt, (m.alt and palette.MODIFIER_PRESSED) or palette.OFF)
    rc:light(defs.FIRE_LIGHT.PatternUp, defs.LIGHT_DARK_RED)
    rc:light(defs.FIRE_LIGHT.PatternDown, defs.LIGHT_DARK_RED)
    rc:light(defs.FIRE_LIGHT.GridLeft, defs.LIGHT_DARK_RED)
    rc:light(defs.FIRE_LIGHT.GridRight, defs.LIGHT_DARK_RED)
end
return ____exports
