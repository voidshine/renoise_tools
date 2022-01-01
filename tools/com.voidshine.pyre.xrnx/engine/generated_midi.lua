--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____common = require("engine.common")
local MIDI = ____common.MIDI
local ____midi = require("engine.midi")
local Midi = ____midi.Midi
local ____osc_renoise = require("engine.osc_renoise")
local osc_renoise_connect = ____osc_renoise.osc_renoise_connect
____exports.GeneratedMidi = __TS__Class()
local GeneratedMidi = ____exports.GeneratedMidi
GeneratedMidi.name = "GeneratedMidi"
function GeneratedMidi.prototype.____constructor(self)
    self.midi = __TS__New(Midi, self)
end
function GeneratedMidi.prototype.send_note_on(self, note, velocity)
    osc_renoise_send_note_on(note, velocity)
    self.midi:send({MIDI.NOTE_ON, note, velocity})
end
function GeneratedMidi.prototype.send_note_off(self, note)
    osc_renoise_send_note_off(note)
    self.midi:send({MIDI.NOTE_OFF, note, 0})
end
function GeneratedMidi.prototype.send_midi(self, message)
    self.midi:send(message)
end
function GeneratedMidi.prototype.on_config_changed(self, generated_midi_config)
    osc_renoise_connect(generated_midi_config)
    self.midi:connect(nil, generated_midi_config.midi_output)
end
function GeneratedMidi.prototype.on_midi_connection_changed(self, connected)
    rprint(
        "GeneratedMidi connected: " .. tostring((connected and "yes") or "no")
    )
end
function GeneratedMidi.prototype.on_midi_in(self, message)
    error(
        __TS__New(Error, "Not used."),
        0
    )
end
return ____exports
