--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____layer_transport = require("layers.layer_transport")
local LayerTransport = ____layer_transport.LayerTransport
local ____layer_wide_step_edit = require("layers.layer_wide_step_edit")
local LayerWideStepEdit = ____layer_wide_step_edit.LayerWideStepEdit
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local ____layer_note_grid = require("layers.layer_note_grid")
local LayerNoteGrid = ____layer_note_grid.LayerNoteGrid
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local ____fire_defs = require("engine.fire_defs")
local FIRE_GRID_WIDTH = ____fire_defs.FIRE_GRID_WIDTH
local ____layer_knobs_selector = require("layers.layer_knobs_selector")
local LayerKnobsSelector = ____layer_knobs_selector.LayerKnobsSelector
local LayerKnobs = ____layer_knobs_selector.LayerKnobs
local ____layer_knobs_mixer = require("layers.layer_knobs_mixer")
local LayerKnobsMixer = ____layer_knobs_mixer.LayerKnobsMixer
local ____layer_knobs_midi_passthrough = require("layers.layer_knobs_midi_passthrough")
local LayerKnobsMidiPassthrough = ____layer_knobs_midi_passthrough.LayerKnobsMidiPassthrough
local ____layer_menu_common = require("layers.layer_menu_common")
local LayerMenuCommon = ____layer_menu_common.LayerMenuCommon
____exports.ModeStepEdit = __TS__Class()
local ModeStepEdit = ____exports.ModeStepEdit
ModeStepEdit.name = "ModeStepEdit"
__TS__ClassExtends(ModeStepEdit, Layer)
function ModeStepEdit.prototype.____constructor(self)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        "Step Edit Mode"
    )
    local step_edit = __TS__New(LayerWideStepEdit)
    self.children = {
        __TS__New(LayerTransport),
        step_edit,
        __TS__New(
            LayerNoteGrid,
            "Note Grid: Step Edit",
            __TS__New(Rect, 0, 2, FIRE_GRID_WIDTH, 2),
            function(v) return v end,
            function(note, velocity) return step_edit:on_note(note, velocity) end
        ),
        __TS__New(
            LayerKnobsSelector,
            {
                __TS__New(LayerKnobs, "Step Edit Knobs", step_edit.edit_knobs),
                __TS__New(LayerKnobsMixer),
                __TS__New(LayerKnobsMidiPassthrough, 0),
                __TS__New(LayerKnobsMidiPassthrough, 1)
            }
        )
    }
    LayerMenuCommon:create_on(self)
end
return ____exports
