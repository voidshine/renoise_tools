import { FIRE_GRID_WIDTH } from "../engine/fire_defs";
import { RENOISE_MIDI } from "../engine/common";

// Allocating pools of objects for reuse in advance can theoretically improve performance, especially
// if the pool is of sufficient size so that memory access benefits from cache locality. In practice,
// the gains seem minor but are still worth it to avoid lots of garbage collection by Lua runtime.
interface Construct<T> {
    new(): T;
}
class Pool<T> {
    ctor: Construct<T>;
    items: T[] = [];
    capacity = 0;
    count = 0;

    constructor(ctor: Construct<T>, capacity: number) {
        this.ctor = ctor;
        this.capacity = capacity;
        while (capacity > 0) {
            this.items.push(new this.ctor());
            capacity--;
        }
    }

    reset() {
        this.count = 0;
    }

    take() {
        // const c = new this.ctor();
        // this.count++;
        // this.items[this.count - 1] = c;
        // return c;

        if (this.capacity <= this.count) {
            print(`PUSH @ ${this.ctor.name}`);
            this.items.push(new this.ctor());
            this.capacity++;
        }
        this.count++;
        return this.items[this.count - 1];
    }
}

export class DivisionSpec {
// class DivisionSpec extends ModelLayer {
    // __eq(rhs: any) { return super.__eq(rhs); }

    // Determine number OF children.
    step_count: number = 1;
    pulse_count: number = 0;

    // Below values will be used BY children...

    time_base: number = 1;

    delay: number = 0;

    step_size: number = 1;

    // A value in the range [0, step_count) used as the initial accumulator value for distribution.
    phase: number = 0;

    // Index in range [0, 15] for easy control.
    // Bipolar about center 7, for greater control with layers.
    velocity_index: number = 7;

    // Index 7 means delta of zero...effective deltas possible are 0-7=-7 to 15-7=+8
    velocity_delta_index: number = 7;

    // Amount of randomization to apply.
    velocity_random: number = 0;

    // MIDI note number
    pitch: number = 60;

    // Number of lines
    gate: number = 0;

    is_occupied_at(x: number) {
        assert(this.phase >= 0 && this.phase < this.step_count);
        return x >= this.step_count ? false :
            (((x * this.pulse_count + this.phase) % this.step_count) < this.pulse_count);
    }

    clean() {
        assert(this.step_count > 0);
        this.pulse_count = cLib.clamp_value(this.pulse_count, 0, this.step_count);
        this.phase = cLib.clamp_value(this.phase, 0, this.step_count - 1);
    }
}

class GenerationState {
    child_index: number = 0;
    pitch: number = 0;
    velocity: number = 0;
    division: Readonly<DivisionSpec> = null as any;

    delta_velocity() {
        return this.division.velocity_delta_index - 7;
    }

    set_from(division: DivisionSpec) {
        this.division = division;
        // TODO: Map velocities using a track-wide mapping.
        this.velocity = 64 + (division.velocity_index - 7) * 8;
        this.pitch = division.pitch;
    }    

    // Mutate this state, using given relations.
    combine(parent: GenerationState, previous: GenerationState | null) {
        // TODO: Have some fun here!

        this.child_index = previous ? previous.child_index + 1 : 0;
        // this.pitch = cLib.clamp_value(parent.pitch + (this.pitch - 60), RENOISE_MIDI.MIN_NOTE, RENOISE_MIDI.MAX_NOTE);
        this.velocity = parent.velocity + (this.velocity - 64) + parent.delta_velocity() * this.child_index;

        if (parent.division.velocity_random > 0) {
            const range = parent.division.velocity_random * 4; // Up to +/- 60 shift
            this.velocity += math.random(-range, range);
        }

        // print(`after combine ${lunajson.encode(this)}`);
    }

    add_note(output: DerivedTrackOutput, start_line: number) {
        const d = this.division;
        if (d.gate > 0) {
            output.add_note(start_line + d.delay * d.time_base, d.gate * d.time_base, this.pitch, this.velocity);
        }
    }
}

// Steps form a tree structure. The root is a single step occupying the full pattern length.
// It is then divided into a given number of child steps, some of which are occupied.
// class Step extends ModelLayer {
class Step {
    // TODO: Find out why this is such a huge performance hit.
    // __eq(rhs: any) { return super.__eq(rhs); }
    // __eq(rhs: any) { return this.division == rhs.division; }

    // Specifies how child steps get distributed.
    division: DivisionSpec = new DivisionSpec();

