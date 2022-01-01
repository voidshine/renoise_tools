--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local ____fire_defs = require("engine.fire_defs")
local FIRE_GRID_HEIGHT = ____fire_defs.FIRE_GRID_HEIGHT
local FIRE_GRID_WIDTH = ____fire_defs.FIRE_GRID_WIDTH
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local LayerModelCrossTrackOverview = __TS__Class()
LayerModelCrossTrackOverview.name = "LayerModelCrossTrackOverview"
__TS__ClassExtends(LayerModelCrossTrackOverview, ModelLayer)
function LayerModelCrossTrackOverview.prototype.____constructor(self, lines_per_row)
    ModelLayer.prototype.____constructor(self)
    self.lines_per_row = lines_per_row
end
function LayerModelCrossTrackOverview.prototype.__eq(self, rhs)
    return ModelLayer.prototype.__eq(self, rhs)
end
____exports.LayerCrossTrackOverview = __TS__Class()
local LayerCrossTrackOverview = ____exports.LayerCrossTrackOverview
LayerCrossTrackOverview.name = "LayerCrossTrackOverview"
__TS__ClassExtends(LayerCrossTrackOverview, Layer)
function LayerCrossTrackOverview.prototype.____constructor(self, grid_rect)
    Layer.prototype.____constructor(
        self,
        __TS__New(LayerModelCrossTrackOverview, 4),
        "Cross-Track Overview"
    )
    self.grid_rect = grid_rect or __TS__New(Rect, 0, 0, FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT)
end
function LayerCrossTrackOverview.prototype.update_model(self, m)
    m.selected_line_index = rns.selected_line_index - 1
end
function LayerCrossTrackOverview.prototype.render(self, rc, m)
end
return ____exports
