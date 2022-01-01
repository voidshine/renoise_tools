--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____layer_line_select = require("layers.layer_line_select")
local LayerLineSelect = ____layer_line_select.LayerLineSelect
local ____layer_transport = require("layers.layer_transport")
local LayerTransport = ____layer_transport.LayerTransport
local ____layer_cross_track_overview = require("layers.layer_cross_track_overview")
local LayerCrossTrackOverview = ____layer_cross_track_overview.LayerCrossTrackOverview
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local ____fire_defs = require("engine.fire_defs")
local FIRE_GRID_WIDTH = ____fire_defs.FIRE_GRID_WIDTH
local FIRE_GRID_HEIGHT = ____fire_defs.FIRE_GRID_HEIGHT
local ____palette = require("palette")
local PALETTE = ____palette.PALETTE
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
____exports.ModeCrossTrackOverview = __TS__Class()
local ModeCrossTrackOverview = ____exports.ModeCrossTrackOverview
ModeCrossTrackOverview.name = "ModeCrossTrackOverview"
__TS__ClassExtends(ModeCrossTrackOverview, Layer)
function ModeCrossTrackOverview.prototype.____constructor(self)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        "Cross-Track Overview Mode"
    )
    local line_select = __TS__New(LayerLineSelect, 0, PALETTE.LINE_SELECT)
    local w = line_select.grid_rect.width
    self.children = {
        __TS__New(LayerTransport),
        line_select,
        __TS__New(
            LayerCrossTrackOverview,
            __TS__New(Rect, w, 0, FIRE_GRID_WIDTH - w, FIRE_GRID_HEIGHT)
        )
    }
end
return ____exports
