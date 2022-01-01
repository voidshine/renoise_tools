import { LayerCommon, ModelCommon } from "./layer_common";
import { RenderContext } from "../engine/render_context";
import { Rect, clock_pulse } from "../engine/utility";
import { FIRE_GRID_WIDTH, FIRE_KNOB, FIRE_LIGHT, FIRE_BUTTON, LIGHT_DARK_RED, FIRE_GRID_HEIGHT } from "../engine/fire_defs";
import { PALETTE } from "../palette";
import { Color } from "../engine/color";
import { LayerNoteGrid } from "./layer_note_grid";
import { DerivedTrackOutput, TrackModel } from "../generator/generator";
import { Parameter, KnobValue, KnobQuantizing, KnobQuantizedParameter } from "../engine/knob";
import { ParameterTimeBase, ParameterDelay, ParameterStepSize, ParameterGate, ParameterStepCount, ParameterPulseCount, ParameterPhase, ParameterVelocity, ParameterVelocityDelta, ParameterVelocityRandom, ParameterPitch, DivisionParameter, ILayerGenerateEuclidean } from "../generator/parameters";
import { FIRE_LED_RECT_FULL } from "../engine/fire_led_state";
import { LayerKnobsSelector, LayerKnobs } from "./layer_knobs_selector";
import { MenuItem } from "../engine/menu";

const palette = PALETTE.GENERATE_EUCLIDEAN;

const SHIFT_SENSITIVITY = 0.15;

function toggle_gen(name: string) {
    return name.startsWith('[gen]') ? name.substr('[gen]'.length) : `[gen]${name}`;
}

class KnobRandomSeed extends KnobQuantizing {
    layer: LayerGenerateEuclidean;
    constructor(layer: LayerGenerateEuclidean) {
        super('Random Seed', SHIFT_SENSITIVITY, 1);
        this.layer = layer;
    }
    on_step(steps: number) {
        const track_model = this.layer.get_track_model();
        if (track_model) {
            track_model.seed += steps * 500;    // Interestingly, the random values don't change much from seed to seed, at least not at all phases of generation. (Some phases seem very stable from seed to seed when seeds are close in value.)
            track_model.is_dirty = true;
        }
    }
}

class KnobLinkedParameter extends KnobQuantizedParameter {
    layer: LayerGenerateEuclidean;
    constructor(layer: LayerGenerateEuclidean, name: string, parameter: DivisionParameter) {
        super(name, SHIFT_SENSITIVITY, parameter);
        this.layer = layer;
        parameter.layer = layer;
    }

    on_press() {
        this.layer.model.held_parameter = this.parameter;
    }
    on_release() {
        this.layer.model.held_parameter = undefined;
    }
}

class KnobNoteParameter extends KnobLinkedParameter {
    on_press() {
        super.on_press();
        this.layer.mark_note(this.parameter.get());
        this.layer.mount_note_grid(true);
    }
    on_release() {
        super.on_release();
        this.layer.mount_note_grid(false);
    }
}

class ModelGenerateEuclidean extends ModelCommon {
    current_track_model: TrackModel | null = null;

    selected_layer: number = 0;

    // Currently held knob parameter, enables quick direct integer set and visualization.
    // Note! This object may go deep, pointing into the entire layer -- so we don't include
    // it in clone with rcopy.
    held_parameter?: Parameter;

    constructor() {
        super();
    }

    // __eq(rhs: any) { return super.__eq(rhs); }
    // __eq(rhs: ModelGenerateEuclidean) {
    //     return this.current_track_model == rhs.current_track_model &&
    //         this.selected_layer == rhs.selected_layer &&
    //         this.parameter_set_index == rhs.parameter_set_index &&
    //         // (this.held_parameter?.get() == rhs.held_parameter?.get());
    //         ((this.held_parameter ? this.held_parameter.get() : null) ==
    //          (rhs.held_parameter ? rhs.held_parameter.get() : null));
    // }

    // clone(): this {
    //     const model = new ModelGenerateEuclidean();
    //     model.current_track_model = this.current_track_model ? this.current_track_model.clone() : null;
    //     model.selected_layer = this.selected_layer;
    //     model.parameter_set_index = this.parameter_set_index;
    //     // Direct copy, not clone!
    //     model.held_parameter = this.held_parameter;
    //     // TODO: this?
    //     return model as this;
    // }
}

export class LayerGenerateEuclidean extends LayerCommon<ModelGenerateEuclidean> implements ILayerGenerateEuclidean {
    // Contains only valid track models, but a key may not be present.
    // track_models: {[track_name: string]: TrackModel | null} = new ModelLayer() as any as {};
    // No need for ModelLayer; always_dirty.
    track_models: {[track_name: string]: TrackModel | null} = {};

