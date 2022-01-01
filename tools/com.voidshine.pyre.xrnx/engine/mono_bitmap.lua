--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____utility = require("engine.utility")
local modulo_up = ____utility.modulo_up
local BITS_PER_ELEMENT = 32
local function isBitmap(maybe)
    return type(maybe) ~= "number"
end
____exports.MonoBitmap = __TS__Class()
local MonoBitmap = ____exports.MonoBitmap
MonoBitmap.name = "MonoBitmap"
function MonoBitmap.prototype.____constructor(self, width_or_copy_from, height)
    if isBitmap(width_or_copy_from) then
        self.width = width_or_copy_from.width
        self.height = width_or_copy_from.height
        self.bits = table.copy(width_or_copy_from.bits)
    else
        self.width = width_or_copy_from
        self.height = height
        self.bits = {}
        self:fill(0)
    end
end
function MonoBitmap.prototype.__eq(self, rhs)
end
function MonoBitmap.prototype.clone(self)
    return __TS__New(____exports.MonoBitmap, self)
end
function MonoBitmap.prototype.index_shift_at(self, x, y)
    local bit_index = (y * self.width) + x
    local shift = bit_index % BITS_PER_ELEMENT
    local element_index = (bit_index - shift) / BITS_PER_ELEMENT
    assert(((element_index * BITS_PER_ELEMENT) + shift) == bit_index, "numerical precision issues")
    return element_index, shift
end
function MonoBitmap.prototype.fill(self, color_bit)
    assert((color_bit == 0) or (color_bit == 1), "color_bit must be 0 or 1")
    local value = ((color_bit == 0) and 0) or bit.bnot(0)
    do
        local i = 0
        while i < (modulo_up(self.width * self.height, BITS_PER_ELEMENT) / BITS_PER_ELEMENT) do
            self.bits[i + 1] = value
            i = i + 1
        end
    end
end
function MonoBitmap.prototype.get(self, x, y)
    local index, shift = self:index_shift_at(x, y)
    return bit.band(
        bit.rshift(self.bits[index + 1], shift),
        1
    )
end
function MonoBitmap.prototype.set(self, x, y, color_bit)
    assert((color_bit == 0) or (color_bit == 1), "color_bit must be 0 or 1")
    local index, shift = self:index_shift_at(x, y)
    local mask = bit.lshift(1, shift)
    local was = self.bits[index + 1]
    if color_bit == 0 then
        self.bits[index + 1] = bit.band(
            was,
            bit.bnot(mask)
        )
    else
        self.bits[index + 1] = bit.bor(was, mask)
    end
    return self.bits[index + 1] ~= was
end
return ____exports
