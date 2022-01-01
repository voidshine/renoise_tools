import { Layer } from '../engine/layer';
import { LayerTransport } from './layer_transport';
import { LayerKnobsMixer } from './layer_knobs_mixer';
import { LayerTrackSelect } from './layer_track_select';
import { Rect } from '../engine/utility';
import { FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT } from '../engine/fire_defs';
import { ModelLayer } from '../engine/model_layer';
import { LayerMenuCommon } from './layer_menu_common';
import { LayerKnobsSelector } from './layer_knobs_selector';
import { LayerKnobsNavigation } from './layer_knobs_navigation';
import { LayerKnobsMidiPassthrough } from './layer_knobs_midi_passthrough';

export class ModeMixer extends Layer {
    constructor() {
        super(new ModelLayer(), 'Mixer Mode');
        this.children = [
            new LayerTransport(),
            new LayerTrackSelect(new Rect(0, 0, FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT)),
            new LayerKnobsSelector([new LayerKnobsNavigation(), new LayerKnobsMixer(), new LayerKnobsMidiPassthrough(0), new LayerKnobsMidiPassthrough(1)]),
        ];
        LayerMenuCommon.create_on(this);
    }
}
