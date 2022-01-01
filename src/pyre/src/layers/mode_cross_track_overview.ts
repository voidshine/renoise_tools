import { Layer } from '../engine/layer';
import { LayerLineSelect } from './layer_line_select';
import { LayerTransport } from './layer_transport';
import { LayerCrossTrackOverview } from './layer_cross_track_overview';
import { Rect } from '../engine/utility';
import { FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT } from '../engine/fire_defs';
import { PALETTE } from '../palette';
import { ModelLayer } from '../engine/model_layer';

export class ModeCrossTrackOverview extends Layer {
    constructor() {
        super(new ModelLayer(), 'Cross-Track Overview Mode')

        const line_select = new LayerLineSelect(0, PALETTE.LINE_SELECT);
        const w = line_select.grid_rect.width
        this.children = [
            new LayerTransport(),
            line_select,
            new LayerCrossTrackOverview(new Rect(w, 0, FIRE_GRID_WIDTH - w, FIRE_GRID_HEIGHT)),
        ];
    }

    // render(rc: RenderContext, m: any) {
    // }
}
