--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____fire_defs = require("engine.fire_defs")
local FIRE_GRID_WIDTH = ____fire_defs.FIRE_GRID_WIDTH
local ____common = require("engine.common")
local RENOISE_MIDI = ____common.RENOISE_MIDI
local Pool = __TS__Class()
Pool.name = "Pool"
function Pool.prototype.____constructor(self, ctor, capacity)
    self.items = {}
    self.capacity = 0
    self.count = 0
    self.ctor = ctor
    self.capacity = capacity
    while capacity > 0 do
        __TS__ArrayPush(
            self.items,
            __TS__New(self.ctor)
        )
        capacity = capacity - 1
    end
end
function Pool.prototype.reset(self)
    self.count = 0
end
function Pool.prototype.take(self)
    if self.capacity <= self.count then
        print(
            "PUSH @ " .. tostring(self.ctor.name)
        )
        __TS__ArrayPush(
            self.items,
            __TS__New(self.ctor)
        )
        self.capacity = self.capacity + 1
    end
    self.count = self.count + 1
    return self.items[self.count]
end
____exports.DivisionSpec = __TS__Class()
local DivisionSpec = ____exports.DivisionSpec
DivisionSpec.name = "DivisionSpec"
function DivisionSpec.prototype.____constructor(self)
    self.step_count = 1
    self.pulse_count = 0
    self.time_base = 1
    self.delay = 0
    self.step_size = 1
    self.phase = 0
    self.velocity_index = 7
    self.velocity_delta_index = 7
    self.velocity_random = 0
    self.pitch = 60
    self.gate = 0
end
function DivisionSpec.prototype.is_occupied_at(self, x)
    assert((self.phase >= 0) and (self.phase < self.step_count))
    return (((x >= self.step_count) and (function() return false end)) or (function() return (((x * self.pulse_count) + self.phase) % self.step_count) < self.pulse_count end))()
end
function DivisionSpec.prototype.clean(self)
    assert(self.step_count > 0)
    self.pulse_count = cLib.clamp_value(self.pulse_count, 0, self.step_count)
    self.phase = cLib.clamp_value(self.phase, 0, self.step_count - 1)
end
local GenerationState = __TS__Class()
GenerationState.name = "GenerationState"
function GenerationState.prototype.____constructor(self)
    self.child_index = 0
    self.pitch = 0
    self.velocity = 0
    self.division = nil
end
function GenerationState.prototype.delta_velocity(self)
    return self.division.velocity_delta_index - 7
end
function GenerationState.prototype.set_from(self, division)
    self.division = division
    self.velocity = 64 + ((division.velocity_index - 7) * 8)
    self.pitch = division.pitch
end
function GenerationState.prototype.combine(self, parent, previous)
    self.child_index = (previous and (previous.child_index + 1)) or 0
    self.velocity = (parent.velocity + (self.velocity - 64)) + (parent:delta_velocity() * self.child_index)
    if parent.division.velocity_random > 0 then
        local range = parent.division.velocity_random * 4
        self.velocity = self.velocity + math.random(-range, range)
    end
end
function GenerationState.prototype.add_note(self, output, start_line)
    local d = self.division
    if d.gate > 0 then
        output:add_note(start_line + (d.delay * d.time_base), d.gate * d.time_base, self.pitch, self.velocity)
    end
end
local Step = __TS__Class()
Step.name = "Step"
function Step.prototype.____constructor(self)
    self.division = __TS__New(____exports.DivisionSpec)
    self.pulses = {}
end
function Step.prototype.apply_division_spec(self, division, level)
    if level == 0 then
        self.division = division
        while #self.pulses > division.pulse_count do
            table.remove(self.pulses)
        end
        while #self.pulses < division.pulse_count do
            __TS__ArrayPush(
                self.pulses,
                __TS__New(Step)
            )
        end
    else
        __TS__ArrayForEach(
            self.pulses,
            function(____, pulse)
                pulse:apply_division_spec(division, level - 1)
            end
        )
    end
end
function Step.prototype.generate(self, output, parent_state, previous_state, start_line, end_line)
    parent_state:add_note(output, start_line)
    local current_state = output:add_state(self.division)
    current_state:combine(parent_state, previous_state)
    if self.division.pulse_count > 0 then
        local step_size = self.division.time_base * self.division.step_size
        local pulse_index = 0
        local child_previous_state = nil
        do
            local i = 0
            while i < self.division.step_count do
                local child_start_line = start_line + (i * step_size)
                if child_start_line >= end_line then
                    break
                end
                if self.division:is_occupied_at(i) then
                    child_previous_state = self.pulses[pulse_index + 1]:generate(output, current_state, child_previous_state, child_start_line, end_line)
                    pulse_index = pulse_index + 1
                end
                i = i + 1
            end
        end
    end
    return current_state
end
local NoteEvent = __TS__Class()
NoteEvent.name = "NoteEvent"
function NoteEvent.prototype.____constructor(self)
    self.start = 0
    self.duration = 0
    self.pitch = 0
    self.velocity = 0
end
NoteEvent.prototype["end"] = function(self)
    return self.start + self.duration
