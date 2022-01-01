import { Layer } from '../engine/layer';
import {} from '../engine/utility';
import { Rect } from '../engine/utility';
import { FIRE_GRID_HEIGHT, FIRE_GRID_WIDTH } from '../engine/fire_defs';
import { RenderContext } from '../engine/render_context';
import { ModelLayer } from '../engine/model_layer';

class LayerModelCrossTrackOverview extends ModelLayer {
    __eq(rhs: any) { return super.__eq(rhs); }
    lines_per_row: number;

    constructor(lines_per_row: number) {
        super();
        this.lines_per_row = lines_per_row;
    }
}

// Provides a scrolling broad view across many tracks, showing notes playing and coming up soon.
// Zoom out and copy/paste chunks across tracks.
export class LayerCrossTrackOverview extends Layer<LayerModelCrossTrackOverview> {
    grid_rect: Rect;

    constructor(grid_rect: Rect | null) {
        super(new LayerModelCrossTrackOverview(4), 'Cross-Track Overview')

        this.grid_rect = grid_rect || new Rect(0, 0, FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT);

        // TODO: Maybe follow lines per beat or a multiple thereof?
        // this.model.lines_per_row = 4
    }

    update_model(m: any) {
        // rprint("update")
        m.selected_line_index = rns.selected_line_index
    }

    render(rc: RenderContext, m: any) {
    }
}
