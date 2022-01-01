--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____fire_defs = require("engine.fire_defs")
local FIRE_GRID_HEIGHT = ____fire_defs.FIRE_GRID_HEIGHT
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local Vec2 = ____utility.Vec2
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local DOUBLE_TAP_TIME_WINDOW = 0.65
local WIDTH = 4
local HEIGHT = FIRE_GRID_HEIGHT
____exports.ModelLineSelect = __TS__Class()
local ModelLineSelect = ____exports.ModelLineSelect
ModelLineSelect.name = "ModelLineSelect"
__TS__ClassExtends(ModelLineSelect, ModelLayer)
function ModelLineSelect.prototype.____constructor(self, ...)
    ModelLayer.prototype.____constructor(self, ...)
    self.show_value = 0
end
function ModelLineSelect.prototype.__eq(self, rhs)
    return ModelLayer.prototype.__eq(self, rhs)
end
____exports.LayerLineSelectHorizontal = __TS__Class()
local LayerLineSelectHorizontal = ____exports.LayerLineSelectHorizontal
LayerLineSelectHorizontal.name = "LayerLineSelectHorizontal"
__TS__ClassExtends(LayerLineSelectHorizontal, Layer)
function LayerLineSelectHorizontal.prototype.____constructor(self, grid_left, palette)
    Layer.prototype.____constructor(
        self,
        __TS__New(____exports.ModelLineSelect),
        "Line Select"
    )
    self.grid_rect = __TS__New(Rect, grid_left, 0, WIDTH, HEIGHT)
    self.palette = palette
    local last_press_time = os.clock() - DOUBLE_TAP_TIME_WINDOW
    local last_press = __TS__New(Vec2, -1, -1)
    local on_grid_pad
    on_grid_pad = function(x, y, velocity)
        if velocity then
            x, y = self:transform_xy(x, y)
            local now = os.clock()
            local current = self:get_value()
            local segment_value = math.pow(WIDTH, (HEIGHT - 1) - y)
            local above_value = segment_value * WIDTH
            if ((last_press.x == x) and (last_press.y == y)) and ((last_press_time + DOUBLE_TAP_TIME_WINDOW) > now) then
                if (x == (WIDTH - 1)) and (y == (HEIGHT - 1)) then
                    current = self:get_value_count() - 1
                elseif (x == 0) and (y == 0) then
                    current = 0
                else
                    current = (current - math.fmod(current, above_value)) + (segment_value * x)
                end
            else
                current = ((current - math.fmod(current, above_value)) + math.fmod(current, segment_value)) + (segment_value * x)
            end
            current = cLib.clamp_value(
                current,
                0,
                self:get_value_count() - 1
            )
            self:set_value(current)
            last_press.x = x
            last_press.y = y
            last_press_time = now
        end
    end
    self:set_note_handlers_grid_rect(self.grid_rect, on_grid_pad)
end
function LayerLineSelectHorizontal.prototype.transform_xy(self, x, y)
    return x, y
end
function LayerLineSelectHorizontal.prototype.update_model(self, m)
    m.show_value = rns.selected_line_index - 1
end
function LayerLineSelectHorizontal.prototype.render(self, rc, m)
    local current = m.show_value
    local xs = {}
    do
        local i = 0
        while i < HEIGHT do
            local power = (HEIGHT - 1) - i
            xs[i + 1] = self.grid_rect.left + math.floor(
                math.fmod(
                    current,
                    math.pow(WIDTH, power + 1)
                ) / math.pow(WIDTH, power)
            )
            i = i + 1
        end
    end
    for ____value in self.grid_rect:iter_xy() do
        local x = ____value[1]
        local y = ____value[2]
        local color = ((xs[y + 1] == x) and self.palette.FOREGROUND_COLOR) or self.palette.BACKGROUND_COLOR
        rc:pad(x, y, color)
    end
end
function LayerLineSelectHorizontal.prototype.get_value(self)
    return self.model.show_value
end
function LayerLineSelectHorizontal.prototype.set_value(self, value)
    rns.selected_line_index = value + 1
    self.model.show_value = value
end
function LayerLineSelectHorizontal.prototype.get_value_count(self)
    return rns.selected_pattern.number_of_lines
end
____exports.LayerLineSelectVertical = __TS__Class()
local LayerLineSelectVertical = ____exports.LayerLineSelectVertical
LayerLineSelectVertical.name = "LayerLineSelectVertical"
__TS__ClassExtends(LayerLineSelectVertical, ____exports.LayerLineSelectHorizontal)
function LayerLineSelectVertical.prototype.transform_xy(self, x, y)
    return y, x
end
function LayerLineSelectVertical.prototype.render(self, rc, m)
    local current = m.show_value
    local ys = {}
    do
        local i = 0
        while i < HEIGHT do
            local power = (HEIGHT - 1) - i
            ys[i + 1] = self.grid_rect.top + math.floor(
                math.fmod(
                    current,
                    math.pow(WIDTH, power + 1)
                ) / math.pow(WIDTH, power)
            )
            i = i + 1
        end
    end
    for ____value in self.grid_rect:iter_xy() do
        local x = ____value[1]
        local y = ____value[2]
        local color = ((ys[x + 1] == y) and self.palette.FOREGROUND_COLOR) or self.palette.BACKGROUND_COLOR
        rc:pad(x, y, color)
    end
end
____exports.LayerLineSelect = __TS__Class()
local LayerLineSelect = ____exports.LayerLineSelect
LayerLineSelect.name = "LayerLineSelect"
__TS__ClassExtends(LayerLineSelect, ____exports.LayerLineSelectVertical)
return ____exports
