// This module contains various knob implementations mappable by Layer.set_knob_handler.

import { MIDI, build_modulation_wheel_coarse, build_modulation_wheel_fine, build_pitch_bend} from './common';
import { step_track_column } from './utility';
import { AltShiftState } from '../layers/layer_common';

// Number of seconds before quantizing knob fractional accumulator resets.
const QUANTIZER_COOLDOWN = 1.5;

export interface Knob {
    on_press(): void;
    on_release(): void;
    on_turn(delta: number): void;

    display_name: string;
    display_text(): string;
}

export interface KnobToggling extends Knob {
    on_toggled(active: boolean): void;
}

export class KnobValue implements Knob {
    display_name: string;
    default_value: number;
    min_value: number;
    max_value: number;
    sensitivity: number;
    _value: number;
    // value: any;

    constructor(display_name: string, default_value: number, min_value: number, max_value: number, sensitivity: number) {
        this.display_name = display_name;
        this.default_value = default_value;
        this.min_value = min_value;
        this.max_value = max_value;
        this.sensitivity = sensitivity;

        this._value = default_value;
        // this.value = property(this.get_value, this.set_value)
    }

    display_text() {
        return this.display_name;
    }

    on_change(new_value: number, old_value: number) {
        // rprint("Knob [" .. this.display_name .. "] changed from " .. tostring(old_value) .. " to " .. tostring(new_value))
    }

    // Handles knob touch and press events: the left knobs are "pressed" very, very lightly. :)
    on_press() {
    }

    on_release() {
    }

    // delta is signed integer indicating number of clicks clockwise (positive) or counterclockwise (negative)
    on_turn(delta: number) {
        this.set_value(this.get_value() + delta * this.sensitivity);
    }

    get_value() {
        return this._value;
    }

    set_value(value: number) {
        const old_value = this.get_value();
        const new_value = cLib.clamp_value(value, this.min_value, this.max_value);
        if (new_value != old_value) {
            this._value = new_value;
            this.on_change(new_value, old_value);
        }
    }
}

export class KnobAutoReset extends KnobValue {
    // Can't seem to leave this to the metatable for luabind class
    // constructor(...) {
    //     super(unpack(arg))
    // }

    on_release() {
        this.set_value(this.default_value);
    }
}

// A knob that passes calls through to one of its children knobs, depending on
// alt and shift states.
export class KnobAlt implements Knob {
    display_name: string;
    knobs: Knob[];
    target: Knob;
    source_model: AltShiftState;
    constructor(source_model: AltShiftState, knobs: Knob[]) {
        this.display_name = `${knobs.map(knob => knob.display_name).join('|')}`;
        this.knobs = knobs;
        this.target = knobs[0];
        this.source_model = source_model;
    }

    display_text() {
        this.select_target();
        return this.target.display_text();
    }

    index(): number {
        // 0 = none
        // 1 = alt
        // 2 = shift
        // 3 = alt + shift
        // out of knobs.length range --> none
        const i = (this.source_model.alt ? 1 : 0) + (this.source_model.shift ? 2 : 0);
        return i < this.knobs.length ? i : 0;
    }

    // TODO: If changing targets while pressed, may want to handle press/release for alternates so nothing gets missed.
    // As long as alternates don't have meaningful press/release behavior (a good idea in general for simplicity's sake), this shouldn't matter.
    select_target() {
        this.target = this.knobs[this.index()];
    }

    // Handles knob touch and press events: the left knobs are "pressed" very, very lightly. :)
    on_press() {
        this.select_target();
        this.target.on_press();
    }

    on_release() {
        this.select_target();
        this.target.on_release();
    }

    // delta is signed integer indicating number of clicks clockwise (positive) or counterclockwise (negative)
    on_turn(delta: number) {
        this.select_target();
        this.target.on_turn(delta);
    }
}

// Uses a faux model to support holding alternate knobs until cycle is manually called.
export class KnobLatch extends KnobAlt {
    constructor(knobs: KnobToggling[]) {
        const faux_model = { alt: false, shift: false };
        super(faux_model, knobs);
    }
    cycle() {
        this.source_model.alt = !this.source_model.alt;

        const current = this.knobs[this.index()];
        this.knobs.forEach(knob => (knob as KnobToggling).on_toggled(knob == current));
    }
}

// Accumulates change in primary value and applies quantized changes via method call.
export class KnobQuantizing extends KnobValue {
    quantum: any;
    last_change_time: number;
    constructor(display_name: string, sensitivity: number, quantum: number) {
        super(display_name, 0, -100, 100, sensitivity);
        this.quantum = quantum;
        this.last_change_time = os.clock();
    }

