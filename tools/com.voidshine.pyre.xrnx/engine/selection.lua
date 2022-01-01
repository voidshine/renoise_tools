--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
require("global")
local function total_visible_columns(track)
    return track.visible_note_columns + track.visible_effect_columns
end
local function rns_current_column()
    local column = rns.selected_note_column_index - 1
    if column < 0 then
        rprint("negative one")
        column = (rns.selected_track.visible_note_columns + (rns.selected_effect_column_index - 1)) - 1
    end
    return column
end
____exports.PatternPos = __TS__Class()
local PatternPos = ____exports.PatternPos
PatternPos.name = "PatternPos"
function PatternPos.prototype.____constructor(self, track, column, line)
    self.track = track
    self.column = column
    self.line = line
end
function PatternPos.prototype.clone(self)
    return __TS__New(____exports.PatternPos, self.track, self.column, self.line)
end
function PatternPos.prototype.set_column_last(self)
    self.column = total_visible_columns(
        rns:track(self.track + 1)
    ) - 1
end
function PatternPos.current(self)
    return __TS__New(
        ____exports.PatternPos,
        rns.selected_track_index - 1,
        rns_current_column(),
        rns.selected_line_index - 1
    )
end
____exports.Selection = __TS__Class()
local Selection = ____exports.Selection
Selection.name = "Selection"
function Selection.prototype.____constructor(self, start_pos, end_pos)
    self.start_pos = start_pos
    self.end_pos = end_pos
end
function Selection.prototype.clone(self)
    return __TS__New(
        ____exports.Selection,
        self.start_pos:clone(),
        self.end_pos:clone()
    )
end
function Selection.prototype.is_empty(self)
    return self.start_pos.line > self.end_pos.line
end
function Selection.prototype.to_rns_selection(self)
    if self:is_empty() then
        return nil
    end
    return {
        start_track = 1 + math.min(self.start_pos.track, self.end_pos.track),
        end_track = 1 + math.max(self.start_pos.track, self.end_pos.track),
        start_column = 1 + math.min(self.start_pos.column, self.end_pos.column),
        end_column = 1 + math.max(self.start_pos.column, self.end_pos.column),
        start_line = 1 + math.min(self.start_pos.line, self.end_pos.line),
        end_line = 1 + math.max(self.start_pos.line, self.end_pos.line)
    }
end
function Selection.prototype.apply(self)
    rns.selection_in_pattern = self:to_rns_selection()
end
function Selection.prototype.expand_width(self)
    if self.start_pos.track == self.end_pos.track then
        if self.start_pos.column == self.end_pos.column then
            self.start_pos.column = 0
            self.end_pos:set_column_last()
        else
            self.start_pos.track = 0
            self.start_pos.column = 0
            self.end_pos.track = rns.sequencer_track_count
            self.end_pos:set_column_last()
        end
    end
end
function Selection.prototype.contract_width(self)
    if self.start_pos.track == self.end_pos.track then
        if self.start_pos.column ~= self.end_pos.column then
            self.start_pos.column = rns_current_column()
            self.end_pos.column = self.start_pos.column
        end
    else
        self.start_pos.track = rns.selected_track_index - 1
        self.start_pos.column = 0
        self.end_pos.track = self.start_pos.track
        self.end_pos:set_column_last()
    end
end
return ____exports