    // Only need one write buffer, which can be recycled.
    track_output = new DerivedTrackOutput();

    note_grid = new LayerNoteGrid("Note Grid: Generate Euclidean", new Rect(0, 0, FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT), v => v);

    layer_knobs_selector: LayerKnobsSelector;

    constructor() {
        super(new ModelGenerateEuclidean(), "Generate Euclidean");

        this.always_dirty = true;
        this.note_grid.always_dirty = true;

        this.note_grid.note_handler = (note, velocity) => {
            if (velocity) {
                this.model.held_parameter!.set(note);
            }
        };

        this.layer_knobs_selector = new LayerKnobsSelector([
            new LayerKnobs('Time', [
                new KnobLinkedParameter(this, "Time Base", new ParameterTimeBase()),
                new KnobLinkedParameter(this, "Delay", new ParameterDelay()),
                new KnobLinkedParameter(this, "Step Size", new ParameterStepSize()),
                new KnobLinkedParameter(this, "Gate", new ParameterGate()),
            ]),
            new LayerKnobs('Steps', [
                new KnobLinkedParameter(this, "Step Count", new ParameterStepCount()),
                new KnobLinkedParameter(this, "Pulse Count", new ParameterPulseCount()),
                new KnobLinkedParameter(this, "Phase", new ParameterPhase()),
                new KnobLinkedParameter(this, "Phase", new ParameterPhase()),
                    ]),
            new LayerKnobs('Velocity', [
                new KnobLinkedParameter(this, "Velocity", new ParameterVelocity()),
                new KnobLinkedParameter(this, "Velocity Delta", new ParameterVelocityDelta()),
                new KnobLinkedParameter(this, "Velocity Random", new ParameterVelocityRandom()),
                new KnobRandomSeed(this),
                    ]),
            new LayerKnobs('Pitch', [
                new KnobNoteParameter(this, "Pitch", new ParameterPitch()),
                new KnobNoteParameter(this, "Pitch", new ParameterPitch()),
                new KnobNoteParameter(this, "Pitch", new ParameterPitch()),
                new KnobNoteParameter(this, "Pitch", new ParameterPitch()),
            ]),
        ]);
        this.children = [this.layer_knobs_selector];

        this.set_note_handlers_grid_rect(new Rect(0, 0, FIRE_GRID_WIDTH, 3), (x, y, velocity) => {
            if (!velocity) {
                return;
            }

            const track_model = this.get_track_model();
            if (track_model) {
                const spec = track_model.division_specs[y];
                if (this.model.alt) {
                    // Shift phase.
                    spec.phase = x;
                } else if (this.model.shift) {
                    // Set number of steps
                    spec.step_count = x + 1;
                } else {
                    // Set number of pulses
                    spec.pulse_count = x + 1;
                }
                spec.clean();

                // Apply all, in case child steps are in unfinished state.
                track_model.apply_division_specs();
                track_model.is_dirty = true;
            }
        });
        this.set_note_handlers_grid_rect(new Rect(0, 3, FIRE_GRID_WIDTH, 1), (x, y, velocity) => {
            if (!velocity) {
                return;
            }
            if (this.model.held_parameter) {
                this.model.held_parameter.set(this.model.held_parameter.min_value + x);
            } else {
                const left = FIRE_GRID_WIDTH - this.layer_knobs_selector.knob_layers.length;
                if (x >= left) {
                    //this.hook_parameters(x - left);
                    this.layer_knobs_selector.select(x - left);
                }
            }
        });

        this.set_note_on_handlers({
            [FIRE_BUTTON.RowMute0]: (note, velocity) => { this.model.selected_layer = 0; },
            [FIRE_BUTTON.RowMute1]: (note, velocity) => { this.model.selected_layer = 1; },
            [FIRE_BUTTON.RowMute2]: (note, velocity) => { this.model.selected_layer = 2; },

            [FIRE_BUTTON.GridLeft]: () => {
                // TODO: Constrain to only [gen] tracks.
                xTrack.jump_to_previous_sequencer_track();
            },
            [FIRE_BUTTON.GridRight]: () => {
                xTrack.jump_to_next_sequencer_track();
            },
        });

        // Stay always hooked so we can write [gen] tracks even when not in this mode. Convenient.
        this.hook_notifiers(true);
    }

    mount_note_grid(on: boolean) {
        if (on) {
            this.mount([this.layer_knobs_selector, this.note_grid]);
        } else {
            this.mount([this.layer_knobs_selector]);
        }
    }

    build_menu(item: MenuItem) {
        item.items.push(new MenuItem('Toggle track name [gen] prefix', [], () => {
            rns.selected_track.name = toggle_gen(rns.selected_track.name);
        }));
    }