    on_change(new_value: number, old_value: number) {
        // Apply cooldown
        const last = this.last_change_time;
        this.last_change_time = os.clock();
        if (this.last_change_time - last > QUANTIZER_COOLDOWN) {
            this._value = this._value - old_value;
            // print('reset ', this._value)
        }

        // Detect steps
        // const steps = this._value - (this._value % this.quantum)
        // print(this._value)
        const steps = this._value - math.fmod(this._value, this.quantum);
        if (steps != 0) {
            this.on_step(steps)
            this._value = this._value - steps
            // print(" -> ", this._value)
        }
    }

    on_step(steps: number) {
    }
}

export class KnobVelocity extends KnobValue {
    constructor() {
        // Note: velocity 0 is often treated as off, so keep 1 as the minimum playable velocity.
        super('Velocity', 64, 1, 127, 1);
    }
}

export class KnobPitchWheel extends KnobAutoReset {
    constructor() {
        super('Pitch Wheel', 0.0, -1.0, 1.0, 0.02);
    }

    on_change(new_value: number, old_value: number) {
        driver.generated_midi.send_midi(build_pitch_bend(new_value));
    }
}

export class KnobModulationWheel extends KnobAutoReset {
    constructor() {
        super('Modulation Wheel', 0.0, 0.0, 1.0, 0.01)
    }
    on_change(new_value: number, old_value: number) {
        driver.generated_midi.send_midi(build_modulation_wheel_coarse(new_value))
        driver.generated_midi.send_midi(build_modulation_wheel_fine(new_value))
    }
}

export class KnobChannelPressure extends KnobAutoReset {
    constructor() {
        super('Channel Pressure', 0.0, 0.0, 1.0, 0.03)
    }
    on_change(new_value: number, old_value: number) {
        driver.generated_midi.send_midi( [MIDI.CHANNEL_PRESSURE, math.floor(127.0 * new_value), 0, ] );
    }
}

export class KnobTime extends KnobQuantizing {
    constructor(sensitivity: number) {
        // Subtle indicator for fast or slow movement.
        super(`Time Select${sensitivity < driver.options.knob_sensitivity(false, false) ? "~" : ''}`, sensitivity, 1);
    }
    on_step(steps: number) {
        // rns.selected_line_index = cLib.clamp_value(rns.selected_line_index + steps, 1, 64)
        rns.selected_line_index = cLib.clamp_value(rns.selected_line_index + steps, 0, rns.selected_pattern.number_of_lines - 1);
    }
}

export class KnobColumnSelect extends KnobQuantizing {
    whole_tracks: boolean;
    note_columns: boolean;
    constructor(whole_tracks: boolean, note_columns: boolean, sensitivity: number) {
        super(whole_tracks ? 'Track Select' : 'Column Select', sensitivity, 1);
        this.whole_tracks = whole_tracks;
        this.note_columns = note_columns;
    }
    on_step(steps: number) {
        step_track_column(steps, this.whole_tracks, false, this.note_columns);
    }
}

export class KnobInstrumentSelect extends KnobQuantizing {
    constructor() {
        super('Instrument Select', driver.options.knob_sensitivity(false, true), 1);
    }
    on_step(steps: number) {
        rns.selected_instrument_index = cLib.clamp_value(rns.selected_instrument_index + steps, 0, rns.instruments.length - 1);
    }
}

export class KnobQuantizingClosure extends KnobQuantizing {
    /** @noSelf */
    handler: (steps: number) => void;
    constructor(name: string, sensitivity: number, handler: (steps: number) => void) {
        super(name, sensitivity, 1);
        this.handler = handler;
    }
    on_step(steps: number) {
        this.handler(steps);
    }
}

export interface Parameter {
    default_value: number;
    min_value: number;
    max_value: number;
    get(): number;
    set(value: number): void;
    get_text(): string;
}

const SPACES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16].map(i => string.rep(' ', i));

// Knob that applies value to/from a property.
export class KnobQuantizedParameter extends KnobQuantizing {
    parameter: Parameter;
    constructor(display_name: string, sensitivity: number, parameter: Parameter) {
        super(display_name, sensitivity, 1);
        this.parameter = parameter;
    }

    display_text() {
        const label_text = super.display_text();
        const parameter_text = this.parameter.get_text();
        // TODO: Clean this up; some kind of layout algorithm might be worth it.
        const spaces = SPACES[16 - (label_text.length + parameter_text.length)] || ':';
        return label_text + spaces + parameter_text;
    }

    on_step(steps: number) {
        this.parameter.set(cLib.clamp_value(this.parameter.get() + steps, this.parameter.min_value, this.parameter.max_value));
    }
}
