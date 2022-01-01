--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
____exports.MIDI_PORT_NONE = "None"
____exports.Midi = __TS__Class()
local Midi = ____exports.Midi
Midi.name = "Midi"
function Midi.prototype.____constructor(self, handler)
    self.handler = handler
    self.input_device = nil
    self.output_device = nil
    self.midi_in_port = nil
    self.midi_out_port = nil
    renoise.Midi.devices_changed_observable():add_notifier(self.on_devices_changed, self)
end
function Midi.prototype.is_connected(self)
    return ((self.input_device ~= nil) or (self.midi_in_port == nil)) and ((self.output_device ~= nil) or (self.midi_out_port == nil))
end
function Midi.prototype.on_devices_changed(self)
end
function Midi.prototype.disconnect(self)
    if self.input_device then
        self.input_device:close()
        self.input_device = nil
    end
    if self.output_device then
        self.output_device:close()
        self.output_device = nil
        self.send = ____exports.Midi.prototype.send
    end
end
function Midi.prototype.connect(self, midi_in_port, midi_out_port)
    self:disconnect()
    self.midi_in_port = midi_in_port
    self.midi_out_port = midi_out_port
    if self.midi_in_port == ____exports.MIDI_PORT_NONE then
        self.midi_in_port = nil
    end
    if self.midi_out_port == ____exports.MIDI_PORT_NONE then
        self.midi_out_port = nil
    end
    if self.midi_in_port and table.find(
        renoise.Midi.available_input_devices(),
        self.midi_in_port
    ) then
        self.input_device = renoise.Midi.create_input_device(
            self.midi_in_port,
            function(message)
                self.handler:on_midi_in(message)
            end
        )
    end
    if self.midi_out_port and table.find(
        renoise.Midi.available_output_devices(),
        self.midi_out_port
    ) then
        self.output_device = renoise.Midi.create_output_device(self.midi_out_port)
        self.send = function(____self, message)
            ____self.output_device:send(message)
        end
    end
    if not self:is_connected() then
        self:disconnect()
    end
    self.handler:on_midi_connection_changed(
        self:is_connected()
    )
end
function Midi.prototype.send(self, message)
end
return ____exports
