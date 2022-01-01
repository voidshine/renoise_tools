--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local DRAW_CLEAR = 1
local DRAW_BOX = 2
local DRAW_TEXT = 3
____exports.DrawCommand = __TS__Class()
local DrawCommand = ____exports.DrawCommand
DrawCommand.name = "DrawCommand"
function DrawCommand.prototype.____constructor(self, kind)
    self.kind = kind
end
____exports.DrawClear = __TS__Class()
local DrawClear = ____exports.DrawClear
DrawClear.name = "DrawClear"
__TS__ClassExtends(DrawClear, ____exports.DrawCommand)
function DrawClear.prototype.____constructor(self)
    DrawClear.____super.prototype.____constructor(self, DRAW_CLEAR)
end
DrawClear.INSTANCE = __TS__New(____exports.DrawClear)
____exports.DrawBox = __TS__Class()
local DrawBox = ____exports.DrawBox
DrawBox.name = "DrawBox"
__TS__ClassExtends(DrawBox, ____exports.DrawCommand)
function DrawBox.prototype.____constructor(self, rect, color)
    DrawBox.____super.prototype.____constructor(self, DRAW_BOX)
    self.rect = rect
    self.color = color
end
____exports.DrawText = __TS__Class()
local DrawText = ____exports.DrawText
DrawText.name = "DrawText"
__TS__ClassExtends(DrawText, ____exports.DrawCommand)
function DrawText.prototype.____constructor(self, font, rect, text)
    DrawText.____super.prototype.____constructor(self, DRAW_TEXT)
    self.font = font
    self.rect = rect
    self.text = text
end
return ____exports
