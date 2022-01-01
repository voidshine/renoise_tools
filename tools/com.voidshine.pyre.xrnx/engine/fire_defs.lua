--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____color = require("engine.color")
local Color = ____color.Color
____exports.FIRE_KNOB_COUNT = 5
____exports.FIRE_GRID_WIDTH = 16
____exports.FIRE_GRID_HEIGHT = 4
____exports.FIRE_GRID_TOP_LEFT_NOTE = 54
____exports.FIRE_BUTTON = {ChannelMixerUserButton = 26, KnobVolume = 16, KnobPan = 17, KnobFilter = 18, KnobResonance = 19, KnobSelect = 25, PatternUp = 31, PatternDown = 32, Browser = 33, GridLeft = 34, GridRight = 35, RowMute0 = 36, RowMute1 = 37, RowMute2 = 38, RowMute3 = 39, Step = 44, Note = 45, Drum = 46, Perform = 47, Shift = 48, Alt = 49, PatternSongMetronome = 50, PlayWait = 51, Stop = 52, Record = 53}
____exports.FIRE_CHANNEL_MIXER_USER_LIGHTS = 27
____exports.FIRE_LIGHT = {PatternUp = 31, PatternDown = 32, Browser = 33, GridLeft = 34, GridRight = 35, RowMute0 = 36, RowMute1 = 37, RowMute2 = 38, RowMute3 = 39, RowSelect0 = 40, RowSelect1 = 41, RowSelect2 = 42, RowSelect3 = 43, Step = 44, Note = 45, Drum = 46, Perform = 47, Shift = 48, Alt = 49, PatternSongMetronome = 50, PlayWait = 51, Stop = 52, Record = 53}
____exports.LIGHT_OFF = Color:black()
____exports.LIGHT_DARK_RED = Color:rgb({32, 0, 0})
____exports.LIGHT_BRIGHT_RED = Color:rgb({180, 0, 0})
____exports.LIGHT_DARK_ORANGE = Color:rgb({32, 24, 0})
____exports.LIGHT_BRIGHT_ORANGE = Color:rgb({180, 120, 0})
____exports.LIGHT_DARK_GREEN = Color:rgb({0, 32, 0})
____exports.LIGHT_BRIGHT_GREEN = Color:rgb({0, 180, 0})
local function build_color_to_index(colors)
    local lookup = {}
    __TS__ArrayForEach(
        colors,
        function(____, color, i)
            lookup[color:to_int() + 1] = i
        end
    )
    return lookup
