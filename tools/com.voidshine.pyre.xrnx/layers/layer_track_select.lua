--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____palette = require("palette")
local PALETTE = ____palette.PALETTE
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local clock_pulse = ____utility.clock_pulse
local ____fire_defs = require("engine.fire_defs")
local FIRE_GRID_WIDTH = ____fire_defs.FIRE_GRID_WIDTH
local FIRE_GRID_HEIGHT = ____fire_defs.FIRE_GRID_HEIGHT
local FIRE_BUTTON = ____fire_defs.FIRE_BUTTON
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local ____color = require("engine.color")
local Color = ____color.Color
local palette = PALETTE.TRACK_SELECT
local ModelTrackSelect = __TS__Class()
ModelTrackSelect.name = "ModelTrackSelect"
__TS__ClassExtends(ModelTrackSelect, ModelLayer)
function ModelTrackSelect.prototype.____constructor(self, ...)
    ModelLayer.prototype.____constructor(self, ...)
    self.offset = 0
    self.track_colors = __TS__New(ModelLayer)
    self.track_mutes = __TS__New(ModelLayer)
    self.track_solos = __TS__New(ModelLayer)
    self.column_and_device_colors = __TS__New(ModelLayer)
end
function ModelTrackSelect.prototype.__eq(self, rhs)
    return ModelLayer.prototype.__eq(self, rhs)
end
____exports.LayerTrackSelect = __TS__Class()
local LayerTrackSelect = ____exports.LayerTrackSelect
LayerTrackSelect.name = "LayerTrackSelect"
__TS__ClassExtends(LayerTrackSelect, Layer)
function LayerTrackSelect.prototype.____constructor(self, grid_rect)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelTrackSelect),
        "Track Select"
    )
    self.grid_rect = grid_rect or __TS__New(Rect, 0, 0, FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT)
    local on_grid_pad
    on_grid_pad = function(x, y, velocity)
        if velocity then
            x = x + self.model.offset
            assert(((rns.sequencer_track_count + 1) + rns.send_track_count) == #rns.tracks)
            if (y < 3) and (x < #rns.tracks) then
                if y == 0 then
                    if x >= 0 then
                        rns.selected_track_index = x + 1
                    end
                elseif y == 1 then
                    local track = rns:track(x + 1)
                    if track and (track.type ~= renoise.Track.TRACK_TYPE_MASTER) then
                        track.mute_state = ((track.mute_state == renoise.Track.MUTE_STATE_ACTIVE) and renoise.Track.MUTE_STATE_MUTED) or renoise.Track.MUTE_STATE_ACTIVE
                    end
                elseif y == 2 then
                    local track = rns:track(x + 1)
                    if track and (track.type ~= renoise.Track.TRACK_TYPE_MASTER) then
                        track.solo_state = not track.solo_state
                    end
                end
            elseif y == 3 then
                if x < rns.selected_track.visible_note_columns then
                    rns.selected_note_column_index = x + 1
                else
                    x = x - rns.selected_track.visible_note_columns
                    if x < rns.selected_track.visible_effect_columns then
                        rns.selected_effect_column_index = x + 1
                    else
                        x = x - rns.selected_track.visible_effect_columns
                        if (x >= 0) and (x < #rns.selected_track.devices) then
                            rns.selected_track_device_index = x + 1
                        end
                    end
                end
            end
        end
    end
    self:set_note_handlers_grid_rect(self.grid_rect, on_grid_pad)
    self:set_note_on_handlers(
        {
            [FIRE_BUTTON.GridLeft] = function()
                self:on_press_grid_left_right(-1)
            end,
            [FIRE_BUTTON.GridRight] = function()
                self:on_press_grid_left_right(1)
            end
        }
    )
end
function LayerTrackSelect.prototype.width(self)
    return self.grid_rect.width
end
function LayerTrackSelect.prototype.on_press_grid_left_right(self, delta)
    local max = #rns.tracks - (#rns.tracks % self:width())
    self.model.offset = cLib.clamp_value(
        self.model.offset + (self:width() * delta),
        0,
        max
    )
end
function LayerTrackSelect.prototype.update_model(self, m)
    m.selected_track_index = rns.selected_track_index - 1
    m.selected_track_device_index = rns.selected_track_device_index - 1
    do
        local i = 0
        while i < self:width() do
            local track_index = i + m.offset
            local track = rns.tracks[track_index + 1]
            local color = (track and Color:rgb(track.color)) or palette.BACKGROUND
            if track_index == m.selected_track_index then
                local hsv = color:to_hsv()
                hsv[3] = hsv[3] * clock_pulse()
                color = Color:hsv(hsv)
            end
            m.track_colors[i] = color
            if track then
                m.track_mutes[i] = ((track.mute_state == renoise.Track.MUTE_STATE_ACTIVE) and palette.TRACK_ACTIVE) or (((track.mute_state == renoise.Track.MUTE_STATE_OFF) and palette.TRACK_OFF) or palette.TRACK_MUTE)
                m.track_solos[i] = (track.solo_state and palette.TRACK_SOLO_ON) or palette.TRACK_SOLO_OFF
            else
                m.track_mutes[i] = palette.BACKGROUND
                m.track_solos[i] = palette.BACKGROUND
            end
            i = i + 1
        end
    end
    local offset = 0
    do
        local i = 0
        while i < rns.selected_track.visible_note_columns do
            m.column_and_device_colors[i] = ((i == (rns.selected_note_column_index - 1)) and palette.NOTE_COLUMN_SELECTED) or palette.NOTE_COLUMN
            i = i + 1
        end
    end
    offset = offset + rns.selected_track.visible_note_columns
    do
        local i = 0
        while i < rns.selected_track.visible_effect_columns do
            m.column_and_device_colors[offset + i] = ((i == (rns.selected_effect_column_index - 1)) and palette.EFFECT_COLUMN_SELECTED) or palette.EFFECT_COLUMN
            i = i + 1
        end
    end
    offset = offset + rns.selected_track.visible_effect_columns
    do
        local i = 0
        while i < #rns.selected_track.devices do
            local color
            if i == m.selected_track_device_index then
                color = Color:white()
            else
                color = Color:gray(80)
            end
            m.column_and_device_colors[offset + i] = color
            i = i + 1
        end
    end
    offset = offset + #rns.selected_track.devices
    do
        local i = offset
        while i < self:width() do
            m.column_and_device_colors[i] = Color:black()
            i = i + 1
        end
    end
end
function LayerTrackSelect.prototype.render(self, rc, m)
    rc:clear_grid(self.grid_rect)
    do
        local i = 0
        while i < self:width() do
            local x = i + self.grid_rect.left
            local y = self.grid_rect.top
            rc:pad(x, y, m.track_colors[i])
            rc:pad(x, y + 1, m.track_mutes[i])
            rc:pad(x, y + 2, m.track_solos[i])
            rc:pad(x, y + 3, m.column_and_device_colors[i])
            i = i + 1
        end
    end
end
return ____exports
