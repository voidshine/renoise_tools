--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____common = require("engine.common")
local MIDI = ____common.MIDI
local build_modulation_wheel_coarse = ____common.build_modulation_wheel_coarse
local build_modulation_wheel_fine = ____common.build_modulation_wheel_fine
local build_pitch_bend = ____common.build_pitch_bend
local ____utility = require("engine.utility")
local step_track_column = ____utility.step_track_column
local QUANTIZER_COOLDOWN = 1.5
____exports.KnobValue = __TS__Class()
local KnobValue = ____exports.KnobValue
KnobValue.name = "KnobValue"
function KnobValue.prototype.____constructor(self, display_name, default_value, min_value, max_value, sensitivity)
    self.display_name = display_name
    self.default_value = default_value
    self.min_value = min_value
    self.max_value = max_value
    self.sensitivity = sensitivity
    self._value = default_value
end
function KnobValue.prototype.display_text(self)
    return self.display_name
end
function KnobValue.prototype.on_change(self, new_value, old_value)
end
function KnobValue.prototype.on_press(self)
end
function KnobValue.prototype.on_release(self)
end
function KnobValue.prototype.on_turn(self, delta)
    self:set_value(
        self:get_value() + (delta * self.sensitivity)
    )
end
function KnobValue.prototype.get_value(self)
    return self._value
end
function KnobValue.prototype.set_value(self, value)
    local old_value = self:get_value()
    local new_value = cLib.clamp_value(value, self.min_value, self.max_value)
    if new_value ~= old_value then
        self._value = new_value
        self:on_change(new_value, old_value)
    end
end
____exports.KnobAutoReset = __TS__Class()
local KnobAutoReset = ____exports.KnobAutoReset
KnobAutoReset.name = "KnobAutoReset"
__TS__ClassExtends(KnobAutoReset, ____exports.KnobValue)
function KnobAutoReset.prototype.on_release(self)
    self:set_value(self.default_value)
end
____exports.KnobAlt = __TS__Class()
local KnobAlt = ____exports.KnobAlt
KnobAlt.name = "KnobAlt"
function KnobAlt.prototype.____constructor(self, source_model, knobs)
    self.display_name = tostring(
        table.concat(
            __TS__ArrayMap(
                knobs,
                function(____, knob) return knob.display_name end
            ),
            "|" or ","
        )
    )
    self.knobs = knobs
    self.target = knobs[1]
    self.source_model = source_model
end
function KnobAlt.prototype.display_text(self)
    self:select_target()
    return self.target:display_text()
