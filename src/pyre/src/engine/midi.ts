// A specially named port that is equivalent with providing null for a connect parameter.
// Any port not null or named MIDI_PORT_NONE will be considered required for connection.
export const MIDI_PORT_NONE = "None";

export interface MidiHandler {
    on_midi_connection_changed(is_connected: boolean): void;
    on_midi_in(message: MidiMessage): void;
}

export class Midi {
    handler: MidiHandler;
    input_device: renoise.Midi.MidiInputDevice | null;
    output_device: renoise.Midi.MidiOutputDevice | null;
    midi_in_port: string | null;
    midi_out_port: string | null;

    // handler has methods:
    //  on_midi_connection_changed(is_connected)
    //  on_midi_in(message)
    constructor(handler: MidiHandler) {
        this.handler = handler
        this.input_device = null;
        this.output_device = null;
        this.midi_in_port = null;
        this.midi_out_port = null;

        // TODO: how to know when tool is unloaded, for cleanup?
        renoise.Midi.devices_changed_observable().add_notifier(this.on_devices_changed, this)
        // renoise.Midi.devices_changed_observable().add_notifier(() => {this.on_devices_changed();});
    }

    // returns true if (and only if (all required (non-null) ports are connected.
    is_connected() {
        return (this.input_device != null || this.midi_in_port == null) &&
            (this.output_device != null || this.midi_out_port == null);
    }

    on_devices_changed() {
        // TODO: Seems wrong?
        // this.connect(null, null);
    }

    disconnect() {
        if (this.input_device) {
            this.input_device.close();
            this.input_device = null;
        }
        if (this.output_device) {
            this.output_device.close();
            this.output_device = null;
            // this.send = null;
            this.send = Midi.prototype.send;
        }
    }

    // Use strings from available MIDI devices lists. To indicate an in or out isn't needed, use null.
    // null ports are vacuously considered connected.
    connect(midi_in_port: string | null, midi_out_port: string | null) {
        this.disconnect()

        this.midi_in_port = midi_in_port
        this.midi_out_port = midi_out_port
        if (this.midi_in_port == MIDI_PORT_NONE) {
            this.midi_in_port = null
        }
        if (this.midi_out_port == MIDI_PORT_NONE) {
            this.midi_out_port = null
        }
    
        if (this.midi_in_port && table.find(renoise.Midi.available_input_devices(), this.midi_in_port)) {
            this.input_device = renoise.Midi.create_input_device(this.midi_in_port, (message: MidiMessage) => { this.handler.on_midi_in(message) })
        }

        if (this.midi_out_port && table.find(renoise.Midi.available_output_devices(), this.midi_out_port)) {
            this.output_device = renoise.Midi.create_output_device(this.midi_out_port)

            // override send method
            //this.send = (message) => {
            this.send = ((self: any, message: number[]) => {
                // rprint(`connected send: message = ${message.join(',')}`);
                // rprint(`Device ${self.output_device.name} open? ${self.output_device.is_open}`);
                self.output_device!.send(message);
            }) as any;
        }

        if (!this.is_connected()) {
            // Clean the half-connected case.
            this.disconnect();
        }

        this.handler.on_midi_connection_changed(this.is_connected());
    }

    send(message: MidiMessage) {
        // rprint(`disconnected send: message = ${message.join(',')}`);
        // Do nothing (used when not overridden during connect)
        // rprint({"Midi:send", message})
    }
}