    // Pulses are steps with content.
    pulses: Step[] = [];// new ModelLayer() as any as [];

    constructor() {
        // super();
    }

    apply_division_spec(division: DivisionSpec, level: number) {
        // print(`level ${level} = ${lunajson.encode(division)}`);
        if (level == 0) {
            // Apply here.
            this.division = division;
            while (this.pulses.length > division.pulse_count) {
                this.pulses.pop();
            }
            while (this.pulses.length < division.pulse_count) {
                this.pulses.push(new Step());
            }
        } else {
            // Pass down to children.
            this.pulses.forEach(pulse => {
                pulse.apply_division_spec(division, level - 1);
            });
        }
    }

    // end_line is inclusive for final OFF event
    generate(output: DerivedTrackOutput, parent_state: GenerationState, previous_state: GenerationState | null, start_line: number, end_line: number): GenerationState {
        // if (parent_state.division.gate > 0) {
            // output.add_note(start_line, parent_state.division.gate, parent_state.pitch, parent_state.velocity);
        // }
        parent_state.add_note(output, start_line);

        // print(`out ${start_line} ${lunajson.encode(this.division)}`);
        const current_state = output.add_state(this.division);
        current_state.combine(parent_state, previous_state);
        if (this.division.pulse_count > 0) {
            const step_size = this.division.time_base * this.division.step_size;
            let pulse_index = 0;
            let child_previous_state = null;
            for (let i = 0; i < this.division.step_count; i++) {
                const child_start_line = start_line + i * step_size;
                if (child_start_line >= end_line) {
                    break;
                }
                if (this.division.is_occupied_at(i)) {
                    // TODO: Apply gating for end_line.
                    child_previous_state = this.pulses[pulse_index].generate(output, current_state, child_previous_state, child_start_line, end_line);
                    pulse_index++;
                }
            }
        }

        return current_state;
    }
}

class NoteEvent {
    // Line values (could be fractional with delay).
    start: number = 0;
    duration: number = 0;
    pitch: number = 0;
    velocity: number = 0;

    // constructor(start: number, duration: number, velocity: number) {
    //     this.start = start;
    //     this.duration = duration;
    //     this.velocity = velocity;
    // }

    // The end line gets an output, generally: an OFF event. So the range is [start, end()] inclusive.
    end() {
        return this.start + this.duration;
    }
}

// A track model binds to a specific track to control its data.
// For efficiency (especially clearing) it is best not to mix manual user-controlled columns
// with generated columns. All columns on the track are specified by the track model.
// class TrackModel extends ModelLayer {
export class TrackModel {
    // __eq(rhs: TrackModel) { return super.__eq(rhs); }
    // // __eq(rhs: TrackModelEuclid) {
    // //     return this.track_name == rhs.track_name && this.root == rhs.root && this.division_specs == rhs.division_specs;
    // // }

    // Require tracks to include [gen] in the name, and/or maybe [euclidean]
    track_name: string;
    
    is_dirty = true;

    root: Step = new Step();

    // Specify how to divide nodes at each level of the tree.
    // TODO: Let steps override their own division.
    // division_specs: DivisionSpec[] = new ModelLayer() as any as [];
    division_specs: DivisionSpec[] = [];

    initial_division_spec = new DivisionSpec();
    initial_parent_state = new GenerationState();
    // initial_previous_state = new GenerationState();

    seed: number = math.random(100000);

    constructor(track_name: string) {
        // super();

        this.initial_parent_state.set_from(this.initial_division_spec);
        // this.initial_previous_state.set_from(this.initial_division_spec);

        this.track_name = track_name;

        this.division_specs.push(new DivisionSpec());
        this.division_specs.push(new DivisionSpec());
        this.division_specs.push(new DivisionSpec());
        this.division_specs[0].pulse_count = 1;
        this.division_specs[0].time_base = 16;
        this.division_specs[1].pulse_count = 1;
        this.division_specs[1].time_base = 4;
        this.division_specs[2].pulse_count = 1;
        this.division_specs[2].time_base = 1;
        this.division_specs[2].gate = 1;
        this.apply_division_specs();
    }

    apply_division_specs() {
        // print(`apply_division_specs`);
        this.division_specs.forEach((division, i) => {
            this.root.apply_division_spec(division, i);
        });
    }

