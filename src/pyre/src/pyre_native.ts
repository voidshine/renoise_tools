// Interface with native pyre.dll modules. PyreNative class wraps calls with necessary
// garbage collection.

import { DrawCommand } from "./engine/draw";

// NOTE: mlua contains a bug that apparently leaks 104 bytes per handler call.
//  For example, custom sum(1, 2) correctly returns 3, and everything is fine as
//  long as collectgarbage() gets called once in a while, but if no explicit
//  collectgarbage() happens then Lua runtime eventually runs out of memory and crashes.
//  This is possibly a bug in mlua logic or may be a result of differences in the
//  Lua implementations. Renoise statically links Lua; so does pyre.dll via mlua.

// In theory, Renoise detects the .dll file in the tool directory, with `.\?.dll` at
// the start of normal package.cpath -- but in practice, it seems unable to load the
// module from there unless we give it the full explicit path.
// TODO: Consider Linux, etc.
_G.package.cpath = `${renoise.tool().bundle_path}/?.dll;${_G.package.cpath}`;

// This doesn't return a module; it initializes the dll.
require('pyre');

// Now we can load native pyre modules.
// const pyre_led: PyreLed = require('pyre.led');
require('pyre.led');
declare global {
    const pyre_led: PyreLed;
}

export const PyreFonts = {
    FontTiny1: {
        handle: 0,
        height: 6,
    },
    FontTiny2: {
        handle: 1,
        height: 12,
    },
    MegamanMono: {
        handle: 2,
        height: 10,
    },
    Megaman: {
        handle: 3,
        height: 10,
    },
}

/** @noSelf */
interface PyreLed {
    // Must be called when the tool/module will be unloaded, to clean up native managed resources.
    shutdown(): void;

    // Log through the native module's logging system.
    log(msg: string): void;

    // Loads an image file as a userdata object with metatable index access; returns null on failure.
    // Note, we can treat it as a number[] for simplicity.
    // load_image_sysex(filename: string): LuaUserdata | null;
    load_image_sysex(filename: string): number[] | null;

    // Gets full internal LED state, ready to send as MIDI sysex.
    get_full_led_sysex(device_index: number): number[];

    // Gets incremental LED state, ready to send as MIDI sysex. Returns null if no update needed.
    get_led_update_sysex(device_index: number, model: LedRenderModel): number[] | null;

    // Takes tool directory path so a hash of code can be computed.
    get_version(tool_path: string): string;
}

// This is the model that the native module uses to decide what to render on the LED display.
// Identical models result in pixel-for-pixel identical bitmaps.
export class LedRenderModel {
    draw_commands: DrawCommand[] = [];

    clone() {
        // TODO
        return this;
    }
}

export class PyreNative {
    shutdown() {
        print("pyre_led.shutdown()");
        pyre_led.shutdown();
    }

    load_image_sysex(filename: string): number[] | null {
        //const data = os.clock() % 1 < 0.5 ? pyre_led.load_image_sysex(filename) : pyre_led.get_full_led_sysex(0); // pyre_led.load_image_sysex_table(filename);
        const t = os.clock();
        const data = pyre_led.load_image_sysex(filename);
        this.t_sum += os.clock() - t;
        if (!data) {
            return null;
        }
        // Copy burns about a millisecond for full screen; could probably optimize, bypassing safety mechanisms in mlua.
        // const s = os.clock();
        const copy = data!.slice();
        // const e = os.clock();
        // print(e - s);
        return copy;
    }

    get_led_update_sysex(fire_index: number, model: LedRenderModel): number[] | null {
        const t = os.clock();
        const data = pyre_led.get_led_update_sysex(fire_index, model);
        this.t_sum += os.clock() - t;
        if (!data) {
            return null;
        }
        return data.slice();
    }

    t_sum = 0;
    get_time() {
        const t = this.t_sum;
        this.t_sum = 0;
        return t;
    }

    get_version() {
        // Seemingly, Renoise sets the current working directory properly for the tool.
        return pyre_led.get_version(".");
    }
}
