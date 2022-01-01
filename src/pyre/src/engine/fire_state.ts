// FireState holds full visible state of a physical Fire device, and offers methods to update it using MIDI.
// From a known state, further updates can be sent as a delta for efficiency.

// require('engine/fire_defs')
// require('engine/fire_grid_state')
// require('engine/fire_led_state')

import * as defs from './fire_defs';
import { FireGridState } from './fire_grid_state';
import { FireLedState } from './fire_led_state';
import { Color } from './color';
import { LedRenderModel } from '../pyre_native';
import { DrawClear } from './draw';

export class FireState {
    grid: FireGridState;

    // Avoid array TypeScript-vs-Lua indexing off by one issues.
    // lights: Color[];
    //lights: { [key: number]: Color; };
    lights: DirectIndex<Color>;

    quad_light: number;
    
    // Note: Lua rendering and sysex conversion is extremely slow compared to the Rust .dll module,
    //  so this isn't actually used.
    led_lua: FireLedState;

    // This is the model passed to the native module for fast LED rendering.
    led_model: LedRenderModel

    // copy_from may be null
    constructor(copy_from: FireState | null) {
        if (copy_from) {
            this.grid = copy_from.grid.clone();
            this.lights = table.rcopy(copy_from.lights);
            this.quad_light = copy_from.quad_light;
            this.led_lua = copy_from.led_lua.clone();
            this.led_model = copy_from.led_model.clone();
        } else {
            this.grid = new FireGridState(null);
            this.lights = [];
            this.quad_light = 0;
            this.led_lua = new FireLedState(null);
            this.led_model = new LedRenderModel();
            this.clear();
        }
    }

    clone() {
        // Failed with: *** [string "// create or convert a table to an object t..."]:66: bad argument #1 to 'table.copy' (table expected, got 'FireState')
        //  ... so trying with alternative constructor instead.
        //const instance = table.rcopy(this)
        return new FireState(this);
    }

    __eq(rhs: FireState) {
        // TODO: lights and all
        return this.grid == rhs.grid;
    }

    clear() {
        this.grid.clear();

        // lights use note values as keys, for efficiency
        for (const key in defs.FIRE_LIGHT) {
            const note = (defs.FIRE_LIGHT as any)[key];
            this.lights[note] = Color.black();
        }

        this.quad_light = 0;

        this.led_model.draw_commands = [DrawClear.INSTANCE];
    }

    get_midi_messages(fire_index: number, state_on_device: FireState | null, quick: boolean) {
        const messages: MidiMessage[] = [];
        const add = function(e: MidiMessage | null) {
            if (e) {
                // table.insert(messages, e)
                messages.push(e);
            }
        }

        if (state_on_device) {
            add(this.grid.get_sysex(state_on_device.grid));
            if (state_on_device.quad_light != this.quad_light) {
                add(defs.get_midi_quad_light(this.quad_light));
            }
        } else {
            add(this.grid.get_sysex(null));
            add(defs.get_midi_quad_light(this.quad_light));
        }

        for (const key in defs.FIRE_LIGHT) {
            const note = (defs.FIRE_LIGHT as any)[key];
            const color = this.lights[note];
            if (!state_on_device || state_on_device.lights[note] != color) {
                add(defs.get_midi_light(note, color));
            }
        }

        if (!quick) {
            add(this.led_lua.get_sysex());
            add(pyre_native.get_led_update_sysex(fire_index, this.led_model));
        }

        return messages;
    }
}
