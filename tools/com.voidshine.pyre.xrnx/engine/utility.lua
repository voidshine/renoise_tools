--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
function ____exports.modulo_up(i, m)
    local r = i % m
    return ((r == 0) and i) or ((i + m) - r)
end
function ____exports.modulo_down(i, m)
    return i - (i % m)
end
function ____exports.table_clear(t)
    for k in pairs(t) do
        t[k] = nil
    end
end
function ____exports.select_first_track_column()
    if rns.selected_track.visible_note_columns > 0 then
        rns.selected_note_column_index = 0 + 1
    else
        rns.selected_effect_column_index = 0 + 1
    end
end
function ____exports.select_last_track_column()
    if rns.selected_track.visible_effect_columns > 0 then
        rns.selected_effect_column_index = (rns.selected_track.visible_effect_columns - 1) + 1
    else
        rns.selected_note_column_index = (rns.selected_track.visible_note_columns - 1) + 1
    end
end
function ____exports.step_note_column(delta, wrap_pattern, wrap_track)
    local track = rns.selected_track
    local column_index = rns.selected_note_column_index - 1
    if column_index < 0 then
        if delta > 0 then
            column_index = track.visible_note_columns - 1
        else
            column_index = track.visible_note_columns
        end
    end
    if wrap_track then
        column_index = ((column_index + delta) + track.visible_note_columns) % track.visible_note_columns
    else
        column_index = column_index + delta
        if column_index < 0 then
            xTrack.jump_to_previous_sequencer_track()
            track = rns.selected_track
            column_index = track.visible_note_columns - 1
        elseif column_index >= track.visible_note_columns then
            xTrack.jump_to_next_sequencer_track()
            column_index = 0
        end
    end
    if (column_index >= 0) and (column_index < track.max_note_columns) then
        rns.selected_note_column_index = column_index + 1
    end
end
function ____exports.step_track_column(steps, whole_tracks, skip_collapsed_tracks, note_columns)
    if skip_collapsed_tracks and __TS__ArrayEvery(
        rns.tracks,
        function(____, track) return track.collapsed end
    ) then
        skip_collapsed_tracks = false
    end
    local start_track_index = rns.selected_track_index - 1
    while steps > 0 do
        steps = steps - 1
        repeat
            do
                if rns.selected_track.collapsed then
                    ____exports.select_last_track_column()
                end
                if whole_tracks then
                    local track_count = #rns.tracks
                    rns.selected_track_index = (((rns.selected_track_index - 1) + 1) % track_count) + 1
                elseif note_columns then
                    ____exports.step_note_column(1, true, false)
                else
                    xColumns.next_column()
                end
            end
        until not ((skip_collapsed_tracks and rns.selected_track.collapsed) and ((rns.selected_track_index - 1) ~= start_track_index))
    end
    while steps < 0 do
        steps = steps + 1
        repeat
            do
                if rns.selected_track.collapsed then
                    ____exports.select_first_track_column()
                end
                if whole_tracks then
                    local track_count = #rns.tracks
                    rns.selected_track_index = ((((rns.selected_track_index - 1) + track_count) - 1) % track_count) + 1
                elseif note_columns then
                    ____exports.step_note_column(-1, true, false)
                else
                    xColumns.previous_column()
                end
            end
        until not ((skip_collapsed_tracks and rns.selected_track.collapsed) and ((rns.selected_track_index - 1) ~= start_track_index))
    end
end
function ____exports.clock_pulse(n)
    if n == nil then
        n = 1
    end
    return 1 - ((os.clock() * n) % 1)
end
function ____exports.read_file(path)
    rprint(
        "Read file: " .. tostring(path)
    )
    if not io.exists(path) then
        return nil, "Path not found: " .. tostring(path)
    end
    local f = io.open(path, "rb")
    local content = f:read("*all")
    f:close()
    return content, nil
end
function ____exports.write_file(path, content)
    rprint(
        (("Write file: " .. tostring(path)) .. "; content = ") .. tostring(content)
    )
    local f = io.open(path, "wb")
    f:write(content)
    f:close()
end
function ____exports.load_json(path)
    local json, ____error = ____exports.read_file(path)
    if ____error then
        return nil, ____error
    end
    return lunajson.decode(json), nil
end
function ____exports.save_json(path, model)
    ____exports.write_file(
        path,
        lunajson.encode(model)
    )
end
local function index_by_key(t, key)
    local index = {}
    for key in pairs(t) do
        local v = t[key]
        index[v[key]] = v
    end
    return index
