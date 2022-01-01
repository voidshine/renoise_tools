// Miscellaneous common definitions

export const MIDI = {
    // MIDI Spec
    NOTE_ON: 0x90,
    NOTE_OFF: 0x80,
    CONTROL_CHANGE: 0xB0,
    CHANNEL_PRESSURE: 0xD0,
    PITCH_BEND: 0xE0,

    // CC 1 is modulation wheel coarse adjust; CC 33 is modulation wheel fine adjust
    CC_MODULATION_WHEEL: 1,
    CC_MODULATION_WHEEL_FINE: 33,
};

export const RENOISE_MIDI = {
    // "C-0" is lowest usable note in Renoise
    NOTE_MIN: 0,

    // "C-10" is the first note NOT usable in Renoise, so maximum usable is one less: (10 * 12) - 1
    NOTE_MAX: 119,

    // Special "OFF" note_value
    NOTE_VALUE_OFF: 120,

    // Special "//-" empty note_value
    NOTE_VALUE_EMPTY: 121,


    VOLUME_MIN: 0,

    VOLUME_MAX: 0x7f,

    // Special value to indicate an empty volume_value on a note column.
    VOLUME_EMPTY: 255,

    is_in_note_range: (note: number) => (note >= 0 && note <= 119),
    clamp_note: (note: number) => (cLib.clamp_value(note, 0, 119)),
    clamp_note_conservative: (from: number, to: number) => (to < 0 || to > 119) ? from : to,
};

// Builds pitch bend midi message.
// bend is between -1.0 and 1.0
export function build_pitch_bend(bend: number) {
    // 0x2000 means wheel centered
    // Close enough to zero? Snap, so we don't leave any lingering pitch bend.
    // Else, compose a 14-bit integer to represent pitch bend wheel position.
    const wheel14 = (math.abs(bend) < 0.01) && 0x2000 || (0x2000 + cLib.round_value(0x1fff * bend))
    const low7 = bit.band(wheel14, 0x7f)
    const high7 = bit.band(bit.rshift(wheel14, 7), 0x7f)
    return [ MIDI.PITCH_BEND, low7, high7, ];
}

// Builds modulation wheel MIDI messages
// wheel is between 0.0 and 1.0
export function build_modulation_wheel_coarse(wheel: number) {
    const high7 = bit.band(bit.rshift(math.floor(wheel * 0x3fff), 7), 0x7f)
    return [ MIDI.CONTROL_CHANGE, MIDI.CC_MODULATION_WHEEL, high7, ];
}

export function build_modulation_wheel_fine(wheel: number) {
    const low7 = bit.band(math.floor(wheel * 0x3fff), 0x7f)
    return [ MIDI.CONTROL_CHANGE, MIDI.CC_MODULATION_WHEEL_FINE, low7, ];
}

export function no_op() {}
