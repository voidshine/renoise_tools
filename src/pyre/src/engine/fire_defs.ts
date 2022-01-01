import { Color } from './color';

// global Fire constants
export const FIRE_KNOB_COUNT = 5;   // Includes Select at right.
export const FIRE_GRID_WIDTH = 16;
export const FIRE_GRID_HEIGHT = 4;

export const FIRE_GRID_TOP_LEFT_NOTE = 54

// These buttons send note-on/off events
export const FIRE_BUTTON = {
    // Just a button, no one associated light
    ChannelMixerUserButton: 26,

    // These 'buttons' press when knob is touched, and depress when knob is released.
    KnobVolume: 16,
    KnobPan: 17,
    KnobFilter: 18,
    KnobResonance: 19,
    KnobSelect: 25,

    PatternUp: 31,
    PatternDown: 32,
    Browser: 33,
    GridLeft: 34,
    GridRight: 35,

    RowMute0: 36,
    RowMute1: 37,
    RowMute2: 38,
    RowMute3: 39,

    Step: 44,
    Note: 45,
    Drum: 46,
    Perform: 47,
    Shift: 48,
    Alt: 49,
    PatternSongMetronome: 50,
    PlayWait: 51,
    Stop: 52,
    Record: 53,
}

// 0 -> Channel, 1 -> Mixer, 2 -> User1, 3 -> User2
// Or... if (high nibble is nonzero) { low nibble indicates bit pattern to show
export const FIRE_CHANNEL_MIXER_USER_LIGHTS = 27

// Control Change codes for output to lights
export const FIRE_LIGHT = {
    // Off, dark red, bright red
    PatternUp: 31,
    PatternDown: 32,
    Browser: 33,
    GridLeft: 34,
    GridRight: 35,

    // Off, dark green, bright green
    RowMute0: 36,
    RowMute1: 37,
    RowMute2: 38,
    RowMute3: 39,

    // Off, dark green, dark red, bright green, bright red
    RowSelect0: 40,
    RowSelect1: 41,
    RowSelect2: 42,
    RowSelect3: 43,

    // Off, dark red, dark orange, bright red, bright orange
    Step: 44,
    Note: 45,
    Drum: 46,
    Perform: 47,
    Shift: 48,

    // Off, dark orange, bright orange
    Alt: 49,

    // Off, dark green, dark orange, bright green, bright orange
    PatternSongMetronome: 50,
    PlayWait: 51,

    // Off, dark orange, bright orange
    Stop: 52,

    // Off, dark red, dark orange, bright red, bright orange
    Record: 53,
}

// Use these exact color values to specify lights; otherwise you get simple black/off or other/on logic.
// TODO: Ideally these should be accurate; just rough hacks for now.
export const LIGHT_OFF = Color.black()
export const LIGHT_DARK_RED = Color.rgb([32, 0, 0])
export const LIGHT_BRIGHT_RED = Color.rgb([180, 0, 0])
export const LIGHT_DARK_ORANGE = Color.rgb([32, 24, 0])
export const LIGHT_BRIGHT_ORANGE = Color.rgb([180, 120, 0])
export const LIGHT_DARK_GREEN = Color.rgb([0, 32, 0])
export const LIGHT_BRIGHT_GREEN = Color.rgb([0, 180, 0])

function build_color_to_index(colors: Color[]) {
    const lookup: number[] = [];
    colors.forEach((color, i) => {
        // The Fire device uses indexes starting from zero.
        //lookup[color.to_int()] = i - 1;
        lookup[color.to_int()] = i;
    });
    return lookup;
}

const color_to_index_lookups = [
    build_color_to_index([ LIGHT_OFF, LIGHT_DARK_RED, LIGHT_BRIGHT_RED ]),
    build_color_to_index([ LIGHT_OFF, LIGHT_DARK_GREEN, LIGHT_BRIGHT_GREEN ]),

    //build_color_to_index([ LIGHT_OFF, LIGHT_DARK_GREEN, LIGHT_DARK_RED, LIGHT_BRIGHT_GREEN, LIGHT_BRIGHT_RED ]),
    build_color_to_index([ LIGHT_OFF, LIGHT_DARK_RED, LIGHT_DARK_GREEN, LIGHT_BRIGHT_RED, LIGHT_BRIGHT_GREEN ]),

    build_color_to_index([ LIGHT_OFF, LIGHT_DARK_RED, LIGHT_DARK_ORANGE, LIGHT_BRIGHT_RED, LIGHT_BRIGHT_ORANGE ]),
    build_color_to_index([ LIGHT_OFF, LIGHT_DARK_ORANGE, LIGHT_BRIGHT_ORANGE ]),
    build_color_to_index([ LIGHT_OFF, LIGHT_DARK_GREEN, LIGHT_DARK_ORANGE, LIGHT_BRIGHT_GREEN, LIGHT_BRIGHT_ORANGE ]),
];

