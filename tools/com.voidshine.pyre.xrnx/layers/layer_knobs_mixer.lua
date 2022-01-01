--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local KNOB_VOLUME_SCALING = 0.007
local KNOB_UNIPOLAR_SCALING = 0.01
____exports.LayerKnobsMixer = __TS__Class()
local LayerKnobsMixer = ____exports.LayerKnobsMixer
LayerKnobsMixer.name = "LayerKnobsMixer"
__TS__ClassExtends(LayerKnobsMixer, Layer)
function LayerKnobsMixer.prototype.____constructor(self)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        "Knobs (Mixer)"
    )
    local on_knob
    on_knob = function(knob, delta)
        local parameter
        if knob == 0 then
            parameter = rns.selected_track.prefx_volume
            delta = delta * KNOB_VOLUME_SCALING
        elseif knob == 1 then
            parameter = rns.selected_track.prefx_panning
            delta = delta * KNOB_UNIPOLAR_SCALING
        elseif knob == 2 then
            parameter = rns.selected_track.postfx_volume
            delta = delta * KNOB_VOLUME_SCALING
        elseif knob == 3 then
            parameter = rns.selected_track.postfx_panning
            delta = delta * KNOB_UNIPOLAR_SCALING
        else
            return true
        end
        parameter.value = cLib.clamp_value(parameter.value + delta, parameter.value_min, parameter.value_max)
    end
    self:set_knob_delta_handler(on_knob)
end
function LayerKnobsMixer.prototype.update_model(self, m)
end
function LayerKnobsMixer.prototype.render(self, rc, m)
    rc:led_text(-1, "Pre-Volume\nPre-Panning\nPost-Volume\nPost-Panning\nTODO: More here.")
end
return ____exports