end
local color_to_index_lookups = {
    build_color_to_index({____exports.LIGHT_OFF, ____exports.LIGHT_DARK_RED, ____exports.LIGHT_BRIGHT_RED}),
    build_color_to_index({____exports.LIGHT_OFF, ____exports.LIGHT_DARK_GREEN, ____exports.LIGHT_BRIGHT_GREEN}),
    build_color_to_index({____exports.LIGHT_OFF, ____exports.LIGHT_DARK_RED, ____exports.LIGHT_DARK_GREEN, ____exports.LIGHT_BRIGHT_RED, ____exports.LIGHT_BRIGHT_GREEN}),
    build_color_to_index({____exports.LIGHT_OFF, ____exports.LIGHT_DARK_RED, ____exports.LIGHT_DARK_ORANGE, ____exports.LIGHT_BRIGHT_RED, ____exports.LIGHT_BRIGHT_ORANGE}),
    build_color_to_index({____exports.LIGHT_OFF, ____exports.LIGHT_DARK_ORANGE, ____exports.LIGHT_BRIGHT_ORANGE}),
    build_color_to_index({____exports.LIGHT_OFF, ____exports.LIGHT_DARK_GREEN, ____exports.LIGHT_DARK_ORANGE, ____exports.LIGHT_BRIGHT_GREEN, ____exports.LIGHT_BRIGHT_ORANGE})
}
local FIRE_LIGHT_TO_COLOR_INDEX_LOOKUP = {[____exports.FIRE_LIGHT.PatternUp] = color_to_index_lookups[1], [____exports.FIRE_LIGHT.PatternDown] = color_to_index_lookups[1], [____exports.FIRE_LIGHT.Browser] = color_to_index_lookups[1], [____exports.FIRE_LIGHT.GridLeft] = color_to_index_lookups[1], [____exports.FIRE_LIGHT.GridRight] = color_to_index_lookups[1], [____exports.FIRE_LIGHT.RowMute0] = color_to_index_lookups[2], [____exports.FIRE_LIGHT.RowMute1] = color_to_index_lookups[2], [____exports.FIRE_LIGHT.RowMute2] = color_to_index_lookups[2], [____exports.FIRE_LIGHT.RowMute3] = color_to_index_lookups[2], [____exports.FIRE_LIGHT.RowSelect0] = color_to_index_lookups[3], [____exports.FIRE_LIGHT.RowSelect1] = color_to_index_lookups[3], [____exports.FIRE_LIGHT.RowSelect2] = color_to_index_lookups[3], [____exports.FIRE_LIGHT.RowSelect3] = color_to_index_lookups[3], [____exports.FIRE_LIGHT.Step] = color_to_index_lookups[4], [____exports.FIRE_LIGHT.Note] = color_to_index_lookups[4], [____exports.FIRE_LIGHT.Drum] = color_to_index_lookups[4], [____exports.FIRE_LIGHT.Perform] = color_to_index_lookups[4], [____exports.FIRE_LIGHT.Shift] = color_to_index_lookups[4], [____exports.FIRE_LIGHT.Alt] = color_to_index_lookups[5], [____exports.FIRE_LIGHT.PatternSongMetronome] = color_to_index_lookups[6], [____exports.FIRE_LIGHT.PlayWait] = color_to_index_lookups[6], [____exports.FIRE_LIGHT.Stop] = color_to_index_lookups[5], [____exports.FIRE_LIGHT.Record] = color_to_index_lookups[4]}
____exports.FIRE_KNOB = {Volume = 16, Pan = 17, Filter = 18, Resonance = 19, Select = 118}
____exports.FIRE_KNOB_TO_BUTTON = {[____exports.FIRE_KNOB.Volume] = ____exports.FIRE_BUTTON.KnobVolume, [____exports.FIRE_KNOB.Pan] = ____exports.FIRE_BUTTON.KnobPan, [____exports.FIRE_KNOB.Filter] = ____exports.FIRE_BUTTON.KnobFilter, [____exports.FIRE_KNOB.Resonance] = ____exports.FIRE_BUTTON.KnobResonance, [____exports.FIRE_KNOB.Select] = ____exports.FIRE_BUTTON.KnobSelect}
____exports.FIRE_BUTTON_TO_LIGHT = {[____exports.FIRE_BUTTON.ChannelMixerUserButton] = ____exports.FIRE_CHANNEL_MIXER_USER_LIGHTS, [____exports.FIRE_BUTTON.KnobVolume] = nil, [____exports.FIRE_BUTTON.KnobPan] = nil, [____exports.FIRE_BUTTON.KnobFilter] = nil, [____exports.FIRE_BUTTON.KnobResonance] = nil, [____exports.FIRE_BUTTON.KnobSelect] = nil, [____exports.FIRE_BUTTON.PatternUp] = ____exports.FIRE_LIGHT.PatternUp, [____exports.FIRE_BUTTON.PatternDown] = ____exports.FIRE_LIGHT.PatternDown, [____exports.FIRE_BUTTON.Browser] = ____exports.FIRE_LIGHT.Browser, [____exports.FIRE_BUTTON.GridLeft] = ____exports.FIRE_LIGHT.GridLeft, [____exports.FIRE_BUTTON.GridRight] = ____exports.FIRE_LIGHT.GridRight, [____exports.FIRE_BUTTON.RowMute0] = ____exports.FIRE_LIGHT.RowMute0, [____exports.FIRE_BUTTON.RowMute1] = ____exports.FIRE_LIGHT.RowMute1, [____exports.FIRE_BUTTON.RowMute2] = ____exports.FIRE_LIGHT.RowMute2, [____exports.FIRE_BUTTON.RowMute3] = ____exports.FIRE_LIGHT.RowMute3, [____exports.FIRE_BUTTON.Step] = ____exports.FIRE_LIGHT.Step, [____exports.FIRE_BUTTON.Note] = ____exports.FIRE_LIGHT.Note, [____exports.FIRE_BUTTON.Drum] = ____exports.FIRE_LIGHT.Drum, [____exports.FIRE_BUTTON.Perform] = ____exports.FIRE_LIGHT.Perform, [____exports.FIRE_BUTTON.Shift] = ____exports.FIRE_LIGHT.Shift, [____exports.FIRE_BUTTON.Alt] = ____exports.FIRE_LIGHT.Alt, [____exports.FIRE_BUTTON.PatternSongMetronome] = ____exports.FIRE_LIGHT.PatternSongMetronome, [____exports.FIRE_BUTTON.PlayWait] = ____exports.FIRE_LIGHT.PlayWait, [____exports.FIRE_BUTTON.Stop] = ____exports.FIRE_LIGHT.Stop, [____exports.FIRE_BUTTON.Record] = ____exports.FIRE_LIGHT.Record}
function ____exports.grid_xy_to_midi_note(x, y)
    return (____exports.FIRE_GRID_TOP_LEFT_NOTE + (y * ____exports.FIRE_GRID_WIDTH)) + x
end
function ____exports.grid_midi_note_to_xy(note)
    local index = note - ____exports.FIRE_GRID_TOP_LEFT_NOTE
    return math.fmod(index, 16), math.floor(index / 16)
end
function ____exports.get_midi_light(light, color)
    local color_index = FIRE_LIGHT_TO_COLOR_INDEX_LOOKUP[light][color:to_int() + 1] or (((color == Color:black()) and 0) or 1)
    return {176, light, color_index}
end
function ____exports.get_midi_quad_light(quad_light)
    return {176, ____exports.FIRE_CHANNEL_MIXER_USER_LIGHTS, quad_light}
end
return ____exports