end
function KnobAlt.prototype.index(self)
    local i = ((self.source_model.alt and 1) or 0) + ((self.source_model.shift and 2) or 0)
    return ((i < #self.knobs) and i) or 0
end
function KnobAlt.prototype.select_target(self)
    self.target = self.knobs[self:index() + 1]
end
function KnobAlt.prototype.on_press(self)
    self:select_target()
    self.target:on_press()
end
function KnobAlt.prototype.on_release(self)
    self:select_target()
    self.target:on_release()
end
function KnobAlt.prototype.on_turn(self, delta)
    self:select_target()
    self.target:on_turn(delta)
end
____exports.KnobLatch = __TS__Class()
local KnobLatch = ____exports.KnobLatch
KnobLatch.name = "KnobLatch"
__TS__ClassExtends(KnobLatch, ____exports.KnobAlt)
function KnobLatch.prototype.____constructor(self, knobs)
    local faux_model = {alt = false, shift = false}
    KnobLatch.____super.prototype.____constructor(self, faux_model, knobs)
end
function KnobLatch.prototype.cycle(self)
    self.source_model.alt = not self.source_model.alt
    local current = self.knobs[self:index() + 1]
    __TS__ArrayForEach(
        self.knobs,
        function(____, knob) return knob:on_toggled(knob == current) end
    )
end
____exports.KnobQuantizing = __TS__Class()
local KnobQuantizing = ____exports.KnobQuantizing
KnobQuantizing.name = "KnobQuantizing"
__TS__ClassExtends(KnobQuantizing, ____exports.KnobValue)
function KnobQuantizing.prototype.____constructor(self, display_name, sensitivity, quantum)
    KnobQuantizing.____super.prototype.____constructor(self, display_name, 0, -100, 100, sensitivity)
    self.quantum = quantum
    self.last_change_time = os.clock()
end
function KnobQuantizing.prototype.on_change(self, new_value, old_value)
    local last = self.last_change_time
    self.last_change_time = os.clock()
    if (self.last_change_time - last) > QUANTIZER_COOLDOWN then
        self._value = self._value - old_value
    end
    local steps = self._value - math.fmod(self._value, self.quantum)
    if steps ~= 0 then
        self:on_step(steps)
        self._value = self._value - steps
    end
end
function KnobQuantizing.prototype.on_step(self, steps)
end
____exports.KnobVelocity = __TS__Class()
local KnobVelocity = ____exports.KnobVelocity
KnobVelocity.name = "KnobVelocity"
__TS__ClassExtends(KnobVelocity, ____exports.KnobValue)
function KnobVelocity.prototype.____constructor(self)
    KnobVelocity.____super.prototype.____constructor(self, "Velocity", 64, 1, 127, 1)
end
____exports.KnobPitchWheel = __TS__Class()
local KnobPitchWheel = ____exports.KnobPitchWheel
KnobPitchWheel.name = "KnobPitchWheel"
__TS__ClassExtends(KnobPitchWheel, ____exports.KnobAutoReset)
function KnobPitchWheel.prototype.____constructor(self)
    KnobPitchWheel.____super.prototype.____constructor(self, "Pitch Wheel", 0, -1, 1, 0.02)
end
function KnobPitchWheel.prototype.on_change(self, new_value, old_value)
    driver.generated_midi:send_midi(
        build_pitch_bend(new_value)
    )
end
____exports.KnobModulationWheel = __TS__Class()
local KnobModulationWheel = ____exports.KnobModulationWheel
KnobModulationWheel.name = "KnobModulationWheel"
__TS__ClassExtends(KnobModulationWheel, ____exports.KnobAutoReset)
function KnobModulationWheel.prototype.____constructor(self)
    KnobModulationWheel.____super.prototype.____constructor(self, "Modulation Wheel", 0, 0, 1, 0.01)
end
function KnobModulationWheel.prototype.on_change(self, new_value, old_value)
    driver.generated_midi:send_midi(
        build_modulation_wheel_coarse(new_value)
    )
    driver.generated_midi:send_midi(
        build_modulation_wheel_fine(new_value)
    )
end
____exports.KnobChannelPressure = __TS__Class()
local KnobChannelPressure = ____exports.KnobChannelPressure
KnobChannelPressure.name = "KnobChannelPressure"
__TS__ClassExtends(KnobChannelPressure, ____exports.KnobAutoReset)
function KnobChannelPressure.prototype.____constructor(self)
    KnobChannelPressure.____super.prototype.____constructor(self, "Channel Pressure", 0, 0, 1, 0.03)
end
function KnobChannelPressure.prototype.on_change(self, new_value, old_value)
    driver.generated_midi:send_midi(
        {
            MIDI.CHANNEL_PRESSURE,
            math.floor(127 * new_value),
            0
        }
    )
end
____exports.KnobTime = __TS__Class()
local KnobTime = ____exports.KnobTime
KnobTime.name = "KnobTime"
__TS__ClassExtends(KnobTime, ____exports.KnobQuantizing)
function KnobTime.prototype.____constructor(self, sensitivity)
    KnobTime.____super.prototype.____constructor(
        self,
        "Time Select" .. tostring(
            ((sensitivity < driver.options:knob_sensitivity(false, false)) and "~") or ""
        ),
        sensitivity,
        1
    )
end
function KnobTime.prototype.on_step(self, steps)
    rns.selected_line_index = cLib.clamp_value((rns.selected_line_index - 1) + steps, 0, rns.selected_pattern.number_of_lines - 1) + 1
end
____exports.KnobColumnSelect = __TS__Class()
local KnobColumnSelect = ____exports.KnobColumnSelect
KnobColumnSelect.name = "KnobColumnSelect"
__TS__ClassExtends(KnobColumnSelect, ____exports.KnobQuantizing)
function KnobColumnSelect.prototype.____constructor(self, whole_tracks, note_columns, sensitivity)
    KnobColumnSelect.____super.prototype.____constructor(self, (whole_tracks and "Track Select") or "Column Select", sensitivity, 1)
    self.whole_tracks = whole_tracks
    self.note_columns = note_columns
end
function KnobColumnSelect.prototype.on_step(self, steps)
    step_track_column(steps, self.whole_tracks, false, self.note_columns)
end
____exports.KnobInstrumentSelect = __TS__Class()
local KnobInstrumentSelect = ____exports.KnobInstrumentSelect
KnobInstrumentSelect.name = "KnobInstrumentSelect"
__TS__ClassExtends(KnobInstrumentSelect, ____exports.KnobQuantizing)
function KnobInstrumentSelect.prototype.____constructor(self)
    KnobInstrumentSelect.____super.prototype.____constructor(
        self,
        "Instrument Select",
        driver.options:knob_sensitivity(false, true),
        1
    )
end
function KnobInstrumentSelect.prototype.on_step(self, steps)
    rns.selected_instrument_index = cLib.clamp_value((rns.selected_instrument_index - 1) + steps, 0, #rns.instruments - 1) + 1
end
____exports.KnobQuantizingClosure = __TS__Class()
local KnobQuantizingClosure = ____exports.KnobQuantizingClosure
KnobQuantizingClosure.name = "KnobQuantizingClosure"
__TS__ClassExtends(KnobQuantizingClosure, ____exports.KnobQuantizing)
function KnobQuantizingClosure.prototype.____constructor(self, name, sensitivity, handler)
    KnobQuantizingClosure.____super.prototype.____constructor(self, name, sensitivity, 1)
    self.handler = handler
end
function KnobQuantizingClosure.prototype.on_step(self, steps)
    self.handler(steps)
end
local SPACES = __TS__ArrayMap(
    {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16},
    function(____, i) return string.rep(" ", i) end
)
____exports.KnobQuantizedParameter = __TS__Class()
local KnobQuantizedParameter = ____exports.KnobQuantizedParameter
KnobQuantizedParameter.name = "KnobQuantizedParameter"
__TS__ClassExtends(KnobQuantizedParameter, ____exports.KnobQuantizing)
function KnobQuantizedParameter.prototype.____constructor(self, display_name, sensitivity, parameter)
    KnobQuantizedParameter.____super.prototype.____constructor(self, display_name, sensitivity, 1)
    self.parameter = parameter
end
function KnobQuantizedParameter.prototype.display_text(self)
    local label_text = KnobQuantizedParameter.____super.prototype.display_text(self)
    local parameter_text = self.parameter:get_text()
    local spaces = SPACES[(16 - (#label_text + #parameter_text)) + 1] or ":"
    return (tostring(label_text) .. tostring(spaces)) .. tostring(parameter_text)
end
function KnobQuantizedParameter.prototype.on_step(self, steps)
    self.parameter:set(
        cLib.clamp_value(
            self.parameter:get() + steps,
            self.parameter.min_value,
            self.parameter.max_value
        )
    )
end
return ____exports
