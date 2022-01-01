--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____color = require("engine.color")
local Color = ____color.Color
local defs = require("engine.fire_defs")
local function midi_pad_start()
    return {240, 71, 127, 67, 101, 0, 0}
end
local function midi_pad(sysex, x, y, color)
    __TS__ArrayPush(sysex, (y * 16) + x)
    __TS__ArrayPush(
        sysex,
        bit.rshift(
            color:get(1),
            1
        )
    )
    __TS__ArrayPush(
        sysex,
        bit.rshift(
            color:get(2),
            1
        )
    )
    __TS__ArrayPush(
        sysex,
        bit.rshift(
            color:get(3),
            1
        )
    )
end
local function midi_pad_end(array)
    local payload_len = #array - 7
    if payload_len == 0 then
        return
    end
    array[6] = bit.rshift(payload_len, 7)
    array[7] = bit.band(payload_len, 127)
    __TS__ArrayPush(array, 247)
end
local function xy_index(x, y)
    return 1 + ((y * defs.FIRE_GRID_WIDTH) + x)
end
____exports.FireGridState = __TS__Class()
local FireGridState = ____exports.FireGridState
FireGridState.name = "FireGridState"
function FireGridState.prototype.____constructor(self, copy_from)
    if copy_from then
        self.colors = table.rcopy(copy_from.colors)
    else
        self.colors = {}
        do
            local y = 0
            while y < defs.FIRE_GRID_HEIGHT do
                do
                    local x = 0
                    while x < defs.FIRE_GRID_WIDTH do
                        self.colors[xy_index(x, y)] = Color:black()
                        x = x + 1
                    end
                end
                y = y + 1
            end
        end
    end
end
function FireGridState.prototype.clone(self)
    return __TS__New(____exports.FireGridState, self)
end
function FireGridState.prototype.__eq(self, rhs)
    for i = 1, defs.FIRE_GRID_WIDTH * defs.FIRE_GRID_HEIGHT do
        if self.colors[i] ~= rhs.colors[i] then
            return false
        end
    end
    return true
end
function FireGridState.prototype.at(self, x, y)
    return self.colors[xy_index(x, y)]
end
function FireGridState.prototype.clear(self)
    local black = Color:black()
    for color in __TS__Iterator(self.colors) do
        color:set_from(black)
    end
end
function FireGridState.prototype.get_sysex(self, grid_on_device)
    if self == grid_on_device then
        return nil
    end
    local sysex = midi_pad_start()
    do
        local y = 0
        while y < defs.FIRE_GRID_HEIGHT do
            do
                local x = 0
                while x < defs.FIRE_GRID_WIDTH do
                    local color = self:at(x, y)
                    if (grid_on_device == nil) or (grid_on_device:at(x, y) ~= color) then
                        midi_pad(sysex, x, y, color)
                    end
                    x = x + 1
                end
            end
            y = y + 1
        end
    end
    midi_pad_end(sysex)
    return sysex
end
return ____exports
