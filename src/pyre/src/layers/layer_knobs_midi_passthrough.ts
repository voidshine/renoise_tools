import { Layer } from '../engine/layer';
import { FIRE_KNOB } from '../engine/fire_defs';
import { RenderContext } from '../engine/render_context';
import { ModelLayer } from '../engine/model_layer';
import { MIDI } from '../engine/common';
import { FIRE_LED_RECT_FULL } from '../engine/fire_led_state';

// A layer to pass knobs MIDI data through the tool with only the MIDI channel possibly changed.
export class LayerKnobsMidiPassthrough extends Layer {
    // Channel is a zero-based MIDI channel for generated MIDI CC messages.
    channel = 0;

    constructor(channel: number) {
        super(new ModelLayer(), 'Knobs (MIDI Passthrough)');
        this.channel = channel;

        const passthrough = (cc: number, value: number) => {
            driver.generated_midi.send_midi([MIDI.CONTROL_CHANGE | this.channel, cc, value]);
        };
        this.set_cc_handlers({
            [FIRE_KNOB.Volume]: passthrough,
            [FIRE_KNOB.Pan]: passthrough,
            [FIRE_KNOB.Filter]: passthrough,
            [FIRE_KNOB.Resonance]: passthrough,
        });
    }

    update_model(m: any) {
    }

    render(rc: RenderContext, m: any) {
        rc.led_text(-1, `MIDI Knobs\nPassthrough\nChannel ${this.channel + 1}\nCC 16,17,18,19`);
    }
}
