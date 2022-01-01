--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____selection = require("engine.selection")
local Selection = ____selection.Selection
local PatternPos = ____selection.PatternPos
local ____layer_button_panel = require("layers.layer_button_panel")
local LayerButtonPanel = ____layer_button_panel.LayerButtonPanel
local ____palette = require("palette")
local PALETTE = ____palette.PALETTE
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____layer_line_select = require("layers.layer_line_select")
local LayerLineSelect = ____layer_line_select.LayerLineSelect
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local ____fire_defs = require("engine.fire_defs")
local FIRE_GRID_HEIGHT = ____fire_defs.FIRE_GRID_HEIGHT
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local palette = PALETTE.STEP_EDIT
____exports.LayerStepEdit = __TS__Class()
local LayerStepEdit = ____exports.LayerStepEdit
LayerStepEdit.name = "LayerStepEdit"
__TS__ClassExtends(LayerStepEdit, Layer)
function LayerStepEdit.prototype.____constructor(self)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        "Step Edit"
    )
    self.selection = __TS__New(
        Selection,
        __TS__New(PatternPos, 1, 1, 1),
        __TS__New(PatternPos, 1, 1, 1)
    )
    self.cursor = __TS__New(LayerLineSelect, 0, PALETTE.LINE_SELECT)
    local buttons = {
        {
            name = "Contract Selection Width",
            color = palette.CONTRACT_SELECTION_WIDTH,
            action = function()
                self.selection:contract_width()
                self.selection:apply()
            end
        },
        {
            name = "Expand Selection Width",
            color = palette.EXPAND_SELECTION_WIDTH,
            action = function()
                self.selection:expand_width()
                self.selection:apply()
            end
        },
        {color = palette.BACKGROUND},
        {color = palette.BACKGROUND},
        {
            name = "Deselect",
            color = palette.DESELECT,
            action = function()
                rns.selection_in_pattern = nil
            end
        },
        {
            name = "Cursor --> Select Start",
            color = palette.SELECT_START,
            action = function()
                self.selection.start_pos = PatternPos:current()
                self.selection:apply()
            end
        },
        {
            name = "Cursor --> Select End",
            color = palette.SELECT_END,
            action = function()
                self.selection.end_pos = PatternPos:current()
                self.selection:apply()
            end
        },
        {color = palette.BACKGROUND}
    }
    self.button_panel = __TS__New(
        LayerButtonPanel,
        __TS__New(Rect, 4, 0, 4, FIRE_GRID_HEIGHT),
        buttons
    )
    self:mount({self.cursor, self.button_panel})
end
function LayerStepEdit.prototype.on_idle(self)
end
function LayerStepEdit.prototype.render(self, rc, m)
    rc:clear_grid(nil)
end
return ____exports
