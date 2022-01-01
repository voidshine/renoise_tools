import { Color } from './engine/color';
import * as defs from './engine/fire_defs'; // Includes some specific light colors LIGHT_*

// All fixed colors come from here. Dynamics like track colors should be the only
// other colors presented.
export const PALETTE = {
    COMMON: {
        OFF: defs.LIGHT_OFF,
        MODIFIER_PRESSED: defs.LIGHT_DARK_ORANGE,
    },

    TRANSPORT: {
        OFF: Color.black(),
        UNDO_ONLY: defs.LIGHT_DARK_ORANGE,
        CAN_REDO: defs.LIGHT_BRIGHT_ORANGE,
        EDIT_MODE: defs.LIGHT_DARK_RED,
        PLAYING: defs.LIGHT_DARK_GREEN,
        STOP: defs.LIGHT_DARK_ORANGE,
    },

    NOTE_GRID: {
        OUT_OF_BOUNDS: Color.gray(12),
        NOTE_VALUE_OFF: Color.rgb([16, 0, 0]),
        NOTE_VALUE_EMPTY: Color.rgb([96, 48, 48]),
        NOTE_ON_WITH_EDIT: Color.rgb([255, 0, 0]),
        NOTE_ON_WITHOUT_EDIT: Color.white(),
        MARKED_NOTE: Color.white(),
        CURSOR_NOTE: Color.gray(30),
        CURSOR_NOTE_IN_SELECTED_COLUMN: Color.gray(150),
    },

    TRACK_SELECT: {
        BACKGROUND: Color.black(),
        TRACK_ACTIVE: Color.hsv([0.65, 0.65, 0.3]),
        TRACK_OFF: Color.hsv([0.65, 0.9, 1.0]),
        TRACK_MUTE: Color.hsv([0.65, 1.0, 1.0]),
        TRACK_SOLO_ON: Color.hsv([0.2, 1.0, 1.0]),
        TRACK_SOLO_OFF: Color.hsv([0.2, 0.65, 0.3]),
        NOTE_COLUMN: Color.hsv([0.1, 0.7, 0.3]),
        NOTE_COLUMN_SELECTED: Color.hsv([0.15, 0.6, 1.0]),
        EFFECT_COLUMN: Color.hsv([0.35, 0.6, 0.3]),
        EFFECT_COLUMN_SELECTED: Color.hsv([0.35, 0.7, 1.0]),
    },

    // For edit cursor position
    LINE_SELECT: {
        BACKGROUND_COLOR: Color.hsv([0.152, 0.25, 0.10]),
        FOREGROUND_COLOR: Color.hsv([0.152, 0.65, 0.95]),
    },

    // For selection bounds
    // LINE_SELECT_BEGIN: {
    //     BACKGROUND_Color. Color.hsv([0.3, 0.25, 0.1]),
    //     FOREGROUND_Color. Color.hsv([0.3, 0.9, 0.9]),
    // },
    // LINE_SELECT_BEGIN_INACTIVE: {
    //     BACKGROUND_Color. Color.hsv([0.3, 0.25, 0.1]),
    //     FOREGROUND_Color. Color.hsv([0.3, 0.5, 0.4]),
    // },
    // LINE_SELECT_END: {
    //     BACKGROUND_Color. Color.hsv([0.0, 0.25, 0.1]),
    //     FOREGROUND_Color. Color.hsv([0.0, 0.9, 0.85]),
    // },
    // LINE_SELECT_END_INACTIVE: {
    //     BACKGROUND_Color. Color.hsv([0.0, 0.25, 0.1]),
    //     FOREGROUND_Color. Color.hsv([0.0, 0.5, 0.35]),
    // },

    STEP_EDIT: {
        BACKGROUND: Color.black(),
        COPY: Color.hsv([0.73, 0.8, 0.8]),
        PASTE: Color.hsv([0.85, 0.8, 0.8]),
        DESELECT: Color.gray(180),
        SELECT_START: Color.hsv([0.43, 0.8, 0.8]),
        SELECT_END: Color.hsv([0.78, 0.8, 0.8]),
        CONTRACT_SELECTION_WIDTH: Color.hsv([0.4, 0.8, 0.75]),
        EXPAND_SELECTION_WIDTH: Color.hsv([0.2, 0.8, 0.75]),
    },

    WIDE_STEP_EDIT: {
        BACKGROUND_VOID: Color.black(),
        BACKGROUND_EMPTY: Color.gray(32),
        OCCUPIED_PAGE: Color.hsv([0.1, 0.3, 0.3]),
        NOTE: Color.hsv([0.1, 0.8, 0.75]),
        NOTE_OFF: Color.hsv([0, 1, 0.05]),
        // CURSOR: Color.hsv([0.0777, 0, 1.0]),
    },

    GENERATE_EUCLIDEAN: {
        BACKGROUND: Color.black(),
        OCCUPIED_STEP: Color.hsv([0.6, 0.7, 1.0]),// Color.white(),
        UNOCCUPIED_STEP: Color.hsv([0, 0.3, 0.5]), // Color.gray(64),

        LAYER_UNSELECTED: defs.LIGHT_OFF,
        LAYER_SELECTED: defs.LIGHT_BRIGHT_GREEN,

        KNOB_SET_SELECTED: Color.gray(200),
        KNOB_SET_UNSELECTED: Color.gray(40),
    },
}

// TODO: Support load/save with checking and metatable setup.
