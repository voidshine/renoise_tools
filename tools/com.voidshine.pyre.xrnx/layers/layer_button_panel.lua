--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____fire_defs = require("engine.fire_defs")
local grid_xy_to_midi_note = ____fire_defs.grid_xy_to_midi_note
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
____exports.LayerButtonPanel = __TS__Class()
local LayerButtonPanel = ____exports.LayerButtonPanel
LayerButtonPanel.name = "LayerButtonPanel"
__TS__ClassExtends(LayerButtonPanel, Layer)
function LayerButtonPanel.prototype.____constructor(self, grid_rect, buttons)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        "Button Panel"
    )
    self.grid_rect = grid_rect
    self.buttons = buttons
    local iter
    iter = self.grid_rect:iter_xy()
    __TS__ArrayForEach(
        buttons,
        function(____, button, i)
            button.x, button.y = unpack(
                iter()
            )
            if button.action then
                self.note_on_handlers[grid_xy_to_midi_note(button.x, button.y)] = function(note, velocity)
                    rprint(button.name)
                    button.action(nil)
                end
            end
        end
    )
end
function LayerButtonPanel.prototype.render(self, rc, m)
    __TS__ArrayForEach(
        self.buttons,
        function(____, button, _)
            rc:pad(button.x, button.y, button.color)
        end
    )
end
return ____exports
