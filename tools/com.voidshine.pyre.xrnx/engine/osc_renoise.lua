--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____common = require("engine.common")
local no_op = ____common.no_op
local client
local socket_error
osc_renoise_send_note_on = no_op
osc_renoise_send_note_off = no_op
function ____exports.osc_renoise_connect(prefs)
    rprint("OSC connect")
    if prefs.osc_enabled then
        client, socket_error = renoise.Socket.create_client(prefs.osc_address, prefs.osc_port, renoise.Socket.PROTOCOL_UDP)
        if socket_error then
            renoise.app():show_warning(
                ("Failed to start the OSC client. Error: '" .. tostring(socket_error)) .. "'"
            )
            return
        end
        rprint("OSC connect")
        osc_renoise_send_note_on = function(note, velocity)
            client:send(
                renoise.Osc.Message("/renoise/trigger/note_on", {{tag = "i", value = -1}, {tag = "i", value = -1}, {tag = "i", value = note}, {tag = "i", value = velocity}})
            )
        end
        osc_renoise_send_note_off = function(note)
            client:send(
                renoise.Osc.Message("/renoise/trigger/note_off", {{tag = "i", value = -1}, {tag = "i", value = -1}, {tag = "i", value = note}})
            )
        end
    else
        client = nil
        socket_error = nil
        osc_renoise_send_note_on = no_op
        osc_renoise_send_note_off = no_op
    end
end
return ____exports
