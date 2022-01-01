--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____fire_defs = require("engine.fire_defs")
local FIRE_KNOB = ____fire_defs.FIRE_KNOB
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local ____common = require("engine.common")
local MIDI = ____common.MIDI
____exports.LayerKnobsMidiPassthrough = __TS__Class()
local LayerKnobsMidiPassthrough = ____exports.LayerKnobsMidiPassthrough
LayerKnobsMidiPassthrough.name = "LayerKnobsMidiPassthrough"
__TS__ClassExtends(LayerKnobsMidiPassthrough, Layer)
function LayerKnobsMidiPassthrough.prototype.____constructor(self, channel)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        "Knobs (MIDI Passthrough)"
    )
    self.channel = 0
    self.channel = channel
    local passthrough
    passthrough = function(cc, value)
        driver.generated_midi:send_midi(
            {
                bit.bor(MIDI.CONTROL_CHANGE, self.channel),
                cc,
                value
            }
        )
    end
    self:set_cc_handlers({[FIRE_KNOB.Volume] = passthrough, [FIRE_KNOB.Pan] = passthrough, [FIRE_KNOB.Filter] = passthrough, [FIRE_KNOB.Resonance] = passthrough})
end
function LayerKnobsMidiPassthrough.prototype.update_model(self, m)
end
function LayerKnobsMidiPassthrough.prototype.render(self, rc, m)
    rc:led_text(
        -1,
        ("MIDI Knobs\nPassthrough\nChannel " .. tostring(self.channel + 1)) .. "\nCC 16,17,18,19"
    )
end
return ____exports
