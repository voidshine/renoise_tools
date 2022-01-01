--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____mono_bitmap = require("engine.mono_bitmap")
local MonoBitmap = ____mono_bitmap.MonoBitmap
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local modulo_down = ____utility.modulo_down
local modulo_up = ____utility.modulo_up
____exports.FIRE_LED_WIDTH = 128
____exports.FIRE_LED_HEIGHT = 64
____exports.FIRE_LED_RECT_FULL = __TS__New(Rect, 0, 0, ____exports.FIRE_LED_WIDTH, ____exports.FIRE_LED_HEIGHT)
local RECT_CLEAR = __TS__New(Rect, 0, 0, 0, 0)
local LedSegmentBitmap = __TS__Class()
LedSegmentBitmap.name = "LedSegmentBitmap"
function LedSegmentBitmap.prototype.____constructor(self, source_rect)
    local top = modulo_down(source_rect.top, 8)
    local bottom = modulo_up(
        source_rect:bottom(),
        8
    )
    assert(((bottom - top) % 8) == 0)
    self.rect = __TS__New(Rect, source_rect.left, top, source_rect.width, bottom - top)
    assert(self.rect.height >= 8, "sending update for empty source_rect will not change device state")
    self.bits_size = modulo_up(
        self.rect:area(),
        7
    ) / 7
    self.bits = {}
    do
        local i = 0
        while i < self.bits_size do
            self.bits[i + 1] = 0
            i = i + 1
        end
    end
end
function LedSegmentBitmap.prototype.set_pixel(self, x, y, color_bit)
    assert((color_bit == 0) or (color_bit == 1))
    assert(
        self.rect:size():contains_xy(x, y)
    )
    local segment = modulo_down(y, 8) / 8
    local bit_index = ((self.rect.width * 8) * segment) + ((x * 8) + (7 - (y % 8)))
    local byte_index = modulo_down(bit_index, 7) / 7
    local shift = 6 - (bit_index % 7)
    local mask = bit.lshift(1, shift)
    if color_bit == 1 then
        self.bits[byte_index + 1] = bit.bor(self.bits[byte_index + 1], mask)
    else
        self.bits[byte_index + 1] = bit.band(
            self.bits[byte_index + 1],
            bit.bnot(mask)
        )
    end
end
function LedSegmentBitmap.prototype.fill_from(self, bitmap)
    local top_left = self.rect:pos()
    for pos in self.rect:size():iter_range() do
        self:set_pixel(
            pos.x,
            pos.y,
            bitmap:get(pos.x + top_left.x, pos.y + top_left.y)
        )
    end
end
function LedSegmentBitmap.prototype.build_sysex(self)
    local data = {240, 71, 127, 67, 14}
    local add
    add = function(e)
        __TS__ArrayPush(data, e)
    end
    local length = self.bits_size + 4
    add(
        bit.band(
            bit.rshift(length, 7),
            127
        )
    )
    add(
        bit.band(length, 127)
    )
    add(self.rect.top / 8)
    add(
        (self.rect:bottom() / 8) - 1
    )
    add(self.rect.left)
    add(
        self.rect:right() - 1
    )
    __TS__ArrayForEach(
        self.bits,
        function(____, b, _)
            add(b)
        end
    )
    add(247)
    return data
end
____exports.FireLedState = __TS__Class()
local FireLedState = ____exports.FireLedState
FireLedState.name = "FireLedState"
function FireLedState.prototype.____constructor(self, copy_from)
    if copy_from then
        self.bitmap = copy_from.bitmap:clone()
        self.dirty_bounds = copy_from.dirty_bounds:clone()
    else
        self.bitmap = __TS__New(MonoBitmap, ____exports.FIRE_LED_WIDTH, ____exports.FIRE_LED_HEIGHT)
        self.dirty_bounds = ____exports.FIRE_LED_RECT_FULL:clone()
    end
end
function FireLedState.prototype.clone(self)
    return __TS__New(____exports.FireLedState, self)
end
function FireLedState.prototype.clear(self)
    self:dirty_rect(____exports.FIRE_LED_RECT_FULL)
    self.bitmap:fill(0)
end
function FireLedState.prototype.set_pixel(self, x, y, color_bit)
    if self.bitmap:set(x, y, color_bit) then
        self:dirty_xy(x, y)
    end
end
function FireLedState.prototype.dirty_xy(self, x, y)
    self.dirty_bounds:include_xy(x, y)
end
function FireLedState.prototype.dirty_rect(self, rect)
    self:dirty_xy(rect.left, rect.top)
    self:dirty_xy(
        rect:right() - 1,
        rect:bottom() - 1
    )
end
function FireLedState.prototype.get_sysex(self)
    if self.dirty_bounds:area() == 0 then
        return nil
    else
        local segment_bitmap = __TS__New(LedSegmentBitmap, self.dirty_bounds)
        segment_bitmap:fill_from(self.bitmap)
        self.dirty_bounds:set(RECT_CLEAR)
        return segment_bitmap:build_sysex()
    end
end
return ____exports
