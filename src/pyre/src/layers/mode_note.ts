import { Layer } from '../engine/layer';
import { LayerTransport } from './layer_transport';
import { LayerNoteGrid } from './layer_note_grid';
import { RenderContext } from '../engine/render_context';
import { ModelLayer } from '../engine/model_layer';
import { LayerKnobsSelector, LayerKnobs } from './layer_knobs_selector';
import { LayerKnobsMidiPassthrough } from './layer_knobs_midi_passthrough';
import { LayerKnobsMixer } from './layer_knobs_mixer';
import { LayerMenuCommon } from './layer_menu_common';
import { KnobVelocity, KnobPitchWheel, KnobModulationWheel, KnobChannelPressure } from '../engine/knob';

// A note mode dedicated to performance with full size keyboards and knobs set
// to control velocity, pitch bend, modulation wheel and aftertouch expression.
export class ModeNote extends Layer {
    constructor() {
        super(new ModelLayer(), 'Note Mode');
        const knob_velocity = new KnobVelocity();
        this.children = [
            new LayerTransport(),
            new LayerNoteGrid("Note Grid: Performance", null, (velocity) => {
                // TODO: ignore, or multiply? simple accent switch?
                return knob_velocity.get_value();
            }),
            new LayerKnobsSelector([
                new LayerKnobs('Note Expression', [
                    knob_velocity,
                    new KnobPitchWheel(),
                    new KnobModulationWheel(),
                    new KnobChannelPressure()
                ]),
                new LayerKnobsMixer(),
                new LayerKnobsMidiPassthrough(0),
                new LayerKnobsMidiPassthrough(1)]),
        ];
        LayerMenuCommon.create_on(this);
    }

    render(rc: RenderContext, m: any) {
    }
}
