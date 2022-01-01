--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local ____color = require("engine.color")
local Color = ____color.Color
local ____draw = require("engine.draw")
local DrawClear = ____draw.DrawClear
local DrawText = ____draw.DrawText
local DrawBox = ____draw.DrawBox
local ____fire_led_state = require("engine.fire_led_state")
local FIRE_LED_WIDTH = ____fire_led_state.FIRE_LED_WIDTH
local FIRE_LED_RECT_FULL = ____fire_led_state.FIRE_LED_RECT_FULL
local ____pyre_native = require("pyre_native")
local PyreFonts = ____pyre_native.PyreFonts
local TEXT_CELL_HEIGHT = 13
____exports.RenderContext = __TS__Class()
local RenderContext = ____exports.RenderContext
RenderContext.name = "RenderContext"
function RenderContext.prototype.____constructor(self, state)
    self.state = state
end
function RenderContext.prototype.clear(self)
    self.state:clear()
end
function RenderContext.prototype.clear_grid(self, grid_rect)
    if grid_rect then
        local black = Color:black()
        for ____value in grid_rect:iter_xy() do
            local x = ____value[1]
            local y = ____value[2]
            self.state.grid:at(x, y):set_from(black)
        end
    else
        self.state.grid:clear()
    end
end
function RenderContext.prototype.pad(self, x, y, color)
    self.state.grid:at(x, y):set_from(color)
end
function RenderContext.prototype.light(self, light, color)
    self.state.lights[light]:set_from(color)
end
function RenderContext.prototype.quad_light_select(self, which)
    self.state.quad_light = which
end
function RenderContext.prototype.quad_light_bits(self, channel, mixer, user1, user2)
    self.state.quad_light = (((bit.lshift((channel and 1) or 0, 1) + bit.lshift((mixer and 1) or 0, 2)) + bit.lshift((user1 and 1) or 0, 3)) + bit.lshift((user2 and 1) or 0, 4)) + 16
end
function RenderContext.prototype.led_clear(self)
    __TS__ArrayPush(self.state.led_model.draw_commands, DrawClear.INSTANCE)
end
function RenderContext.prototype.led_box(self, rect, color_bit)
    __TS__ArrayPush(
        self.state.led_model.draw_commands,
        __TS__New(DrawBox, rect, color_bit)
    )
end
function RenderContext.prototype.led_text(self, row, text)
    local rect = ((row < 0) and FIRE_LED_RECT_FULL) or __TS__New(Rect, 0, row * TEXT_CELL_HEIGHT, FIRE_LED_WIDTH, TEXT_CELL_HEIGHT)
    __TS__ArrayPush(
        self.state.led_model.draw_commands,
        __TS__New(DrawText, PyreFonts.Megaman.handle, rect, text)
    )
end
function RenderContext.prototype.led_page(self, header, lines)
    local y = 0
    local rect = __TS__New(Rect, 0, y, FIRE_LED_WIDTH, 12)
    local step_rect
    step_rect = function(height)
        rect.top = y
        rect.height = height
        y = y + height
        return rect:clone()
    end
    local font = PyreFonts.FontTiny2
    __TS__ArrayPush(
        self.state.led_model.draw_commands,
        __TS__New(
            DrawText,
            font.handle,
            step_rect(font.height),
            header
        )
    )
    __TS__ArrayPush(
        self.state.led_model.draw_commands,
        __TS__New(
            DrawBox,
            step_rect(1),
            1
        )
    )
    step_rect(1)
    font = PyreFonts.MegamanMono
    __TS__ArrayForEach(
        lines,
        function(____, line, i)
            __TS__ArrayPush(
                self.state.led_model.draw_commands,
                __TS__New(
                    DrawText,
                    font.handle,
                    step_rect(font.height),
                    line
                )
            )
        end
    )
end
function RenderContext.prototype.led_line_parameter(self, row, normalized_value)
    local width = normalized_value * FIRE_LED_WIDTH
    local rect = __TS__New(Rect, 0, (row * TEXT_CELL_HEIGHT) + 13, width, 2)
    __TS__ArrayPush(
        self.state.led_model.draw_commands,
        __TS__New(DrawBox, rect, 1)
    )
end
function RenderContext.prototype.on_start(self)
    self:clear()
end
function RenderContext.prototype.on_finish(self)
end
return ____exports
