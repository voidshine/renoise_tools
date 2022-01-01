import { RenderContext } from '../engine/render_context';
import { Layer } from '../engine/layer';
import { ModelLayer } from '../engine/model_layer';
import { LayerKnobs } from './layer_knobs_selector';
import { KnobValue } from '../engine/knob';
import { FIRE_LED_WIDTH, FIRE_LED_HEIGHT } from '../engine/fire_led_state';
import { Rect } from '../engine/utility';

class ModelToys extends ModelLayer {
    __eq(rhs: any) { return super.__eq(rhs); }

    rect: Rect = new Rect(0, 0, 0, 0);
}

class LayerToys extends Layer<ModelToys> {
    knobs = [
        new KnobValue('X', FIRE_LED_WIDTH / 2, 0, FIRE_LED_WIDTH, 1.0),
        new KnobValue('Y', FIRE_LED_HEIGHT / 2, 0, FIRE_LED_HEIGHT, 1.0),
        new KnobValue('W', 3, 0, FIRE_LED_WIDTH, 1.0),
        new KnobValue('H', 19, 0, FIRE_LED_HEIGHT, 1.0),
    ];
    constructor() {
        super(new ModelToys(), 'Toys');

        this.children = [
            new LayerKnobs('Toy Knobs', this.knobs),
        ];
    }

    update_model(m: ModelToys) {
        m.rect.left = this.knobs[0].get_value();
        m.rect.top = this.knobs[1].get_value();
        m.rect.width = this.knobs[2].get_value();
        m.rect.height = this.knobs[3].get_value();
    }

    render(rc: RenderContext, m: ModelToys) {
        rc.led_box(m.rect, 1);
        rc.led_text(4, driver.VERSION_STRING);
    }
}

// A mode to access various toys and diagnostics
export class ModeToys extends Layer {
    constructor() {
        super(new ModelLayer(), 'Toys Mode')

        this.children = [
            new LayerToys(),
        ];
    }
}
