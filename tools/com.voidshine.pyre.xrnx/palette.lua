--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____color = require("engine.color")
local Color = ____color.Color
local defs = require("engine.fire_defs")
____exports.PALETTE = {
    COMMON = {OFF = defs.LIGHT_OFF, MODIFIER_PRESSED = defs.LIGHT_DARK_ORANGE},
    TRANSPORT = {
        OFF = Color:black(),
        UNDO_ONLY = defs.LIGHT_DARK_ORANGE,
        CAN_REDO = defs.LIGHT_BRIGHT_ORANGE,
        EDIT_MODE = defs.LIGHT_DARK_RED,
        PLAYING = defs.LIGHT_DARK_GREEN,
        STOP = defs.LIGHT_DARK_ORANGE
    },
    NOTE_GRID = {
        OUT_OF_BOUNDS = Color:gray(12),
        NOTE_VALUE_OFF = Color:rgb({16, 0, 0}),
        NOTE_VALUE_EMPTY = Color:rgb({96, 48, 48}),
        NOTE_ON_WITH_EDIT = Color:rgb({255, 0, 0}),
        NOTE_ON_WITHOUT_EDIT = Color:white(),
        MARKED_NOTE = Color:white(),
        CURSOR_NOTE = Color:gray(30),
        CURSOR_NOTE_IN_SELECTED_COLUMN = Color:gray(150)
    },
    TRACK_SELECT = {
        BACKGROUND = Color:black(),
        TRACK_ACTIVE = Color:hsv({0.65, 0.65, 0.3}),
        TRACK_OFF = Color:hsv({0.65, 0.9, 1}),
        TRACK_MUTE = Color:hsv({0.65, 1, 1}),
        TRACK_SOLO_ON = Color:hsv({0.2, 1, 1}),
        TRACK_SOLO_OFF = Color:hsv({0.2, 0.65, 0.3}),
        NOTE_COLUMN = Color:hsv({0.1, 0.7, 0.3}),
        NOTE_COLUMN_SELECTED = Color:hsv({0.15, 0.6, 1}),
        EFFECT_COLUMN = Color:hsv({0.35, 0.6, 0.3}),
        EFFECT_COLUMN_SELECTED = Color:hsv({0.35, 0.7, 1})
    },
    LINE_SELECT = {
        BACKGROUND_COLOR = Color:hsv({0.152, 0.25, 0.1}),
        FOREGROUND_COLOR = Color:hsv({0.152, 0.65, 0.95})
    },
    STEP_EDIT = {
        BACKGROUND = Color:black(),
        COPY = Color:hsv({0.73, 0.8, 0.8}),
        PASTE = Color:hsv({0.85, 0.8, 0.8}),
        DESELECT = Color:gray(180),
        SELECT_START = Color:hsv({0.43, 0.8, 0.8}),
        SELECT_END = Color:hsv({0.78, 0.8, 0.8}),
        CONTRACT_SELECTION_WIDTH = Color:hsv({0.4, 0.8, 0.75}),
        EXPAND_SELECTION_WIDTH = Color:hsv({0.2, 0.8, 0.75})
    },
    WIDE_STEP_EDIT = {
        BACKGROUND_VOID = Color:black(),
        BACKGROUND_EMPTY = Color:gray(32),
        OCCUPIED_PAGE = Color:hsv({0.1, 0.3, 0.3}),
        NOTE = Color:hsv({0.1, 0.8, 0.75}),
        NOTE_OFF = Color:hsv({0, 1, 0.05})
    },
    GENERATE_EUCLIDEAN = {
        BACKGROUND = Color:black(),
        OCCUPIED_STEP = Color:hsv({0.6, 0.7, 1}),
        UNOCCUPIED_STEP = Color:hsv({0, 0.3, 0.5}),
        LAYER_UNSELECTED = defs.LIGHT_OFF,
        LAYER_SELECTED = defs.LIGHT_BRIGHT_GREEN,
        KNOB_SET_SELECTED = Color:gray(200),
        KNOB_SET_UNSELECTED = Color:gray(40)
    }
}
return ____exports
