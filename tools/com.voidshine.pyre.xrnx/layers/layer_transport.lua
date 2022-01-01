--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer_common = require("layers.layer_common")
local LayerCommon = ____layer_common.LayerCommon
local ModelCommon = ____layer_common.ModelCommon
local defs = require("engine.fire_defs")
local ____palette = require("palette")
local PALETTE = ____palette.PALETTE
local palette = PALETTE.TRANSPORT
local ModelTransport = __TS__Class()
ModelTransport.name = "ModelTransport"
__TS__ClassExtends(ModelTransport, ModelCommon)
function ModelTransport.prototype.____constructor(self, ...)
    ModelCommon.prototype.____constructor(self, ...)
    self.playing = false
    self.edit_mode = false
    self.can_redo = false
end
function ModelTransport.prototype.__eq(self, rhs)
    return ModelCommon.prototype.__eq(self, rhs)
end
____exports.LayerTransport = __TS__Class()
local LayerTransport = ____exports.LayerTransport
LayerTransport.name = "LayerTransport"
__TS__ClassExtends(LayerTransport, LayerCommon)
function LayerTransport.prototype.____constructor(self)
    LayerCommon.prototype.____constructor(
        self,
        __TS__New(ModelTransport),
        "Transport"
    )
    self:set_note_on_handlers(
        {
            [defs.FIRE_BUTTON.PatternSongMetronome] = function(_note, _velocity)
                self:on_press_pattern()
            end,
            [defs.FIRE_BUTTON.Record] = self.on_press_record,
            [defs.FIRE_BUTTON.Stop] = self.on_press_stop,
            [defs.FIRE_BUTTON.PlayWait] = self.on_press_play
        }
    )
end
function LayerTransport.prototype.on_idle(self)
    self.model.playing = rns.transport.playing
    self.model.edit_mode = rns.transport.edit_mode
    self.model.can_redo = rns:can_redo()
end
function LayerTransport.prototype.render(self, rc, m)
    LayerCommon.prototype.render(self, rc, m)
    rc:light(defs.FIRE_LIGHT.PatternSongMetronome, (m.can_redo and palette.CAN_REDO) or palette.UNDO_ONLY)
    rc:light(defs.FIRE_LIGHT.Record, (m.edit_mode and palette.EDIT_MODE) or palette.OFF)
    rc:light(defs.FIRE_LIGHT.PlayWait, ((not m.playing) and palette.PLAYING) or palette.OFF)
    rc:light(defs.FIRE_LIGHT.Stop, (m.playing and palette.STOP) or palette.OFF)
end
function LayerTransport.prototype.on_press_record(self)
    rns.transport.edit_mode = not rns.transport.edit_mode
end
function LayerTransport.prototype.on_press_stop(self)
    local playing = rns.transport.playing
    rns.transport:stop()
    if not playing then
    end
end
function LayerTransport.prototype.on_press_play(self)
    rns.transport:start(renoise.Transport.PLAYMODE_RESTART_PATTERN)
end
function LayerTransport.prototype.on_press_pattern(self)
    if self.model.shift then
        rns:redo()
    else
        rns:undo()
    end
end
return ____exports
