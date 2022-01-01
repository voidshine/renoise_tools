--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____layer_transport = require("layers.layer_transport")
local LayerTransport = ____layer_transport.LayerTransport
local ____layer_note_grid = require("layers.layer_note_grid")
local LayerNoteGrid = ____layer_note_grid.LayerNoteGrid
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local ____layer_knobs_selector = require("layers.layer_knobs_selector")
local LayerKnobsSelector = ____layer_knobs_selector.LayerKnobsSelector
local LayerKnobs = ____layer_knobs_selector.LayerKnobs
local ____layer_knobs_midi_passthrough = require("layers.layer_knobs_midi_passthrough")
local LayerKnobsMidiPassthrough = ____layer_knobs_midi_passthrough.LayerKnobsMidiPassthrough
local ____layer_knobs_mixer = require("layers.layer_knobs_mixer")
local LayerKnobsMixer = ____layer_knobs_mixer.LayerKnobsMixer
local ____layer_menu_common = require("layers.layer_menu_common")
local LayerMenuCommon = ____layer_menu_common.LayerMenuCommon
local ____knob = require("engine.knob")
local KnobVelocity = ____knob.KnobVelocity
local KnobPitchWheel = ____knob.KnobPitchWheel
local KnobModulationWheel = ____knob.KnobModulationWheel
local KnobChannelPressure = ____knob.KnobChannelPressure
____exports.ModeNote = __TS__Class()
local ModeNote = ____exports.ModeNote
ModeNote.name = "ModeNote"
__TS__ClassExtends(ModeNote, Layer)
function ModeNote.prototype.____constructor(self)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        "Note Mode"
    )
    local knob_velocity = __TS__New(KnobVelocity)
    self.children = {
        __TS__New(LayerTransport),
        __TS__New(
            LayerNoteGrid,
            "Note Grid: Performance",
            nil,
            function(velocity)
                return knob_velocity:get_value()
            end
        ),
        __TS__New(
            LayerKnobsSelector,
            {
                __TS__New(
                    LayerKnobs,
                    "Note Expression",
                    {
                        knob_velocity,
                        __TS__New(KnobPitchWheel),
                        __TS__New(KnobModulationWheel),
                        __TS__New(KnobChannelPressure)
                    }
                ),
                __TS__New(LayerKnobsMixer),
                __TS__New(LayerKnobsMidiPassthrough, 0),
                __TS__New(LayerKnobsMidiPassthrough, 1)
            }
        )
    }
    LayerMenuCommon:create_on(self)
end
function ModeNote.prototype.render(self, rc, m)
end
return ____exports
