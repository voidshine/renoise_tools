--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____layer_transport = require("layers.layer_transport")
local LayerTransport = ____layer_transport.LayerTransport
local ____layer_knobs_mixer = require("layers.layer_knobs_mixer")
local LayerKnobsMixer = ____layer_knobs_mixer.LayerKnobsMixer
local ____layer_track_select = require("layers.layer_track_select")
local LayerTrackSelect = ____layer_track_select.LayerTrackSelect
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local ____fire_defs = require("engine.fire_defs")
local FIRE_GRID_WIDTH = ____fire_defs.FIRE_GRID_WIDTH
local FIRE_GRID_HEIGHT = ____fire_defs.FIRE_GRID_HEIGHT
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local ____layer_menu_common = require("layers.layer_menu_common")
local LayerMenuCommon = ____layer_menu_common.LayerMenuCommon
local ____layer_knobs_selector = require("layers.layer_knobs_selector")
local LayerKnobsSelector = ____layer_knobs_selector.LayerKnobsSelector
local ____layer_knobs_navigation = require("layers.layer_knobs_navigation")
local LayerKnobsNavigation = ____layer_knobs_navigation.LayerKnobsNavigation
local ____layer_knobs_midi_passthrough = require("layers.layer_knobs_midi_passthrough")
local LayerKnobsMidiPassthrough = ____layer_knobs_midi_passthrough.LayerKnobsMidiPassthrough
____exports.ModeMixer = __TS__Class()
local ModeMixer = ____exports.ModeMixer
ModeMixer.name = "ModeMixer"
__TS__ClassExtends(ModeMixer, Layer)
function ModeMixer.prototype.____constructor(self)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        "Mixer Mode"
    )
    self.children = {
        __TS__New(LayerTransport),
        __TS__New(
            LayerTrackSelect,
            __TS__New(Rect, 0, 0, FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT)
        ),
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
return ____exports