    // end_line is inclusive for final OFF event
    fill_output(output: DerivedTrackOutput, start_line: number, end_line: number) {
        output.reset();
        math.randomseed(this.seed);
        // this.root.generate(output, this.initial_parent_state, this.initial_previous_state, start_line, end_line);
        this.root.generate(output, this.initial_parent_state, null, start_line, end_line);
    }

    // Returns false if target track no longer exists.
    write_to_track(reusable_output: DerivedTrackOutput): boolean {
        const track_index = rns.tracks.findIndex(t => t.name == this.track_name);
        if (track_index < 0) {
            return false;
        }
        const pattern = rns.selected_pattern;
        const track = rns.track(track_index);
        const pattern_track = pattern.track(track_index);
        // End line is inclusive for final OFF event.
        this.fill_output(reusable_output, 0, pattern.number_of_lines - 1);
        // print(lunajson.encode(reusable_output));
        reusable_output.fill_track(pattern, track, pattern_track);
        return true;
    }

    print() {
        print(lunajson.encode(this));
    }
}

// This structure is fully determined by a track model.
// For efficiency, the arrays are recycled instead of reallocated.
export class DerivedTrackOutput {
    note_pool: Pool<NoteEvent> = new Pool(NoteEvent, math.pow(FIRE_GRID_WIDTH, 3));
    state_pool: Pool<GenerationState> = new Pool(GenerationState, 512);

    reset() {
        this.note_pool.reset();
        this.state_pool.reset();
    }

    add_note(start: number, duration: number, pitch: number, velocity: number) {
        const note = this.note_pool.take();
        note.start = start;
        note.duration = duration;
        note.pitch = pitch;
        note.velocity = velocity;
        return note;
    }

    add_state(division: DivisionSpec) {
        const state = this.state_pool.take();
        state.set_from(division);
        // print(`${lunajson.encode(state)}`);
        return state;
    }

    // sort_events() {
        // Insertion sort: good for mostly sorted data.
        // for i = 2:n,
        //     for (k = i; k > 1 and a[k] < a[k-1]; k--)
        //         swap a[k,k-1]
        //     → invariant: a[1..i] is sorted
        // end        

        // Not strictly necessary with the fill_track algorithm below.
        // TODO: Sorting will make usage of columns potentially more efficient.
        // Better yet, just use a BST from the start. :)
    // }

    fill_track(pattern: renoise.Pattern, track: renoise.Track, pattern_track: renoise.PatternTrack) {
        // this.sort_events();

        const lines = pattern_track.lines;

        // Take instrument from top-left note column instrument_value, and re-write after clear.
        // const first = pattern_track.line(0).note_column(0);
        const first = lines[0].note_column(0);
        let instrument = first.instrument_value;
        if (instrument == 255) {
            // Empty. Use current.
            instrument = rns.selected_instrument_index;
        }

        pattern_track.clear();
        first.instrument_value = instrument;

        // TODO: How does JavaScript (or Lua) efficiently initialize sized arrays?
        const filled_until: number[] = [];
        for (let i = 0; i < track.visible_note_columns; i++) {
            filled_until.push(0);
        }

        //const limit = pattern_track.lines.length;
        const limit = pattern.number_of_lines;
        let used_columns = 0;
        for (let i = 0; i < this.note_pool.count; i++) {
            const event = this.note_pool.items[i];
            if (event.end() < limit) {
                let column_index = filled_until.findIndex(v => v <= event.start);
                if (column_index < 0 && track.visible_note_columns >= 12) {
                    renoise.app().show_status("Warning! Max polyphony exceeded. Some note events are dropped.");
                } else {
                    if (column_index < 0) {
                        // Need another column.
                        track.visible_note_columns = track.visible_note_columns + 1;
                        assert(track.visible_note_columns == filled_until.length + 1);
                        column_index = filled_until.length;
                        filled_until.push(0);
                    }
                    used_columns = math.max(used_columns, column_index + 1);
                    filled_until[column_index] = event.end() + 1;
                    // let column = pattern_track.line(event.start).note_column(column_index);
                    let column = lines[event.start].note_column(column_index);
                    column.note_value = event.pitch;
                    column.instrument_value = instrument;
                    column.volume_value = cLib.clamp_value(event.velocity, 1, 127);
                    // column = pattern_track.line(event.end()).note_column(column_index);
                    column = lines[event.end()].note_column(column_index);
                    column.note_value = RENOISE_MIDI.NOTE_VALUE_OFF;
                }
            }
        }
        track.visible_note_columns = math.max(1, used_columns);

        // TODO: Effects. :)
        track.visible_effect_columns = 0;
    }
}
