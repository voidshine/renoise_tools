--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local defs = require("engine.fire_defs")
____exports.Layer = __TS__Class()
local Layer = ____exports.Layer
Layer.name = "Layer"
function Layer.prototype.____constructor(self, model, name)
    self.children = {}
    self.always_dirty = true
    self.name = name
    self.note_on_handlers = {}
    self.note_off_handlers = {}
    self.cc_handlers = {}
    self.model = model
    self.rendered_model = nil
end
function Layer.prototype.set_note_on_handlers(self, handlers)
    for key in pairs(handlers) do
        local v
        v = handlers[key]
        self.note_on_handlers[key] = v
    end
end
function Layer.prototype.set_note_off_handlers(self, handlers)
    for key in pairs(handlers) do
        local v
        v = handlers[key]
        self.note_off_handlers[key] = v
    end
end
function Layer.prototype.set_cc_handlers(self, handlers)
    for key in pairs(handlers) do
        local v
        v = handlers[key]
        self.cc_handlers[key] = v
    end
end
function Layer.prototype.set_note_handlers_grid_rect(self, rect, handler)
    local on_handlers = {}
    local off_handlers = {}
    local translate_on
    translate_on = function(note, velocity)
        local x, y = defs.grid_midi_note_to_xy(note)
        handler(x - rect.left, y - rect.top, velocity)
    end
    local translate_off
    translate_off = function(note)
        local x, y = defs.grid_midi_note_to_xy(note)
        handler(x - rect.left, y - rect.top, nil)
    end
    do
        local y = rect.top
        while y < (rect.top + rect.height) do
            do
                local x = rect.left
                while x < (rect.left + rect.width) do
                    local index = defs.grid_xy_to_midi_note(x, y)
                    on_handlers[index] = translate_on
                    off_handlers[index] = translate_off
                    x = x + 1
                end
            end
            y = y + 1
        end
    end
    self:set_note_on_handlers(on_handlers)
    self:set_note_off_handlers(off_handlers)
end
function Layer.prototype.set_knob_delta_handler(self, handler)
    local convert
    convert = function(knob)
        return function(cc, value)
            return handler(knob, ((value < 64) and value) or -(128 - value))
        end
    end
    self:set_cc_handlers(
        {
            [defs.FIRE_KNOB.Volume] = convert(0),
            [defs.FIRE_KNOB.Pan] = convert(1),
            [defs.FIRE_KNOB.Filter] = convert(2),
            [defs.FIRE_KNOB.Resonance] = convert(3),
            [defs.FIRE_KNOB.Select] = convert(4)
        }
    )
end
function Layer.prototype.set_knob_handler(self, knob_cc, knob_handler)
    self.cc_handlers[knob_cc] = function(cc, value)
        knob_handler:on_turn(((value < 64) and value) or -(128 - value))
    end
    self.note_on_handlers[defs.FIRE_KNOB_TO_BUTTON[knob_cc]] = function(note, velocity)
        knob_handler:on_press()
    end
    self.note_off_handlers[defs.FIRE_KNOB_TO_BUTTON[knob_cc]] = function(note)
        knob_handler:on_release()
    end
end
function Layer.prototype.set_knob_handlers(self, knobs)
    if knobs[1] then
        self:set_knob_handler(defs.FIRE_KNOB.Volume, knobs[1])
    end
    if knobs[2] then
        self:set_knob_handler(defs.FIRE_KNOB.Pan, knobs[2])
    end
    if knobs[3] then
        self:set_knob_handler(defs.FIRE_KNOB.Filter, knobs[3])
    end
    if knobs[4] then
        self:set_knob_handler(defs.FIRE_KNOB.Resonance, knobs[4])
    end
    if knobs[5] then
        self:set_knob_handler(defs.FIRE_KNOB.Select, knobs[5])
    end
end
function Layer.prototype.get_model_is_dirty(self)
    return self.always_dirty or (self.model ~= self.rendered_model)
end
function Layer.prototype.set_model_is_dirty(self, dirty)
    if dirty or self.always_dirty then
        self.rendered_model = nil
    else
        self.rendered_model = self.model:clone()
        if self:get_model_is_dirty() then
        end
        assert(
            not self:get_model_is_dirty(),
            ("On layer " .. tostring(self.name)) .. ", model is still dirty after clone! This will cause rendering on every idle call."
        )
    end
end
function Layer.prototype.render(self, rc, m)
end
function Layer.prototype.all_render(self, rc)
    if self:get_model_is_dirty() then
        self:render(rc, self.model)
        self:set_model_is_dirty(false)
    end
    __TS__ArrayForEach(
        self.children,
        function(____, child, _)
            child:all_render(rc)
        end
    )
end
function Layer.prototype.all_on_midi_note(self, note, velocity)
    do
        local i = 0
        while i < #self.children do
            if self.children[i + 1]:all_on_midi_note(note, velocity) then
                return true
            end
            i = i + 1
        end
    end
    return self:on_midi_note(note, velocity)
end
function Layer.prototype.on_midi_note(self, note, velocity)
    if velocity then
        local handler
        handler = self.note_on_handlers[note]
        if handler then
            if handler(note, velocity) then
                return false
            end
            return true
        end
    else
        local handler
        handler = self.note_off_handlers[note]
        if handler then
            if handler(note) then
                return false
            end
            return true
        end
    end
    return false
end
function Layer.prototype.all_on_midi_cc(self, cc, value)
    do
        local i = 0
        while i < #self.children do
            if self.children[i + 1]:all_on_midi_cc(cc, value) then
                return true
            end
            i = i + 1
        end
    end
    return self:on_midi_cc(cc, value)
end
function Layer.prototype.on_midi_cc(self, cc, value)
    local handler
    handler = self.cc_handlers[cc]
    if handler then
        if handler(cc, value) then
            return false
        end
        return true
    end
    return false
end
function Layer.prototype.update_model(self, m)
end
function Layer.prototype.on_idle(self)
    self:update_model(self.model)
end
function Layer.prototype.all_on_idle(self)
    self:on_idle()
    __TS__ArrayForEach(
        self.children,
        function(____, child, _)
            child:all_on_idle()
        end
    )
end
function Layer.prototype.all_visit(self, method_name)
    (function()
        local ____self = self
        return ____self[method_name](____self, self)
    end)()
    __TS__ArrayForEach(
        self.children,
        function(____, child, _)
            child:all_visit(method_name)
        end
    )
end
function Layer.prototype.mount(self, children)
    __TS__ArrayForEach(
        self.children,
        function(____, child, _)
            child:all_visit("on_unmount")
        end
    )
    self.children = children
    __TS__ArrayForEach(
        self.children,
        function(____, child, _)
            child:all_visit("on_mount")
        end
    )
end
function Layer.prototype.on_mount(self)
    self:on_idle()
    self:set_model_is_dirty(true)
end
function Layer.prototype.on_unmount(self)
end
function Layer.prototype.invalidate(self)
    self:set_model_is_dirty(true)
    __TS__ArrayForEach(
        self.children,
        function(____, child) return child:invalidate() end
    )
end
function Layer.prototype.build_menu(self, item)
    __TS__ArrayForEach(
        self.children,
        function(____, child)
            child:build_menu(item)
        end
    )
end
return ____exports
