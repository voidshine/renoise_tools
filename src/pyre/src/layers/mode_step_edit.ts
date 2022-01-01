import { Layer } from '../engine/layer';
import { LayerTransport } from './layer_transport';
import { LayerStepEdit } from './layer_step_edit';
import { LayerWideStepEdit } from './layer_wide_step_edit';
import { ModelLayer } from '../engine/model_layer';
import { LayerNoteGrid } from './layer_note_grid';
import { Rect } from '../engine/utility';
import { FIRE_GRID_WIDTH } from '../engine/fire_defs';
import { LayerKnobsSelector, LayerKnobs } from './layer_knobs_selector';
import { LayerKnobsMixer } from './layer_knobs_mixer';
import { LayerKnobsMidiPassthrough } from './layer_knobs_midi_passthrough';
import { LayerMenuCommon } from './layer_menu_common';

export class ModeStepEdit extends Layer {
    constructor() {
        super(new ModelLayer(), 'Step Edit Mode')

        const step_edit = new LayerWideStepEdit();

        this.children = [
            new LayerTransport(),

            // TODO: Implement
            //new LayerStepEdit(),
            step_edit,

            new LayerNoteGrid("Note Grid: Step Edit", new Rect(0, 2, FIRE_GRID_WIDTH, 2), v => v, (note, velocity) => step_edit.on_note(note, velocity)),
            new LayerKnobsSelector([new LayerKnobs('Step Edit Knobs', step_edit.edit_knobs), new LayerKnobsMixer(), new LayerKnobsMidiPassthrough(0), new LayerKnobsMidiPassthrough(1)]),
        ];
        LayerMenuCommon.create_on(this);
    }
}
