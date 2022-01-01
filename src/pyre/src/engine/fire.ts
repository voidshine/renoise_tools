// require('engine/fire_defs')
// // require('engine/fire_state')
// require('engine/midi')
// require('engine/render_context')
// require('layers/mode_selector')

import { MIDI } from './common';
import { FireState } from './fire_state';
import { FireConfig } from './options';
import { RenderContext } from './render_context';
// import { Layer } from './layer';
import { ModeSelector } from '../layers/mode_selector';
import { Midi } from './midi';

export class Fire {
    fire_device_index: number;
    fire_config: FireConfig | null;
    state_on_device: FireState | null;
    state: FireState;
    is_active: boolean;
    midi: Midi;
    render_context: RenderContext;
    root_layer: ModeSelector; // Layer;

    // TODO: TEMP TEST
    // copy: number[];

    // fire_device_index is 1 for the first Fire, 2 for the second, etc.
    // This determines the set of MIDI ports and mode bindings according to configuration.
    constructor(fire_device_index: number) {
        this.fire_device_index = fire_device_index;

        // fire_config may be null when not running or not yet configured.
        this.fire_config = null;

        this.state_on_device = new FireState(null);
        this.state = new FireState(null);
        this.is_active = false;

        this.midi = new Midi(this);
        this.render_context = new RenderContext(this.state);

        // TODO: Fix this hack. We're assuming init before use.
        this.root_layer = null as unknown as ModeSelector;

        // this.copy = pyre_native.load_image_sysex("heart.bmp");
    }

    start(fire_config: FireConfig | null) {
        this.fire_config = fire_config;
        if (this.fire_config && this.fire_config.enabled) {
            this.root_layer = new ModeSelector(this.fire_config.mode_bindings, this.fire_device_index);
            // this.root_layer.fire_device_index = ;
            oprint(`Fire #${this.fire_device_index} config changed`);
            //rprint({this.fire_device_index, this.fire_config, this.root_layer})    
            this.midi.connect(this.fire_config.midi_input, this.fire_config.midi_output);
        } else {
            this.midi.disconnect();
        }
    }

    on_fire_config_changed(fire_config: FireConfig | null) {
        if (this.is_active) {
            this.clear_now();
        }

        // This happens infrequently. Just restart for simplicity.
        this.start(fire_config);
    }

    clear_now() {
        this.state.clear();
        this.set_device_state(true);
    }

    on_midi_connection_changed(connected: boolean) {
        this.is_active = connected;
        oprint(`Fire #${this.fire_device_index} midi ${(connected ? "yes" : "no")}`);
        if (connected) {
            // Do an early idle cycle to ensure layers update their models before first render
            // could be called by an event handler.
            this.root_layer.all_on_idle();
            this.render();
            this.set_device_state(true);

            // this.midi.send(this.copy);
        }
    }

    on_midi_in(message: any) {
        // rprint({["Fire #" .. this.fire_device_index .. " midi_in: "] = message})
        if (message[1] == MIDI.NOTE_ON) {
            // Note ON
            this.root_layer.all_on_midi_note(message[2], message[3]);
         } else if (message[1] == MIDI.NOTE_OFF) {
            // Note OFF
            this.root_layer.all_on_midi_note(message[2], null);
         } else if (message[1] == MIDI.CONTROL_CHANGE) {
            // Control Change
            this.root_layer.all_on_midi_cc(message[2], message[3]);
        }

        // Models often change as a result of event handlers, so don't wait until next idle to render changes on device.
        this.render();
        this.set_device_state(false, true);
    }

    render() {
        this.render_context.on_start();
        this.root_layer.all_render(this.render_context);
        this.render_context.on_finish();
    }

    // full_update true sets full device state, without regard for what may be on it.
    // With quick true, some output is intentionally bypassed for speed. Quick mode rendering is done
    //  in MIDI event handlers to get immediate visual response on pads, lights, etc. but LED updates should
    //  not be done because pumping out a bunch of sysex during a MIDI event handler can result in missed
    //  MIDI messages. For example, a note-off event might be missed if the note-on event is still busy
    //  updating the LED with a huge sysex output.
    set_device_state(full_update: boolean, quick = false) {
        // rprint(`set_device_state for Fire #${this.fire_device_index}`);
        let from = null;
        if (!full_update) {
            from = this.state_on_device;
        }
        for (const message of this.state.get_midi_messages(this.fire_device_index, from, quick)) {
            this.midi.send(message);
        }
        //this.state_on_device = table.rcopy(this.state)
        this.state_on_device = this.state.clone();
    }

    t_start = 0;
    t_idle = 0;
    t_render = 0;
    t_end = 0;
    t_threshold = 0.001;
    on_idle() {
        // Clear time accumulator so it doesn't accumulate across frames.
        pyre_native.get_time();

        this.t_start = os.clock();
        this.root_layer.all_on_idle();
        this.t_idle = os.clock();
        this.render();
        this.t_render = os.clock();
        this.set_device_state(false);        
        this.t_end = os.clock();

        const t = this.t_end - this.t_start;
        // Notify about slow frames, but don't bog down with lots of print calls.
        if (t > this.t_threshold) {
            print(`Slow frame: ${t} = idle:${this.t_idle - this.t_start} + render:${this.t_render - this.t_idle} + device:${this.t_end - this.t_render} [native.t_sum=${pyre_native.get_time()}]`);
            this.t_threshold = t;
        }
    }
}
