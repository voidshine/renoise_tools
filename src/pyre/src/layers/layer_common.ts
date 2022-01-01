import * as defs from '../engine/fire_defs';
import {Layer} from '../engine/layer';
import { RenderContext } from '../engine/render_context';
import { ModelLayer } from '../engine/model_layer';
import { PALETTE } from '../palette';
import { step_track_column } from '../engine/utility';

const palette = PALETTE.COMMON;

export interface AltShiftState {
    alt: boolean;
    shift: boolean;
}

export class ModelCommon extends ModelLayer implements AltShiftState {
    __eq(rhs: any) { return super.__eq(rhs); }
    shift: boolean = false;
    alt: boolean = false;
}

// A base class for layers that want common behaviors like Shift and Alt buttons,
// as well as generally useful Renoise behaviors like Pattern up/down.
export class LayerCommon<T extends ModelCommon> extends Layer<T> {
    constructor(model: T, name: string) {
        super(model, name);
        
        // this.model.shift = false
        // this.model.alt = false
        // this.model = new LayerModelCommon();

        this.set_note_on_handlers({
            // Note: we return true here to let other common layers also get the shift and alt messages and affect states.
            [defs.FIRE_BUTTON.Shift]: () => { this.model.shift = true; return true; },
            [defs.FIRE_BUTTON.Alt]: () => { this.model.alt = true; return true; },

            [defs.FIRE_BUTTON.PatternUp]: () => {
                const n = rns.sequencer.pattern_sequence.length;
                rns.selected_sequence_index = (rns.selected_sequence_index + n - 1) % n;
            },
            [defs.FIRE_BUTTON.PatternDown]: () => {
                rns.selected_sequence_index = (rns.selected_sequence_index + 1) % rns.sequencer.pattern_sequence.length;
            },

            [defs.FIRE_BUTTON.GridLeft]: () => {
                if (this.model.shift) {
                    if (rns.selected_track.visible_note_columns > 1) {
                        rns.selected_track.visible_note_columns--;
                    }
                } else if (this.model.alt) {
                    step_track_column(-1, true, true, true);
                } else {
                    //xColumns.previous_note_column(true, false);
                    step_track_column(-1, false, false, true);
                }
            },
            [defs.FIRE_BUTTON.GridRight]: () => {
                if (this.model.shift) {
                    const note_columns = rns.selected_track.visible_note_columns;
                    if (note_columns > 0 && note_columns < 12) {
                        rns.selected_track.visible_note_columns++;
                    }
                } else if (this.model.alt) {
                    step_track_column(1, true, true, true);
                } else {
                    //xColumns.next_note_column(true, false);
                    step_track_column(1, false, false, true);
                }
            },
        });

        this.set_note_off_handlers({
            [defs.FIRE_BUTTON.Shift]: () => { this.model.shift = false; return true; },
            [defs.FIRE_BUTTON.Alt]: () => { this.model.alt = false; return true; },
        });
    }

    render(rc: RenderContext, m: any) {
        // TODO: Save BRIGHT_ORANGE for a latch mode where shift is held until something else is pressed; maybe BRIGHT_RED for strong latch mode, held until shift pressed again.
        rc.light(defs.FIRE_LIGHT.Shift, m.shift ? palette.MODIFIER_PRESSED : palette.OFF)
        rc.light(defs.FIRE_LIGHT.Alt, m.alt ? palette.MODIFIER_PRESSED : palette.OFF)

        rc.light(defs.FIRE_LIGHT.PatternUp, defs.LIGHT_DARK_RED);
        rc.light(defs.FIRE_LIGHT.PatternDown, defs.LIGHT_DARK_RED);

        rc.light(defs.FIRE_LIGHT.GridLeft, defs.LIGHT_DARK_RED);
        rc.light(defs.FIRE_LIGHT.GridRight, defs.LIGHT_DARK_RED);
    }
}
