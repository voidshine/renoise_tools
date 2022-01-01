--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
function ____exports.rgb_to_hsv(rgb)
    local r = rgb[1] / 255
    local g = rgb[2] / 255
    local b = rgb[3] / 255
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h
    local s
    local v
    v = max
    local d = max - min
    if max == 0 then
        s = 0
    else
        s = d / max
    end
    if max == min then
        h = 0
    else
        if max == r then
            h = (g - b) / d
            if g < b then
                h = h + 6
            end
        elseif max == g then
            h = ((b - r) / d) + 2
        else
            h = ((r - g) / d) + 4
        end
        h = h / 6
    end
    return {h, s, v}
end
function ____exports.hsv_to_rgb(hsv)
    local h, s, v = hsv[1], hsv[2], hsv[3]
    local i = math.floor(h * 6) % 6
    local f = (h * 6) - i
    local p = v * (1 - s)
    local q = v * (1 - (f * s))
    local t = v * (1 - ((1 - f) * s))
    local r, g, b = unpack(((i == 0) and ({v, t, p})) or (((i == 1) and ({q, v, p})) or (((i == 2) and ({p, v, t})) or (((i == 3) and ({p, q, v})) or (((i == 4) and ({t, p, v})) or ({v, p, q}))))))
    return {
        math.floor(r * 255),
        math.floor(g * 255),
        math.floor(b * 255)
    }
end
____exports.Color = __TS__Class()
local Color = ____exports.Color
Color.name = "Color"
function Color.prototype.____constructor(self, rgb)
    self:set(1, rgb[1])
    self:set(2, rgb[2])
    self:set(3, rgb[3])
end
function Color.prototype.get(self, component)
    return self[component]
end
function Color.prototype.set(self, component, value)
    self[component] = value
end
function Color.prototype.__eq(self, rhs)
    return ((self:get(1) == rhs:get(1)) and (self:get(2) == rhs:get(2))) and (self:get(3) == rhs:get(3))
end
function Color.rgb(self, rgb)
    return __TS__New(____exports.Color, rgb)
end
function Color.hsv(self, hsv)
    return __TS__New(
        ____exports.Color,
        ____exports.hsv_to_rgb(hsv)
    )
end
function Color.black(self)
    return __TS__New(____exports.Color, {0, 0, 0})
end
function Color.white(self)
    return __TS__New(____exports.Color, {255, 255, 255})
end
function Color.gray(self, shade)
    return __TS__New(____exports.Color, {shade, shade, shade})
end
function Color.prototype.set_from(self, rhs)
    self:set(
        1,
        rhs:get(1)
    )
    self:set(
        2,
        rhs:get(2)
    )
    self:set(
        3,
        rhs:get(3)
    )
end
function Color.prototype.to_hsv(self)
    return ____exports.rgb_to_hsv(
        {
            self:get(1),
            self:get(2),
            self:get(3)
        }
    )
end
function Color.prototype.to_int(self)
    return ((self:get(1) * 65536) + (self:get(2) * 256)) + self:get(3)
end
function Color.prototype.with_hsv_value(self, value)
    local hsv = self:to_hsv()
    hsv[3] = value
    return ____exports.Color:hsv(hsv)
end
return ____exports
