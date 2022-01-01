--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
require("external.xLib")
local ____palette = require("palette")
local PALETTE = ____palette.PALETTE
local ____common = require("engine.common")
local RENOISE_MIDI = ____common.RENOISE_MIDI
local ____color = require("engine.color")
local Color = ____color.Color
local ____layer_common = require("layers.layer_common")
local LayerCommon = ____layer_common.LayerCommon
local ModelCommon = ____layer_common.ModelCommon
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local ____fire_defs = require("engine.fire_defs")
local FIRE_GRID_WIDTH = ____fire_defs.FIRE_GRID_WIDTH
local FIRE_GRID_HEIGHT = ____fire_defs.FIRE_GRID_HEIGHT
local FIRE_BUTTON = ____fire_defs.FIRE_BUTTON
local grid_xy_to_midi_note = ____fire_defs.grid_xy_to_midi_note
local FIRE_LIGHT = ____fire_defs.FIRE_LIGHT
local LIGHT_BRIGHT_GREEN = ____fire_defs.LIGHT_BRIGHT_GREEN
local LIGHT_DARK_GREEN = ____fire_defs.LIGHT_DARK_GREEN
local LIGHT_DARK_RED = ____fire_defs.LIGHT_DARK_RED
local LIGHT_OFF = ____fire_defs.LIGHT_OFF
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local ____menu = require("engine.menu")
local MenuItem = ____menu.MenuItem
local palette = PALETTE.NOTE_GRID
local function map_general(base, x_pattern, y_pattern, x, y)
    local nx = #x_pattern - 1
    local ny = #y_pattern - 1
    return (((base + (math.floor(y / ny) * y_pattern[ny + 1])) + y_pattern[(y % ny) + 1]) + (math.floor(x / nx) * x_pattern[nx + 1])) + x_pattern[(x % nx) + 1]
end
local map_note
map_note = map_general
local function note_color(m, note)
    if note == m.marked_note then
        return palette.MARKED_NOTE
    elseif m.note_to_count[note] then
        return (m.edit_mode and palette.NOTE_ON_WITH_EDIT) or palette.NOTE_ON_WITHOUT_EDIT
    elseif (note < RENOISE_MIDI.NOTE_MIN) or (note > RENOISE_MIDI.NOTE_MAX) then
        return palette.OUT_OF_BOUNDS
    elseif __TS__ArrayIncludes(m.cursor_notes, note) then
        if m.selected_column_note == note then
            return driver.song_data:note_color(note):with_hsv_value(1)
        else
            return driver.song_data:note_color(note):with_hsv_value(0.6)
        end
    elseif (note % 12) == 0 then
        return driver.song_data:note_color(note)
    else
        return driver.song_data:note_color(note)
    end
end
local ModelNoteGrid = __TS__Class()
ModelNoteGrid.name = "ModelNoteGrid"
__TS__ClassExtends(ModelNoteGrid, ModelCommon)
function ModelNoteGrid.prototype.____constructor(self, ...)
    ModelCommon.prototype.____constructor(self, ...)
    self.top_left_note = 0
    self.note_to_count = __TS__New(ModelLayer)
    self.edit_mode = false
    self.track_color = Color:white()
    self.marked_note = 1000
    self.cursor_notes = __TS__New(ModelLayer)
    self.selected_column_note = RENOISE_MIDI.NOTE_VALUE_EMPTY
end
function ModelNoteGrid.prototype.__eq(self, rhs)
    return ModelCommon.prototype.__eq(self, rhs)