end
____exports.Vec2 = __TS__Class()
local Vec2 = ____exports.Vec2
Vec2.name = "Vec2"
function Vec2.prototype.____constructor(self, x, y)
    if y then
        self.x = x
        self.y = y
    else
        x = x
        self.x = x.x
        self.y = x.y
    end
end
function Vec2.prototype.__add(self, rhs)
    return __TS__New(____exports.Vec2, self.x + rhs.x, self.y + rhs.y)
end
function Vec2.prototype.__sub(self, rhs)
    return __TS__New(____exports.Vec2, self.x - rhs.x, self.y - rhs.y)
end
function Vec2.prototype.iter_range(self)
    local at_x = 0
    local at_y = 0
    return function()
        if at_y < self.y then
            local pos = __TS__New(____exports.Vec2, at_x, at_y)
            at_x = at_x + 1
            if at_x >= self.x then
                at_x = 0
                at_y = at_y + 1
            end
            return pos
        else
            return nil
        end
    end
end
function Vec2.prototype.area(self)
    return self.x * self.y
end
function Vec2.prototype.contains_xy(self, x, y)
    return (((x >= 0) and (y >= 0)) and (x < self.x)) and (y < self.y)
end
function Vec2.prototype.contains_pos(self, pos)
    return (((pos.x >= 0) and (pos.y >= 0)) and (pos.x < self.x)) and (pos.y < self.y)
end
____exports.Rect = __TS__Class()
local Rect = ____exports.Rect
Rect.name = "Rect"
function Rect.prototype.____constructor(self, left_or_pos, top_or_size, width, height)
    if width then
        self.left = left_or_pos
        self.top = top_or_size
        self.width = width
        self.height = height
    else
        local pos = left_or_pos
        local size = top_or_size
        self.left = pos.x
        self.top = pos.y
        self.width = size.x
        self.height = (function()
            height = size.y
            return height
        end)()
    end
end
function Rect.prototype.clone(self)
    return __TS__New(____exports.Rect, self.left, self.top, self.width, self.height)
end
function Rect.prototype.set(self, from)
    self.left = from.left
    self.top = from.top
    self.width = from.width
    self.height = from.height
end
function Rect.prototype.iter_xy(self)
    local at_x = self.left
    local at_y = self.top
    return function()
        if at_y < (self.top + self.height) then
            local x = at_x
            local y = at_y
            at_x = at_x + 1
            if at_x >= (self.left + self.width) then
                at_x = self.left
                at_y = at_y + 1
            end
            return {x, y}
        else
            return nil
        end
    end
end
function Rect.prototype.iter_pos(self)
    local iter_xy = self:iter_xy()
    return function()
        local x, y = unpack(
            iter_xy(nil)
        )
        print(
            (tostring(x) .. ", ") .. tostring(y)
        )
        if x then
            return {
                __TS__New(____exports.Vec2, x, y)
            }
        else
            return nil
        end
    end
end
function Rect.prototype.right(self)
    return self.left + self.width
end
function Rect.prototype.bottom(self)
    return self.top + self.height
end
function Rect.prototype.sub_rect(self, x, y, w, h)
    return __TS__New(____exports.Rect, self.left + x, self.top + y, w, h)
end
function Rect.prototype.area(self)
    return self.width * self.height
end
function Rect.prototype.contains(self, pos)
    return (((pos.x >= self.left) and (pos.y >= self.top)) and (pos.x < self:right())) and (pos.y < self:bottom())
end
function Rect.prototype.pos(self)
    return __TS__New(____exports.Vec2, self.left, self.top)
end
function Rect.prototype.size(self)
    return __TS__New(____exports.Vec2, self.width, self.height)
end
function Rect.prototype.include_xy(self, x, y)
    self.left = math.min(self.left, x)
    self.top = math.min(self.top, y)
    self.width = math.max(self.width, (x - self.left) + 1)
    self.height = math.max(self.height, (y - self.top) + 1)
end
function Rect.prototype.include_pos(self, pos)
    self.left = math.min(self.left, pos.x)
    self.top = math.min(self.top, pos.y)
    self.width = math.max(self.width, (pos.x - self.left) + 1)
    self.height = math.max(self.height, (pos.y - self.top) + 1)
end
function Rect.prototype.corners(self)
    return {
        {self.left, self.top},
        {
            self:right(),
            self.top
        },
        {
            self:right(),
            self:bottom()
        },
        {
            self.left,
            self:bottom()
        }
    }
end
return ____exports
