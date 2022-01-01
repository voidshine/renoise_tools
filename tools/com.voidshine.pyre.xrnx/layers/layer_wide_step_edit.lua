--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer_common = require("layers.layer_common")
local LayerCommon = ____layer_common.LayerCommon
local ModelCommon = ____layer_common.ModelCommon
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local clock_pulse = ____utility.clock_pulse
local table_clear = ____utility.table_clear
local defs = require("engine.fire_defs")
local ____palette = require("palette")
local PALETTE = ____palette.PALETTE
local ____common = require("engine.common")
local RENOISE_MIDI = ____common.RENOISE_MIDI
local ____knob = require("engine.knob")
local KnobTime = ____knob.KnobTime
local KnobAlt = ____knob.KnobAlt
local KnobQuantizingClosure = ____knob.KnobQuantizingClosure
local palette = PALETTE.WIDE_STEP_EDIT
local PULSE_RATE_SELECTED = 2.5
local ModelWideStepEdit = __TS__Class()
ModelWideStepEdit.name = "ModelWideStepEdit"
__TS__ClassExtends(ModelWideStepEdit, ModelCommon)
function ModelWideStepEdit.prototype.____constructor(self, ...)
    ModelCommon.prototype.____constructor(self, ...)
    self.steps_per_page = 16
    self.lines_per_step = 1
    self.view_start_step = 0
    self.cursor_line = -1
    self.selection_step_offsets = __TS__New(ModelLayer)
    self.page_colors = __TS__New(ModelLayer)
    self.note_colors = __TS__New(ModelLayer)
end
function ModelWideStepEdit.prototype.__eq(self, rhs)
    return ModelCommon.prototype.__eq(self, rhs)
end
function ModelWideStepEdit.prototype.view_page(self)
    return math.floor(self.view_start_step / self.steps_per_page)
end
function ModelWideStepEdit.prototype.cursor_step(self)
    return math.floor(self.cursor_line / self.lines_per_step)
end
function ModelWideStepEdit.prototype.cursor_page(self)
    return math.floor(
        self:cursor_step() / self.steps_per_page
    )
end
function ModelWideStepEdit.prototype.cursor_step_in_page(self)
    return self:cursor_step() % self.steps_per_page
end
function ModelWideStepEdit.prototype.is_step_selected(self, at)
    return self.selection_step_offsets[at - self:cursor_step()] == true
end
function ModelWideStepEdit.prototype.line_offset(self)
    return self.cursor_line % self.lines_per_step
end
function ModelWideStepEdit.prototype.adjust_line_offset(self, delta)
    local new_line_offset = cLib.clamp_value(
        self:line_offset() + delta,
        0,
        self.lines_per_step - 1
    )
    local cursor_line = (self:cursor_step() * self.lines_per_step) + new_line_offset
    if (cursor_line >= 0) and (cursor_line < rns.selected_pattern.number_of_lines) then
        rns.selected_line_index = cursor_line + 1
    end
end
function ModelWideStepEdit.prototype.step_line(self, step)
    return (step * self.lines_per_step) + self:line_offset()
