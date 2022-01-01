--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____common = require("engine.common")
local MIDI = ____common.MIDI
local ____fire_state = require("engine.fire_state")
local FireState = ____fire_state.FireState
local ____render_context = require("engine.render_context")
local RenderContext = ____render_context.RenderContext
local ____mode_selector = require("layers.mode_selector")
local ModeSelector = ____mode_selector.ModeSelector
local ____midi = require("engine.midi")
local Midi = ____midi.Midi
____exports.Fire = __TS__Class()
local Fire = ____exports.Fire
Fire.name = "Fire"
function Fire.prototype.____constructor(self, fire_device_index)
    self.t_start = 0
    self.t_idle = 0
    self.t_render = 0
    self.t_end = 0
    self.t_threshold = 0.001
    self.fire_device_index = fire_device_index
    self.fire_config = nil
    self.state_on_device = __TS__New(FireState, nil)
    self.state = __TS__New(FireState, nil)
    self.is_active = false
    self.midi = __TS__New(Midi, self)
    self.render_context = __TS__New(RenderContext, self.state)
    self.root_layer = nil
end
function Fire.prototype.start(self, fire_config)
    self.fire_config = fire_config
    if self.fire_config and self.fire_config.enabled then
        self.root_layer = __TS__New(ModeSelector, self.fire_config.mode_bindings, self.fire_device_index)
        oprint(
            ("Fire #" .. tostring(self.fire_device_index)) .. " config changed"
        )
        self.midi:connect(self.fire_config.midi_input, self.fire_config.midi_output)
    else
        self.midi:disconnect()
    end
end
function Fire.prototype.on_fire_config_changed(self, fire_config)
    if self.is_active then
        self:clear_now()
    end
    self:start(fire_config)
end
function Fire.prototype.clear_now(self)
    self.state:clear()
    self:set_device_state(true)
end
function Fire.prototype.on_midi_connection_changed(self, connected)
    self.is_active = connected
    oprint(
        (("Fire #" .. tostring(self.fire_device_index)) .. " midi ") .. tostring((connected and "yes") or "no")
    )
    if connected then
        self.root_layer:all_on_idle()
        self:render()
        self:set_device_state(true)
    end
end
function Fire.prototype.on_midi_in(self, message)
    if message[1] == MIDI.NOTE_ON then
        self.root_layer:all_on_midi_note(message[2], message[3])
    elseif message[1] == MIDI.NOTE_OFF then
        self.root_layer:all_on_midi_note(message[2], nil)
    elseif message[1] == MIDI.CONTROL_CHANGE then
        self.root_layer:all_on_midi_cc(message[2], message[3])
    end
    self:render()
    self:set_device_state(false, true)
end
function Fire.prototype.render(self)
    self.render_context:on_start()
    self.root_layer:all_render(self.render_context)
    self.render_context:on_finish()
end
function Fire.prototype.set_device_state(self, full_update, quick)
    if quick == nil then
        quick = false
    end
    local from = nil
    if not full_update then
        from = self.state_on_device
    end
    for ____, message in ipairs(
        self.state:get_midi_messages(self.fire_device_index, from, quick)
    ) do
        self.midi:send(message)
    end
    self.state_on_device = self.state:clone()
end
function Fire.prototype.on_idle(self)
    pyre_native:get_time()
    self.t_start = os.clock()
    self.root_layer:all_on_idle()
    self.t_idle = os.clock()
    self:render()
    self.t_render = os.clock()
    self:set_device_state(false)
    self.t_end = os.clock()
    local t = self.t_end - self.t_start
    if t > self.t_threshold then
        print(
            ((((((((("Slow frame: " .. tostring(t)) .. " = idle:") .. tostring(self.t_idle - self.t_start)) .. " + render:") .. tostring(self.t_render - self.t_idle)) .. " + device:") .. tostring(self.t_end - self.t_render)) .. " [native.t_sum=") .. tostring(
                pyre_native:get_time()
            )) .. "]"
        )
        self.t_threshold = t
    end
end
return ____exports
