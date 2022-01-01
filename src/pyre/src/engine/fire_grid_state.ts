import { Color } from './color';
import * as defs from './fire_defs';

function midi_pad_start() {
    return [ 0xf0, 0x47, 0x7f, 0x43, 0x65, 0x00, 0x00 ];
}

function midi_pad(sysex: MidiMessage, x: number, y: number, color: Color) {
    // const pos = #array + 1
    // array[pos] = y * 16 + x
    // array[pos + 1] = bit.rshift(color[1], 1)
    // array[pos + 2] = bit.rshift(color[2], 1)
    // array[pos + 3] = bit.rshift(color[3], 1)

    sysex.push(y * 16 + x);
    sysex.push(bit.rshift(color.get(1)!, 1));
    sysex.push(bit.rshift(color.get(2)!, 1));
    sysex.push(bit.rshift(color.get(3)!, 1));
}

function midi_pad_end(array: MidiMessage) {
    // const payload_len = #array - 7
    const payload_len = array.length - 7;
    if (payload_len == 0) {
        return;
    }
    // array[6] = bit.rshift(payload_len, 7)
    // array[7] = bit.band(payload_len, 0x7f)
    array[5] = bit.rshift(payload_len, 7);
    array[6] = bit.band(payload_len, 0x7f);
    // array[#array + 1] = 0xf7
    array.push(0xf7);
}

// x and y are zero based, not Lua one-based index values.
function xy_index(x: number, y: number) {
    return 1 + (y * defs.FIRE_GRID_WIDTH + x);
}

export class FireGridState {
    // colors: Color[];
    colors: DirectIndex<Color>;

    // copy_from may be null
    constructor(copy_from: FireGridState | null) {
        if (copy_from) {
            this.colors = table.rcopy(copy_from.colors);
        } else {
            this.colors = [];
            for (let y = 0; y < defs.FIRE_GRID_HEIGHT; y++) {
                for (let x = 0; x < defs.FIRE_GRID_WIDTH; x++) {
                    this.colors[xy_index(x, y)] = Color.black();
                }
            }
        }
    }

    clone() {
        return new FireGridState(this);
    }

    __eq(rhs: FireGridState) {
        // for i = 1, FIRE_GRID_WIDTH * FIRE_GRID_HEIGHT do
        //for (let i = 0; i < defs.FIRE_GRID_WIDTH * defs.FIRE_GRID_HEIGHT; i++) {
        for (const i of forRange(1, defs.FIRE_GRID_WIDTH * defs.FIRE_GRID_HEIGHT)) {
            if (this.colors[i] != rhs.colors[i]) {
                // rprint("NOPE");
                return false;
            }
        }
        // rprint("YEP");
        return true;
    }

    at(x: number, y: number) {
        return this.colors[xy_index(x, y)];
    }

    clear() {
        const black = Color.black();
        // let count = 0;
        for (const color of this.colors) {
            // const color = this.colors[key];
            color.set_from(black);
            // count++;
        }
        // rprint(`count ${count}`);
    }

    // Gets differential update sysex by comparing to grid_on_device.
    // Full update is provided if (grid_on_device is null.
    // May return null if (no update is necessary
    get_sysex(grid_on_device: FireGridState | null) {
        if (this == grid_on_device) {
            // rprint("nil!");
            return null;
        }
        // rprint("FILL!");
        const sysex = midi_pad_start();
        for (let y = 0; y < defs.FIRE_GRID_HEIGHT; y++) {
            for (let x = 0; x < defs.FIRE_GRID_WIDTH; x++) {
                const color = this.at(x, y);
                if (grid_on_device == null || grid_on_device.at(x, y) != color) {
                    midi_pad(sysex, x, y, color);
                }
            }
        }
        midi_pad_end(sysex);
        return sysex;
    }
}