end
____exports.LayerWideStepEdit = __TS__Class()
local LayerWideStepEdit = ____exports.LayerWideStepEdit
LayerWideStepEdit.name = "LayerWideStepEdit"
__TS__ClassExtends(LayerWideStepEdit, LayerCommon)
function LayerWideStepEdit.prototype.____constructor(self)
    LayerCommon.prototype.____constructor(
        self,
        __TS__New(ModelWideStepEdit),
        "Wide Step Edit"
    )
    self.navigation_rect = __TS__New(Rect, 0, 0, defs.FIRE_GRID_WIDTH, 2)
    self.on_page_hold_count = 0
    self.model.selection_step_offsets[0] = true
    self:set_note_handlers_grid_rect(
        self.navigation_rect,
        function(x, y, velocity)
            if velocity then
                if y == 0 then
                    local step_in_page = self.model:cursor_step_in_page()
                    self:set_view_start(x * self.model.steps_per_page)
                    self:move_to(self.model.view_start_step + step_in_page)
                else
                    if self.model.shift or (self.on_page_hold_count > 0) then
                        local offset = (self.model.view_start_step + x) - self.model:cursor_step()
                        self.model.selection_step_offsets[offset] = ((self.model.selection_step_offsets[offset] and (function() return nil end)) or (function() return true end))()
                    elseif self.model.alt then
                        self:move_to(self.model.view_start_step + x)
                        table_clear(self.model.selection_step_offsets)
                        self.model.selection_step_offsets[0] = true
                    else
                        self:move_to(self.model.view_start_step + x)
                    end
                    self.on_page_hold_count = self.on_page_hold_count + 1
                end
            else
                if y == 1 then
                    self.on_page_hold_count = self.on_page_hold_count - 1
                end
            end
        end
    )
    local ____self = self
    self.edit_knobs = {
        __TS__New(
            KnobAlt,
            self.model,
            {
                __TS__New(
                    KnobTime,
                    driver.options:knob_sensitivity(false, false)
                ),
                __TS__New(
                    KnobTime,
                    driver.options:knob_sensitivity(true, false)
                )
            }
        ),
        __TS__New(
            KnobAlt,
            self.model,
            {
                __TS__New(
                    KnobQuantizingClosure,
                    "Line Offset",
                    driver.options:knob_sensitivity(false, true),
                    function(delta)
                        ____self.model:adjust_line_offset(delta)
                        renoise.app():show_status(
                            "Line Offset: " .. tostring(
                                ____self.model:line_offset()
                            )
                        )
                    end
                ),
                __TS__New(
                    KnobQuantizingClosure,
                    "Lines per Step",
                    driver.options:knob_sensitivity(false, true),
                    function(delta)
                        ____self.model.lines_per_step = cLib.clamp_value(____self.model.lines_per_step + delta, 1, rns.selected_pattern.number_of_lines)
                        renoise.app():show_status(
                            "Lines per Step: " .. tostring(____self.model.lines_per_step)
                        )
                    end
                ),
                __TS__New(
                    KnobQuantizingClosure,
                    "Steps per Page",
                    driver.options:knob_sensitivity(false, true),
                    function(delta)
                        ____self.model.steps_per_page = cLib.clamp_value(____self.model.steps_per_page + delta, 1, self.navigation_rect.width)
                        renoise.app():show_status(
                            "Steps per Page: " .. tostring(____self.model.steps_per_page)
                        )
                    end
                )
            }
        ),
        __TS__New(
            KnobQuantizingClosure,
            "Note Pitches +/-",
            driver.options:knob_sensitivity(false, true),
            function(delta) return ____self:adjust_selected_steps(
                function(step, line, note_column)
                    if note_column and RENOISE_MIDI.is_in_note_range(note_column.note_value) then
                        if ____self.model.alt then
                            delta = delta * 12
                        elseif ____self.model.shift then
                            delta = delta * 7
                        end
                        note_column.note_value = RENOISE_MIDI.clamp_note_conservative(note_column.note_value, note_column.note_value + delta)
                    end
                end
            ) end
        ),
        __TS__New(
            KnobQuantizingClosure,
            "Note Volumes +/-",
            driver.options:knob_sensitivity(false, false),
            function(delta) return ____self:adjust_selected_steps(
                function(step, line, note_column)
                    if note_column then
                        local value = note_column.volume_value
                        if value == RENOISE_MIDI.VOLUME_EMPTY then
                            value = rns.transport.keyboard_velocity
                        end
                        note_column.volume_value = cLib.clamp_value(value + delta, RENOISE_MIDI.VOLUME_MIN, RENOISE_MIDI.VOLUME_MAX)
                    end
                end
            ) end
        ),
        nil
    }
end
function LayerWideStepEdit.prototype.adjust_selected_steps(self, edit)
    for offset, _ in pairs(self.model.selection_step_offsets) do
        local step = self.model:cursor_step() + offset
        self:adjust_step(step, edit)
    end
end
function LayerWideStepEdit.prototype.adjust_step(self, step, edit)
    if (not rns.transport.edit_mode) or ((rns.selected_note_column_index - 1) < 0) then
        return
    end
    local line_index = self.model:step_line(step)
    if (line_index >= 0) and (line_index < rns.selected_pattern.number_of_lines) then
        local pattern_track = rns.selected_pattern_track
        local line = pattern_track:line(line_index + 1)
        local note_column = line:note_column((rns.selected_note_column_index - 1) + 1)
        edit(step, line, note_column)
    end
end
function LayerWideStepEdit.prototype.adjust_step_note(self, step, from_note, note)
    self:adjust_step(
        step,
        function(step, line, note_column)
            if note_column then
                if (RENOISE_MIDI.is_in_note_range(from_note) and RENOISE_MIDI.is_in_note_range(note_column.note_value)) and RENOISE_MIDI.is_in_note_range(note) then
                    local to = (note_column.note_value + note) - from_note
                    if RENOISE_MIDI.is_in_note_range(to) then
                        note_column.note_value = to
                    end
                else
                    note_column.note_value = note
                    if note == RENOISE_MIDI.NOTE_VALUE_EMPTY then
                        note_column:clear()
                    end
                end
            end
        end
    )
end
function LayerWideStepEdit.prototype.note_at_step(self, step)
    if (rns.selected_note_column_index - 1) < 0 then
        return RENOISE_MIDI.NOTE_VALUE_EMPTY
    end
    return rns.selected_pattern_track:line(
        self.model:step_line(step) + 1
    ):note_column((rns.selected_note_column_index - 1) + 1).note_value
