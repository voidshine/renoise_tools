--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
____exports.MIDI = {NOTE_ON = 144, NOTE_OFF = 128, CONTROL_CHANGE = 176, CHANNEL_PRESSURE = 208, PITCH_BEND = 224, CC_MODULATION_WHEEL = 1, CC_MODULATION_WHEEL_FINE = 33}
____exports.RENOISE_MIDI = {
    NOTE_MIN = 0,
    NOTE_MAX = 119,
    NOTE_VALUE_OFF = 120,
    NOTE_VALUE_EMPTY = 121,
    VOLUME_MIN = 0,
    VOLUME_MAX = 127,
    VOLUME_EMPTY = 255,
    is_in_note_range = function(note) return (note >= 0) and (note <= 119) end,
    clamp_note = function(note) return cLib.clamp_value(note, 0, 119) end,
    clamp_note_conservative = function(from, to) return (((to < 0) or (to > 119)) and from) or to end
}
function ____exports.build_pitch_bend(bend)
    local wheel14 = ((math.abs(bend) < 0.01) and 8192) or (8192 + cLib.round_value(8191 * bend))
    local low7 = bit.band(wheel14, 127)
    local high7 = bit.band(
        bit.rshift(wheel14, 7),
        127
    )
    return {____exports.MIDI.PITCH_BEND, low7, high7}
end
function ____exports.build_modulation_wheel_coarse(wheel)
    local high7 = bit.band(
        bit.rshift(
            math.floor(wheel * 16383),
            7
        ),
        127
    )
    return {____exports.MIDI.CONTROL_CHANGE, ____exports.MIDI.CC_MODULATION_WHEEL, high7}
end
function ____exports.build_modulation_wheel_fine(wheel)
    local low7 = bit.band(
        math.floor(wheel * 16383),
        127
    )
    return {____exports.MIDI.CONTROL_CHANGE, ____exports.MIDI.CC_MODULATION_WHEEL_FINE, low7}
end
function ____exports.no_op()
end
return ____exports