end
____exports.LayerNoteGrid = __TS__Class()
local LayerNoteGrid = ____exports.LayerNoteGrid
LayerNoteGrid.name = "LayerNoteGrid"
__TS__ClassExtends(LayerNoteGrid, LayerCommon)
function LayerNoteGrid.prototype.____constructor(self, name, grid_rect, map_velocity, note_handler)
    LayerCommon.prototype.____constructor(
        self,
        __TS__New(ModelNoteGrid),
        name
    )
    self.grid_to_note = {}
    self.invalid = false
    self.grid_rect = grid_rect or __TS__New(Rect, 0, 0, FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT)
    self.note_grid_rect = self.grid_rect:sub_rect(1, 0, self.grid_rect.width - 1, self.grid_rect.height)
    self.map_velocity = map_velocity
    self.note_handler = function(note, velocity)
        if note_handler then
            if not note_handler(note, velocity) then
                return
            end
        end
        if velocity then
            driver.generated_midi:send_note_on(note, velocity)
        else
            driver.generated_midi:send_note_off(note)
        end
    end
    self:set_note_handlers_grid_rect(
        self.note_grid_rect,
        function(x, y, velocity)
            if velocity then
                local note = map_note(self.model.top_left_note, self.layout.x_pattern, self.layout.y_pattern, x, y)
                if (note >= 0) and (note <= 255) then
                    self.grid_to_note[(y * FIRE_GRID_WIDTH) + x] = note
                    velocity = self.map_velocity(velocity)
                    self.model.note_to_count[note] = (self.model.note_to_count[note] or 0) + 1
                    if self.model.note_to_count[note] == 1 then
                        self.note_handler(note, velocity)
                    end
                end
            else
                local note = self.grid_to_note[(y * FIRE_GRID_WIDTH) + x]
                if note ~= nil then
                    self.model.note_to_count[note] = (self.model.note_to_count[note] or 1) - 1
                    if self.model.note_to_count[note] == 0 then
                        self.model.note_to_count[note] = nil
                        self.note_handler(note, velocity)
                    end
                end
            end
        end
    )
    self:set_note_on_handlers(
        {
            [FIRE_BUTTON.RowMute0] = function()
                self:transpose((self.model.shift and 2) or 24)
            end,
            [FIRE_BUTTON.RowMute1] = function()
                self:transpose((self.model.shift and 1) or 12)
            end,
            [FIRE_BUTTON.RowMute2] = function()
                self:transpose((self.model.shift and -1) or -12)
            end,
            [FIRE_BUTTON.RowMute3] = function()
                self:transpose((self.model.shift and -2) or -24)
            end,
            [FIRE_BUTTON.GridLeft] = function()
                xColumns.previous_note_column(true, false)
            end,
            [FIRE_BUTTON.GridRight] = function()
                xColumns.next_note_column(true, false)
            end,
            [grid_xy_to_midi_note(
                self.grid_rect.left,
                self.grid_rect:bottom() - 2
            )] = function()
                if (not note_handler) or (note_handler(RENOISE_MIDI.NOTE_VALUE_OFF, 0) == true) then
                    if rns.transport.edit_mode then
                        local note_column = rns.selected_note_column
                        if note_column then
                            note_column.note_value = RENOISE_MIDI.NOTE_VALUE_OFF
                        end
                    end
                end
            end,
            [grid_xy_to_midi_note(
                self.grid_rect.left,
                self.grid_rect:bottom() - 1
            )] = function()
                if (not note_handler) or note_handler(RENOISE_MIDI.NOTE_VALUE_EMPTY, 0) then
                    if rns.transport.edit_mode then
                        local note_column = rns.selected_note_column
                        if note_column then
                            note_column.note_value = RENOISE_MIDI.NOTE_VALUE_EMPTY
                        end
                    end
                end
            end
        }
    )
    self:apply_layout()
    self:transpose(0)
end
function LayerNoteGrid.prototype.apply_layout(self)
    self.layout = driver.song_data:create_or_get_track_note_layout(self.name, rns.selected_track.name)
    self.model.top_left_note = self.layout.origin_note
end
function LayerNoteGrid.prototype.build_menu(self, item)
    __TS__ArrayPush(
        item.items,
        __TS__New(
            MenuItem,
            "Note Grid Layout for current Track",
            __TS__ArrayMap(
                driver.options.config.note_grid_layouts,
                function(____, layout) return __TS__New(
                    MenuItem,
                    layout.name,
                    {},
                    function()
                        driver.song_data:get_track_data(rns.selected_track.name).layer_note_layouts[self.name] = driver.song_data:clone_note_layout(layout)
                        self:invalidate()
                    end
                ) end
            )
        )
    )
    __TS__ArrayPush(
        item.items,
        __TS__New(
            MenuItem,
            ("Note Grid Layout Default for '" .. tostring(self.name)) .. "'",
            __TS__ArrayMap(
                driver.options.config.note_grid_layouts,
                function(____, layout) return __TS__New(
                    MenuItem,
                    layout.name,
                    {},
                    function()
                        if driver.options.config.default_note_layouts_by_layer[self.name] ~= layout.name then
                            driver.options.config.default_note_layouts_by_layer[self.name] = layout.name
                            driver.options:save_config()
                            self:invalidate()
                        end
                    end
                ) end
            )
        )
    )