end
function LayerWideStepEdit.prototype.on_note(self, note, velocity)
    local from_note = self:note_at_step(
        self.model:cursor_step()
    )
    for offset, _ in pairs(self.model.selection_step_offsets) do
        local step = self.model:cursor_step() + offset
        self:adjust_step_note(step, from_note, note)
    end
    return false
end
function LayerWideStepEdit.prototype.move_to(self, step)
    local line_index = self.model:step_line(step)
    if (line_index >= 0) and (line_index < rns.selected_pattern.number_of_lines) then
        self.model.cursor_line = line_index
        rns.selected_line_index = line_index + 1
    end
end
function LayerWideStepEdit.prototype.set_view_start(self, start_step)
    self.model.view_start_step = start_step
end
function LayerWideStepEdit.prototype.update_model(self, m)
    m.cursor_line = rns.selected_line_index - 1
    if rns.transport.follow_player then
        if (m:cursor_step() < m.view_start_step) or (m:cursor_step() >= (m.view_start_step + m.steps_per_page)) then
            self:set_view_start(
                m.steps_per_page * math.floor(
                    m:cursor_step() / m.steps_per_page
                )
            )
        end
    end
    local pattern_track = rns.selected_pattern_track
    local lines = pattern_track.lines
    local note_column_index = rns.selected_note_column_index - 1
    local view_page = m:view_page()
    do
        local page = 0
        while page < self.navigation_rect.width do
            local page_color = palette.BACKGROUND_VOID
            if ((page * m.steps_per_page) * m.lines_per_step) < #lines then
                page_color = palette.BACKGROUND_EMPTY
                if page == view_page then
                    do
                        local step_in_page = 0
                        while step_in_page < self.navigation_rect.width do
                            if step_in_page < m.steps_per_page then
                                local step = (page * m.steps_per_page) + step_in_page
                                local line = m:step_line(step)
                                if line >= #lines then
                                    break
                                end
                                local note = ((note_column_index >= 0) and lines[line + 1]:note_column(note_column_index + 1).note_value) or RENOISE_MIDI.NOTE_VALUE_EMPTY
                                m.note_colors[step_in_page + 1] = ((note == RENOISE_MIDI.NOTE_VALUE_OFF) and palette.NOTE_OFF) or (((note == RENOISE_MIDI.NOTE_VALUE_EMPTY) and palette.BACKGROUND_EMPTY) or driver.song_data:note_color(note))
                                if step == m:cursor_step() then
                                    if m:is_step_selected(step) then
                                        m.note_colors[step_in_page + 1] = m.note_colors[step_in_page + 1]:with_hsv_value(
                                            clock_pulse(PULSE_RATE_SELECTED)
                                        )
                                    else
                                        m.note_colors[step_in_page + 1] = m.note_colors[step_in_page + 1]:with_hsv_value(
                                            clock_pulse()
                                        )
                                    end
                                elseif m:is_step_selected(step) then
                                    m.note_colors[step_in_page + 1] = m.note_colors[step_in_page + 1]:with_hsv_value(
                                        clock_pulse(PULSE_RATE_SELECTED) / 5
                                    )
                                end
                            else
                                m.note_colors[step_in_page + 1] = palette.BACKGROUND_VOID
                            end
                            step_in_page = step_in_page + 1
                        end
                    end
                else
                    do
                        local step_in_page = 0
                        while step_in_page < m.steps_per_page do
                            local step = (page * m.steps_per_page) + step_in_page
                            local line = m:step_line(step)
                            if line >= #lines then
                                break
                            end
                            local note = ((note_column_index >= 0) and lines[line + 1]:note_column(note_column_index + 1).note_value) or RENOISE_MIDI.NOTE_VALUE_EMPTY
                            if (page_color == palette.BACKGROUND_EMPTY) and RENOISE_MIDI.is_in_note_range(note) then
                                page_color = driver.song_data:note_color(note)
                            end
                            step_in_page = step_in_page + 1
                        end
                    end
                end
            end
            if view_page == page then
                page_color = page_color:with_hsv_value(
                    clock_pulse() % 1
                )
            end
            m.page_colors[page + 1] = page_color
            page = page + 1
        end
    end
end
function LayerWideStepEdit.prototype.render(self, rc, m)
    rc:clear_grid(self.navigation_rect)
    do
        local x = self.navigation_rect.left
        while x < self.navigation_rect:right() do
            rc:pad(x, 0, m.page_colors[x + 1] or palette.BACKGROUND_VOID)
            x = x + 1
        end
    end
    do
        local x = self.navigation_rect.left
        while x < self.navigation_rect:right() do
            rc:pad(x, 1, m.note_colors[x + 1] or palette.BACKGROUND_VOID)
            x = x + 1
        end
    end
end
return ____exports
