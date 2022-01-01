/** @noSelfInFile */

// Interface to communicate with the Renoise OSC server
// TODO: Can we get the user's OSC options to adapt and inform about config?

import { no_op } from './common';
import {} from './options';
import { NoteOnHandler, NoteOffHandler } from './layer';

// create some handy shortcuts
// const OscMessage = renoise.Osc.Message;
// const OscBundle = renoise.Osc.Bundle;

// open a socket connection to the server
let client: any;
let socket_error: any;

// These are wired up after connection, and unwired on disconnect.
declare global {
    let osc_renoise_send_note_on: NoteOnHandler; 
    let osc_renoise_send_note_off: NoteOffHandler;
}

osc_renoise_send_note_on = no_op as NoteOnHandler;
osc_renoise_send_note_off = no_op as NoteOffHandler;

export interface OscPrefs {
    osc_enabled: boolean;
    osc_address: string;
    osc_port: number;
}

// prefs contains osc_enabled, osc_address and osc_port keys
export function osc_renoise_connect(prefs: OscPrefs) {
    rprint("OSC connect");
    // client, socket_error = renoise.Socket.create_client("localhost", 8086, renoise.Socket.PROTOCOL_UDP)
    // const prefs = options.config.generated_midi
    if (prefs.osc_enabled) {
        [client, socket_error] = renoise.Socket.create_client(prefs.osc_address, prefs.osc_port, renoise.Socket.PROTOCOL.PROTOCOL_UDP);
        if ((socket_error)) {
            renoise.app().show_warning((`Failed to start the OSC client. Error: '${socket_error}'`));
            return
        }

        rprint("OSC connect");

        osc_renoise_send_note_on = function(note: number, velocity: number) {
            // rprint("OSC send on");
            client.send(
                renoise.Osc.Message("/renoise/trigger/note_on", [
                    {tag: "i", value: -1},
                    {tag: "i", value: -1},
                    {tag: "i", value: note},
                    {tag: "i", value: velocity},
                ])
              );
        }
        
        osc_renoise_send_note_off = function(note: number) {
            // rprint("OSC send off");
            client.send(
                renoise.Osc.Message("/renoise/trigger/note_off", [
                    {tag: "i", value: -1},
                    {tag: "i", value: -1},
                    {tag: "i", value: note},
                ])
              );
        }
    } else {
        client = null;
        socket_error = null;
        osc_renoise_send_note_on = no_op;
        osc_renoise_send_note_off = no_op;
    }
}