    hook_notifiers(hook: boolean) {
        if (rns.selected_track_index_observable.has_notifier(this, this.on_track_changed)) {
            rns.selected_track_index_observable.remove_notifier(this, this.on_track_changed);
        }
        if (hook) {
            rns.selected_track_index_observable.add_notifier(this, this.on_track_changed);
        }
    }

    // on_mount() {
    //     super.on_mount();
    //     this.hook_notifiers(true);
    // }
    // on_unmount() {
    //     super.on_unmount();
    //     this.hook_notifiers(false);
    // }

    on_track_changed() {
        const track_model = this.get_track_model();
        if (track_model) {
            // Refresh newly selected track.
            track_model.is_dirty = true;
        }
    }

    get_track_model(): TrackModel | null {
        // TODO: Take only the one for current track.
        // return this.model.track_models[0];
        const name = rns.selected_track.name;
        let track_model = this.track_models[name];
        if (track_model == null && name.startsWith('[gen]')) {
            track_model = new TrackModel(name);
            this.track_models[name] = track_model;
        }
        return track_model;
    }

    update_model() {
        this.model.current_track_model = this.get_track_model();
    }

    on_idle() {
        super.on_idle();

        for (const key in this.track_models) {
            const track_model = this.track_models[key];
            if (track_model) {
                if (track_model.is_dirty) {
                    const start = os.clock();
                    track_model.is_dirty = false;
                    if (!track_model.write_to_track(this.track_output)) {
                        // Orphaned track model. Delete.
                        // TODO: This doesn't actually ever happen because we don't access or dirty orphaned models. Clean up by other means.
                        this.track_models[key] = null;
                        print(`Deleted orphan track model: ${key}`);
                    }
                    const end = os.clock();
                    // print(`write ${track_model.track_name} ${end - start}`);
                }
            }
        }
    }

    render(rc: RenderContext, m: ModelGenerateEuclidean) {
        // const start = os.clock();

        if (m.held_parameter) {
            rc.clear_grid(new Rect(0, 2, FIRE_GRID_WIDTH, 1));
            const max_x = m.held_parameter.max_value - m.held_parameter.min_value;
            const value_x = m.held_parameter.get() - m.held_parameter.min_value;
            for (let x = 0; x < FIRE_GRID_WIDTH; x++) {
                // TODO: May need to map in range
                rc.pad(x, 3,
                    x <= value_x ? Color.white() :
                    x <= max_x ? Color.gray(32) :
                    Color.black());
            }
        } else {
            rc.clear_grid(new Rect(0, 2, FIRE_GRID_WIDTH, 2));
            const left = FIRE_GRID_WIDTH - this.layer_knobs_selector.knob_layers.length;
            for (let x = left; x < FIRE_GRID_WIDTH; x++) {
                //rc.pad(x, 3, (x - left) == m.parameter_set_index ? palette.KNOB_SET_SELECTED : palette.KNOB_SET_UNSELECTED);
                rc.pad(x, 3, (x - left) == this.layer_knobs_selector.index ? palette.KNOB_SET_SELECTED : palette.KNOB_SET_UNSELECTED);
            }
        }

        rc.light(FIRE_LIGHT.RowMute0, m.selected_layer == 0 ? palette.LAYER_SELECTED : palette.LAYER_UNSELECTED);
        rc.light(FIRE_LIGHT.RowMute1, m.selected_layer == 1 ? palette.LAYER_SELECTED : palette.LAYER_UNSELECTED);
        rc.light(FIRE_LIGHT.RowMute2, m.selected_layer == 2 ? palette.LAYER_SELECTED : palette.LAYER_UNSELECTED);
        rc.light(FIRE_LIGHT.RowMute3, Color.black());

        const track_model = m.current_track_model;
        if (track_model) {
            // track_model.print();
            const color = Color.rgb(rns.selected_track.color);
            track_model.division_specs.forEach((division, i) => {
                let x;
                for (x = 0; x < division.step_count; x++) {
                    rc.pad(x, i, division.is_occupied_at(x) ? color : palette.UNOCCUPIED_STEP);
                }
                for (; x < FIRE_GRID_WIDTH; x++) {
                    rc.pad(x, i, palette.BACKGROUND);
                }
            });
        } else {
            rc.clear_grid(new Rect(0, 0, FIRE_GRID_WIDTH, 3));
        }

        rc.light(FIRE_LIGHT.GridLeft, LIGHT_DARK_RED);
        rc.light(FIRE_LIGHT.GridRight, LIGHT_DARK_RED);

        // const start = os.clock();

        // rc.box(FIRE_LED_RECT_FULL, 1);

        // const end = os.clock();
        // print(`r led ${end - start}`);
    }

    mark_note(note: number) {
        this.note_grid.model.marked_note = note;
    }

    get_selected_layer(): number {
        return this.model.selected_layer;
    }
}
