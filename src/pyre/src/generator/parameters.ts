import { FIRE_GRID_WIDTH } from '../engine/fire_defs';
import { Parameter } from '../engine/knob';
import { RENOISE_MIDI } from '../engine/common';
import { DivisionSpec, TrackModel } from './generator';

export interface ILayerGenerateEuclidean {
    get_track_model(): TrackModel | null;
    get_selected_layer(): number;
    mark_note(note: number): void;
}

export abstract class DivisionParameter implements Parameter {
    // Avoid lots of constructor boilerplate by letting these get set in client code.
    layer?: ILayerGenerateEuclidean;

    default_value: number;
    min_value: number;
    max_value: number;

    /** @noSelf */
    get_with: (division: DivisionSpec) => number;
    /** @noSelf */
    set_with: (division: DivisionSpec, value: number) => void;

    constructor(min: number, max: number, get_with: (division: DivisionSpec) => number, set_with: (division: DivisionSpec, value: number) => void) {
        this.default_value = min;
        this.min_value = min;
        this.max_value = max;
        this.get_with = get_with;
        this.set_with = set_with;
    }

    get() {
        const track_model = this.layer!.get_track_model();
        if (track_model) {
            const division = track_model.division_specs[this.layer!.get_selected_layer()];
            return this.get_with(division);
        } else {
            return this.default_value;
        }

    }
    set(value: number) {
        const track_model = this.layer!.get_track_model();
        if (track_model) {
            const division = track_model.division_specs[this.layer!.get_selected_layer()];
            this.set_with(division, value);
            division.clean();
            track_model.apply_division_specs();
            track_model.is_dirty = true;
        }
    }
    get_text() {
        return this.get().toString();
    }
}

export class ParameterStepSize extends DivisionParameter {
    constructor() {
        super(1, FIRE_GRID_WIDTH, d => d.step_size, (d, v) => { d.step_size = v; });
    }
}

export class ParameterTimeBase extends DivisionParameter {
    constructor() {
        super(1, FIRE_GRID_WIDTH, d => d.time_base, (d, v) => { d.time_base = v; });
    }
}

export class ParameterDelay extends DivisionParameter {
    constructor() {
        super(0, FIRE_GRID_WIDTH - 1, d => d.delay, (d, v) => { d.delay = v; });
    }
}

export class ParameterStepCount extends DivisionParameter {
    constructor() {
        super(1, FIRE_GRID_WIDTH, d => d.step_count, (d, v) => { d.step_count = v; });
    }
}

export class ParameterPulseCount extends DivisionParameter {
    constructor() {
        super(1, FIRE_GRID_WIDTH, d => {
            this.max_value = d.step_count;
            return d.pulse_count;
        }, (d, v) => { d.pulse_count = v; });
    }
}

export class ParameterPhase extends DivisionParameter {
    constructor() {
        super(0, FIRE_GRID_WIDTH, d => {
            // Always keep max value up to date.
            this.max_value = d.step_count - 1;
            return d.phase;
        }, (d, v) => { d.phase = v; });
    }
}

export class ParameterPitch extends DivisionParameter {
    constructor() {
        super(RENOISE_MIDI.NOTE_MIN, RENOISE_MIDI.NOTE_MAX, d => d.pitch, (d, v) => {
            d.pitch = v;
            // this.layer!.note_grid.model.marked_note = v;
            this.layer!.mark_note(v);
        });
    }
}

export class ParameterGate extends DivisionParameter {
    constructor() {
        super(0, FIRE_GRID_WIDTH - 1, d => d.gate, (d, v) => { d.gate = v; });
    }
}

export class ParameterVelocity extends DivisionParameter {
    constructor() {
        super(0, FIRE_GRID_WIDTH - 1, d => d.velocity_index, (d, v) => { d.velocity_index = v; });
    }
}

export class ParameterVelocityDelta extends DivisionParameter {
    constructor() {
        super(0, FIRE_GRID_WIDTH - 1, d => d.velocity_delta_index, (d, v) => { d.velocity_delta_index = v; });
    }
}

export class ParameterVelocityRandom extends DivisionParameter {
    constructor() {
        super(0, FIRE_GRID_WIDTH - 1, d => d.velocity_random, (d, v) => { d.velocity_random = v; });
    }
}
