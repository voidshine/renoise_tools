import { RenderContext } from '../engine/render_context';
import { Layer } from '../engine/layer';
import { LayerLineSelect } from './layer_line_select';
import { PALETTE } from '../palette';
import { LayerTransport } from './layer_transport';
import { LayerNoteGrid } from './layer_note_grid';
import { Rect } from '../engine/utility';
import { FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT } from '../engine/fire_defs';
import { LayerKnobsNavigation } from './layer_knobs_navigation';
import { ModelLayer } from '../engine/model_layer';
import { LayerKnobsMixer } from './layer_knobs_mixer';
import { LayerKnobsMidiPassthrough } from './layer_knobs_midi_passthrough';
import { LayerKnobsSelector } from './layer_knobs_selector';
import { LayerMenuCommon } from './layer_menu_common';

// A mode that splits grid into line selector and notes
export class ModeLineNote extends Layer {
    constructor() {
        super(new ModelLayer(), 'Line Note Mode')

        const line_select = new LayerLineSelect(0, PALETTE.LINE_SELECT);
        const w = line_select.grid_rect.width;
        const note_grid = new LayerNoteGrid("Note Grid: Line & Note", new Rect(w, 0, FIRE_GRID_WIDTH - w, FIRE_GRID_HEIGHT), v => v);
        this.children = [
            new LayerTransport(),
            line_select,
            note_grid,
            new LayerKnobsSelector([
                new LayerKnobsNavigation(),
                new LayerKnobsMixer(),
                new LayerKnobsMidiPassthrough(0),
                new LayerKnobsMidiPassthrough(1)
            ]),
        ];
        LayerMenuCommon.create_on(this);
    }

    render(rc: RenderContext, m: any) {
    }
}