end
____exports.TrackModel = __TS__Class()
local TrackModel = ____exports.TrackModel
TrackModel.name = "TrackModel"
function TrackModel.prototype.____constructor(self, track_name)
    self.is_dirty = true
    self.root = __TS__New(Step)
    self.division_specs = {}
    self.initial_division_spec = __TS__New(____exports.DivisionSpec)
    self.initial_parent_state = __TS__New(GenerationState)
    self.seed = math.random(100000)
    self.initial_parent_state:set_from(self.initial_division_spec)
    self.track_name = track_name
    __TS__ArrayPush(
        self.division_specs,
        __TS__New(____exports.DivisionSpec)
    )
    __TS__ArrayPush(
        self.division_specs,
        __TS__New(____exports.DivisionSpec)
    )
    __TS__ArrayPush(
        self.division_specs,
        __TS__New(____exports.DivisionSpec)
    )
    self.division_specs[1].pulse_count = 1
    self.division_specs[1].time_base = 16
    self.division_specs[2].pulse_count = 1
    self.division_specs[2].time_base = 4
    self.division_specs[3].pulse_count = 1
    self.division_specs[3].time_base = 1
    self.division_specs[3].gate = 1
    self:apply_division_specs()
end
function TrackModel.prototype.apply_division_specs(self)
    __TS__ArrayForEach(
        self.division_specs,
        function(____, division, i)
            self.root:apply_division_spec(division, i)
        end
    )
end
function TrackModel.prototype.fill_output(self, output, start_line, end_line)
    output:reset()
    math.randomseed(self.seed)
    self.root:generate(output, self.initial_parent_state, nil, start_line, end_line)
end
function TrackModel.prototype.write_to_track(self, reusable_output)
    local track_index = __TS__ArrayFindIndex(
        rns.tracks,
        function(____, t) return t.name == self.track_name end
    )
    if track_index < 0 then
        return false
    end
    local pattern = rns.selected_pattern
    local track = rns:track(track_index + 1)
    local pattern_track = pattern:track(track_index + 1)
    self:fill_output(reusable_output, 0, pattern.number_of_lines - 1)
    reusable_output:fill_track(pattern, track, pattern_track)
    return true
end
function TrackModel.prototype.print(self)
    print(
        lunajson.encode(self)
    )
end
____exports.DerivedTrackOutput = __TS__Class()
local DerivedTrackOutput = ____exports.DerivedTrackOutput
DerivedTrackOutput.name = "DerivedTrackOutput"
function DerivedTrackOutput.prototype.____constructor(self)
    self.note_pool = __TS__New(
        Pool,
        NoteEvent,
        math.pow(FIRE_GRID_WIDTH, 3)
    )
    self.state_pool = __TS__New(Pool, GenerationState, 512)
end
function DerivedTrackOutput.prototype.reset(self)
    self.note_pool:reset()
    self.state_pool:reset()
end
function DerivedTrackOutput.prototype.add_note(self, start, duration, pitch, velocity)
    local note = self.note_pool:take()
    note.start = start
    note.duration = duration
    note.pitch = pitch
    note.velocity = velocity
    return note
end
function DerivedTrackOutput.prototype.add_state(self, division)
    local state = self.state_pool:take()
    state:set_from(division)
    return state
end
function DerivedTrackOutput.prototype.fill_track(self, pattern, track, pattern_track)
    local lines = pattern_track.lines
    local first = lines[1]:note_column(0 + 1)
    local instrument = first.instrument_value
    if instrument == 255 then
        instrument = rns.selected_instrument_index - 1
    end
    pattern_track:clear()
    first.instrument_value = instrument
    local filled_until = {}
    do
        local i = 0
        while i < track.visible_note_columns do
            __TS__ArrayPush(filled_until, 0)
            i = i + 1
        end
    end
    local limit = pattern.number_of_lines
    local used_columns = 0
    do
        local i = 0
        while i < self.note_pool.count do
            local event = self.note_pool.items[i + 1]
            if event["end"](event) < limit then
                local column_index = __TS__ArrayFindIndex(
                    filled_until,
                    function(____, v) return v <= event.start end
                )
                if (column_index < 0) and (track.visible_note_columns >= 12) then
                    renoise.app():show_status("Warning! Max polyphony exceeded. Some note events are dropped.")
                else
                    if column_index < 0 then
                        track.visible_note_columns = track.visible_note_columns + 1
                        assert(track.visible_note_columns == (#filled_until + 1))
                        column_index = #filled_until
                        __TS__ArrayPush(filled_until, 0)
                    end
                    used_columns = math.max(used_columns, column_index + 1)
                    filled_until[column_index + 1] = event["end"](event) + 1
                    local column = lines[event.start + 1]:note_column(column_index + 1)
                    column.note_value = event.pitch
                    column.instrument_value = instrument
                    column.volume_value = cLib.clamp_value(event.velocity, 1, 127)
                    column = lines[event["end"](event) + 1]:note_column(column_index + 1)
                    column.note_value = RENOISE_MIDI.NOTE_VALUE_OFF
                end
            end
            i = i + 1
        end
    end
    track.visible_note_columns = math.max(1, used_columns)
    track.visible_effect_columns = 0
end
return ____exports