end
function LayerNoteGrid.prototype.invalidate(self)
    LayerCommon.prototype.invalidate(self)
    self.invalid = true
end
function LayerNoteGrid.prototype.on_track_changed(self)
    self:invalidate()
end
function LayerNoteGrid.prototype.on_mount(self)
    LayerCommon.prototype.on_mount(self)
    rns.selected_track_observable:add_notifier(self.on_track_changed, self)
end
function LayerNoteGrid.prototype.on_unmount(self)
    LayerCommon.prototype.on_unmount(self)
    rns.selected_track_observable:remove_notifier(self.on_track_changed, self)
    self:all_off()
end
function LayerNoteGrid.prototype.all_off(self)
    for k in pairs(self.model.note_to_count) do
        osc_renoise_send_note_off(k)
        self.model.note_to_count[k] = nil
    end
    for k in pairs(self.grid_to_note) do
        self.grid_to_note[k] = nil
    end
end
function LayerNoteGrid.prototype.transpose(self, delta)
    self:all_off()
    local layout = driver.song_data:create_or_get_track_note_layout(self.name, rns.selected_track.name)
    layout.origin_note = RENOISE_MIDI.clamp_note_conservative(self.model.top_left_note, self.model.top_left_note + delta)
    self.model.top_left_note = layout.origin_note
end
function LayerNoteGrid.prototype.update_model(self, m)
    if self.invalid then
        self.invalid = false
        self:apply_layout()
    end
    m.edit_mode = rns.transport.edit_mode
    m.track_color = Color:rgb(rns.selected_track.color)
    local columns = rns.selected_line.note_columns
    local ____ = rns.selected_note_column_index - 1
    __TS__ArrayForEach(
        columns,
        function(____, note_column, i)
            m.cursor_notes[i + 1] = note_column.note_value
            if i == (rns.selected_note_column_index - 1) then
                m.selected_column_note = note_column.note_value
            end
        end
    )
    __TS__ArraySetLength(m.cursor_notes, #columns)
end
function LayerNoteGrid.prototype.render(self, rc, m)
    LayerCommon.prototype.render(self, rc, m)
    for ____value in self.note_grid_rect:iter_xy() do
        local x = ____value[1]
        local y = ____value[2]
        local note = map_note(m.top_left_note, self.layout.x_pattern, self.layout.y_pattern, x - self.note_grid_rect.left, y - self.note_grid_rect.top)
        local color = note_color(m, note)
        rc:pad(x, y, color)
    end
    local x = self.grid_rect.left
    local y = self.grid_rect:bottom() - 1
    rc:pad(x, y, palette.NOTE_VALUE_EMPTY)
    rc:pad(x, y - 1, palette.NOTE_VALUE_OFF)
    if self.note_grid_rect.height > 2 then
        rc:pad(
            x,
            y - 2,
            Color:black()
        )
        rc:pad(
            x,
            y - 3,
            Color:black()
        )
    end
    rc:light(FIRE_LIGHT.RowMute0, LIGHT_BRIGHT_GREEN)
    rc:light(FIRE_LIGHT.RowMute1, LIGHT_DARK_GREEN)
    rc:light(FIRE_LIGHT.RowMute2, LIGHT_DARK_GREEN)
    rc:light(FIRE_LIGHT.RowMute3, LIGHT_BRIGHT_GREEN)
    rc:light(FIRE_LIGHT.GridLeft, LIGHT_DARK_RED)
    rc:light(FIRE_LIGHT.GridRight, LIGHT_DARK_RED)
    rc:light(FIRE_LIGHT.RowSelect0, LIGHT_OFF)
    rc:light(FIRE_LIGHT.RowSelect1, LIGHT_OFF)
    rc:light(FIRE_LIGHT.RowSelect2, LIGHT_OFF)
    rc:light(FIRE_LIGHT.RowSelect3, LIGHT_OFF)
    local octave_index = math.floor((m.top_left_note - 24) / 12)
    if (octave_index >= 0) and (octave_index < 8) then
        rc:light(
            (FIRE_LIGHT.RowSelect0 + 3) - math.floor(octave_index / 2),
            ((bit.band(octave_index, 1) > 0) and LIGHT_BRIGHT_GREEN) or LIGHT_DARK_GREEN
        )
    end
end
return ____exports
