--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____layer_line_select = require("layers.layer_line_select")
local LayerLineSelect = ____layer_line_select.LayerLineSelect
local ____palette = require("palette")
local PALETTE = ____palette.PALETTE
local ____layer_transport = require("layers.layer_transport")
local LayerTransport = ____layer_transport.LayerTransport
local ____layer_note_grid = require("layers.layer_note_grid")
local LayerNoteGrid = ____layer_note_grid.LayerNoteGrid
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local ____fire_defs = require("engine.fire_defs")
local FIRE_GRID_WIDTH = ____fire_defs.FIRE_GRID_WIDTH
local FIRE_GRID_HEIGHT = ____fire_defs.FIRE_GRID_HEIGHT
local ____layer_knobs_navigation = require("layers.layer_knobs_navigation")
local LayerKnobsNavigation = ____layer_knobs_navigation.LayerKnobsNavigation
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local ____layer_knobs_mixer = require("layers.layer_knobs_mixer")
local LayerKnobsMixer = ____layer_knobs_mixer.LayerKnobsMixer
local ____layer_knobs_midi_passthrough = require("layers.layer_knobs_midi_passthrough")
local LayerKnobsMidiPassthrough = ____layer_knobs_midi_passthrough.LayerKnobsMidiPassthrough
local ____layer_knobs_selector = require("layers.layer_knobs_selector")
local LayerKnobsSelector = ____layer_knobs_selector.LayerKnobsSelector
local ____layer_menu_common = require("layers.layer_menu_common")
local LayerMenuCommon = ____layer_menu_common.LayerMenuCommon
____exports.ModeLineNote = __TS__Class()
local ModeLineNote = ____exports.ModeLineNote
ModeLineNote.name = "ModeLineNote"
__TS__ClassExtends(ModeLineNote, Layer)
function ModeLineNote.prototype.____constructor(self)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        "Line Note Mode"
    )
    local line_select = __TS__New(LayerLineSelect, 0, PALETTE.LINE_SELECT)
    local w = line_select.grid_rect.width
    local note_grid = __TS__New(
        LayerNoteGrid,
        "Note Grid: Line & Note",
        __TS__New(Rect, w, 0, FIRE_GRID_WIDTH - w, FIRE_GRID_HEIGHT),
        function(v) return v end
    )
    self.children = {
        __TS__New(LayerTransport),
        line_select,
        note_grid,
        __TS__New(
            LayerKnobsSelector,
            {
                __TS__New(LayerKnobsNavigation),
                __TS__New(LayerKnobsMixer),
                __TS__New(LayerKnobsMidiPassthrough, 0),
                __TS__New(LayerKnobsMidiPassthrough, 1)
            }
        )
    }
    LayerMenuCommon:create_on(self)
end
function ModeLineNote.prototype.render(self, rc, m)
end
return ____exports