const FIRE_LIGHT_TO_COLOR_INDEX_LOOKUP = {
    // Off, dark red, bright red
    [FIRE_LIGHT.PatternUp]: color_to_index_lookups[0],
    [FIRE_LIGHT.PatternDown]: color_to_index_lookups[0],
    [FIRE_LIGHT.Browser]: color_to_index_lookups[0],
    [FIRE_LIGHT.GridLeft]: color_to_index_lookups[0],
    [FIRE_LIGHT.GridRight]: color_to_index_lookups[0],

    // Off, dark green, bright green
    [FIRE_LIGHT.RowMute0]: color_to_index_lookups[1],
    [FIRE_LIGHT.RowMute1]: color_to_index_lookups[1],
    [FIRE_LIGHT.RowMute2]: color_to_index_lookups[1],
    [FIRE_LIGHT.RowMute3]: color_to_index_lookups[1],

    // Off, dark green, dark red, bright green, bright red
    [FIRE_LIGHT.RowSelect0]: color_to_index_lookups[2],
    [FIRE_LIGHT.RowSelect1]: color_to_index_lookups[2],
    [FIRE_LIGHT.RowSelect2]: color_to_index_lookups[2],
    [FIRE_LIGHT.RowSelect3]: color_to_index_lookups[2],

    // Off, dark red, dark orange, bright red, bright orange
    [FIRE_LIGHT.Step]: color_to_index_lookups[3],
    [FIRE_LIGHT.Note]: color_to_index_lookups[3],
    [FIRE_LIGHT.Drum]: color_to_index_lookups[3],
    [FIRE_LIGHT.Perform]: color_to_index_lookups[3],
    [FIRE_LIGHT.Shift]: color_to_index_lookups[3],

    // Off, dark orange, bright orange
    [FIRE_LIGHT.Alt]: color_to_index_lookups[4],

    // Off, dark green, dark orange, bright green, bright orange
    [FIRE_LIGHT.PatternSongMetronome]: color_to_index_lookups[5],
    [FIRE_LIGHT.PlayWait]: color_to_index_lookups[5],

    // Off, dark orange, bright orange
    [FIRE_LIGHT.Stop]: color_to_index_lookups[4],

    // Off, dark red, dark orange, bright red, bright orange
    [FIRE_LIGHT.Record]: color_to_index_lookups[3],
}

export const FIRE_KNOB = {
    // Control change codes
    // CC value 1 -> Turned clockwise; 127 -> Turned counterclockwise
    Volume: 16,
    Pan: 17,
    Filter: 18,
    Resonance: 19,
    Select: 118,
}

// map from knobs to buttons that trigger on touch/press or release
export const FIRE_KNOB_TO_BUTTON = {
    [FIRE_KNOB.Volume]: FIRE_BUTTON.KnobVolume,
    [FIRE_KNOB.Pan]: FIRE_BUTTON.KnobPan,
    [FIRE_KNOB.Filter]: FIRE_BUTTON.KnobFilter,
    [FIRE_KNOB.Resonance]: FIRE_BUTTON.KnobResonance,
    [FIRE_KNOB.Select]: FIRE_BUTTON.KnobSelect,
}

// map from buttons to lights
export const FIRE_BUTTON_TO_LIGHT = {
    [FIRE_BUTTON.ChannelMixerUserButton]: FIRE_CHANNEL_MIXER_USER_LIGHTS, // FIRE_LIGHT.ChannelMixerUserLights,
    [FIRE_BUTTON.KnobVolume]: null,
    [FIRE_BUTTON.KnobPan]: null,
    [FIRE_BUTTON.KnobFilter]: null,
    [FIRE_BUTTON.KnobResonance]: null,
    [FIRE_BUTTON.KnobSelect]: null,
    [FIRE_BUTTON.PatternUp]: FIRE_LIGHT.PatternUp,
    [FIRE_BUTTON.PatternDown]: FIRE_LIGHT.PatternDown,
    [FIRE_BUTTON.Browser]: FIRE_LIGHT.Browser,
    [FIRE_BUTTON.GridLeft]: FIRE_LIGHT.GridLeft,
    [FIRE_BUTTON.GridRight]: FIRE_LIGHT.GridRight,
    [FIRE_BUTTON.RowMute0]: FIRE_LIGHT.RowMute0,
    [FIRE_BUTTON.RowMute1]: FIRE_LIGHT.RowMute1,
    [FIRE_BUTTON.RowMute2]: FIRE_LIGHT.RowMute2,
    [FIRE_BUTTON.RowMute3]: FIRE_LIGHT.RowMute3,
    [FIRE_BUTTON.Step]: FIRE_LIGHT.Step,
    [FIRE_BUTTON.Note]: FIRE_LIGHT.Note,
    [FIRE_BUTTON.Drum]: FIRE_LIGHT.Drum,
    [FIRE_BUTTON.Perform]: FIRE_LIGHT.Perform,
    [FIRE_BUTTON.Shift]: FIRE_LIGHT.Shift,
    [FIRE_BUTTON.Alt]: FIRE_LIGHT.Alt,
    [FIRE_BUTTON.PatternSongMetronome]: FIRE_LIGHT.PatternSongMetronome,
    [FIRE_BUTTON.PlayWait]: FIRE_LIGHT.PlayWait,
    [FIRE_BUTTON.Stop]: FIRE_LIGHT.Stop,
    [FIRE_BUTTON.Record]: FIRE_LIGHT.Record,
}

export function grid_xy_to_midi_note(x: number, y: number): number {
    return FIRE_GRID_TOP_LEFT_NOTE + y * FIRE_GRID_WIDTH + x;
}

/** @tupleReturn */
export function grid_midi_note_to_xy(note: number): [number, number] {
    const index = note - FIRE_GRID_TOP_LEFT_NOTE;
    return [math.fmod(index, 16), math.floor(index / 16)];
}

// Applies for all singular lights (see get_midi_quad_light for upper-left group of connected lights)
export function get_midi_light(light: number, color: Color) {
    const color_index = FIRE_LIGHT_TO_COLOR_INDEX_LOOKUP[light][color.to_int()] || ((color == Color.black()) ? 0 : 1);
    // TRACE(color_index, color)
    return [176, light, color_index];
}

// quad_light is spec for the four linked lights at top left: channel, mixer, user1, user2
// 0 -> Channel, 1 -> Mixer, 2 -> User1, 3 -> User2
// Or... if (high nibble is nonzero) { low nibble indicates bit pattern to show
export function get_midi_quad_light(quad_light: number) {
    return [ 176, FIRE_CHANNEL_MIXER_USER_LIGHTS, quad_light ];
}
