import { Layer } from '../engine/layer';
import { LayerTransport } from './layer_transport';
import { ModelLayer } from '../engine/model_layer';
import { LayerGenerateEuclidean } from './layer_generate_euclidean';
import { LayerMenuCommon } from './layer_menu_common';

export class ModeGenerateEuclidean extends Layer {
    constructor() {
        super(new ModelLayer(), 'Generate Euclidean Mode')

        this.children = [
            new LayerTransport(),
            new LayerGenerateEuclidean(),
        ];
        LayerMenuCommon.create_on(this);
    }
}
