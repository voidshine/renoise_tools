--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____utility = require("engine.utility")
local write_file = ____utility.write_file
local read_file = ____utility.read_file
local ____color = require("engine.color")
local Color = ____color.Color
____exports.PITCH_CLASS_NAMES = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
local PITCH_CLASS_COLORS = __TS__ArrayMap(
    ____exports.PITCH_CLASS_NAMES,
    function(____, _, i) return Color:hsv({i / #____exports.PITCH_CLASS_NAMES, 0.6, 0.1}) end
)
local TrackData = __TS__Class()
TrackData.name = "TrackData"
function TrackData.prototype.____constructor(self)
    self.layer_note_layouts = {}
end
____exports.SongData = __TS__Class()
local SongData = ____exports.SongData
SongData.name = "SongData"
function SongData.prototype.____constructor(self)
    self.per_track = {}
    self.root_pitch_class = 0
    self.rotate_colors_to_root = true
end
function SongData.get_filename(self)
    return __TS__StringReplace(rns.file_name, ".xrns", "_pyre_data.json")
end
function SongData.load_from_file(self)
    local content, ____error = read_file(
        ____exports.SongData:get_filename()
    )
    return ____exports.SongData:from_json(content)
end
function SongData.from_json(self, json)
    local data = __TS__New(____exports.SongData)
    if json ~= nil then
        local loaded = lunajson.decode(json)
        for key in pairs(loaded) do
            data[key] = loaded[key]
        end
    end
    return data
end
function SongData.prototype.save_to_file(self)
    write_file(
        ____exports.SongData:get_filename(),
        lunajson.encode(self)
    )
end
function SongData.prototype.get_track_data(self, track_name)
    local data = self.per_track[track_name]
    if not data then
        data = __TS__New(TrackData)
        self.per_track[track_name] = data
    end
    return data
end
function SongData.prototype.note_color(self, note)
    if self.rotate_colors_to_root then
        note = note + (#PITCH_CLASS_COLORS - self.root_pitch_class)
    end
    return PITCH_CLASS_COLORS[(note % #PITCH_CLASS_COLORS) + 1]
end
function SongData.prototype.create_or_get_track_note_layout(self, layer_name, track_name)
    local track_data = self:get_track_data(track_name)
    local layout = track_data.layer_note_layouts[layer_name]
    if not layout then
        layout = self:clone_note_layout(
            driver.options:get_note_layout(layer_name)
        )
        track_data.layer_note_layouts[layer_name] = layout
    end
    return layout
end
function SongData.prototype.clone_note_layout(self, from_layout)
    local layout = table.rcopy(from_layout)
    if layout.use_song_root then
        layout.origin_note = layout.origin_note + self.root_pitch_class
    end
    return layout
end
return ____exports
