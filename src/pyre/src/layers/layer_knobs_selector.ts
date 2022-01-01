import { Layer, KnobDeltaHandler } from '../engine/layer';
import { FIRE_BUTTON, } from '../engine/fire_defs';
import { RenderContext } from '../engine/render_context';
import { ModelLayer } from '../engine/model_layer';
import { Knob } from '../engine/knob';

// A layer that lets user select any one of four knob sets with the upper-left ChannelMixerUserButton.
// It's designed for Knobs* layers, but could theoretically mount/unmount any kind of child layer.
export class LayerKnobsSelector extends Layer {
    index: number = 0;
    knob_layers: Layer[];
    button_down = false;
    last_index = 1;

    constructor(knob_layers: Layer[]) {
        super(new ModelLayer(), 'Knobs (Selector)');

        // No need for this layer if not at least two options.
        assert(knob_layers.length >= 2);

        this.knob_layers = knob_layers;

        const convert = (n: number) => (note: number, velocity: number) => {
            if (this.button_down) {
                this.select(n);
                // Set up the button release to "return" to targeted selection.
                // if (n != this.index) {
                //     this.last_index = n;
                // }
            }
            return true;
        };

        this.set_note_on_handlers({
            [FIRE_BUTTON.ChannelMixerUserButton]: () => {
                this.button_down = true;
                this.select(this.index + 1);
            },
            [FIRE_BUTTON.KnobVolume]: convert(0),
            [FIRE_BUTTON.KnobPan]: convert(1),
            [FIRE_BUTTON.KnobFilter]: convert(2),
            [FIRE_BUTTON.KnobResonance]: convert(3),
        });
        this.set_note_off_handlers({
            [FIRE_BUTTON.ChannelMixerUserButton]: () => {
                this.button_down = false;
                // this.select(this.last_index);
            },
        });

        this.mount_selection();

        // Shortcut to keep quad light showing index.
        this.always_dirty = true;
    }

    mount_selection() {
        this.mount([this.knob_layers[this.index]]);
    }

    // Note: We override ordinary note event handling so that we can intercept events *before* passing them to children layers.
    // This is needed to properly catch knob touch events; without it, a child knobs layer could handle knob touches and
    // this layer wouldn't be able to change on knob touch.
    all_on_midi_note(note: number, velocity: number | null) {
        if (this.button_down) {
            // Don't propagate to children while button is down; but still handle the event at this layer.
            return this.on_midi_note(note, velocity);
        }
        return super.all_on_midi_note(note, velocity);
    }

    select(new_index: number) {
        this.last_index = this.index;
        this.index = new_index % this.knob_layers.length;
        this.mount_selection();
    }

    update_model(m: any) {
    }

    render(rc: RenderContext, m: any) {
        // print(this.index);
        rc.quad_light_select(this.index);
    }
}

export class LayerKnobs extends Layer {
    // led_text: string;
    mount_message: string;
    knobs: (Knob | null)[];
    constructor(name: string, knobs: (Knob | null)[]) {
        super(new ModelLayer(), name);
        this.knobs = knobs;
        this.set_knob_handlers(knobs);
        // this.led_text = knobs.map(knob => `[${knob ? knob.display_name : '_'}]`).join('\n');
        this.mount_message = knobs.map(knob => `[${knob ? knob.display_name : '_'}]`).join(' ');
    }

    on_mount() {
        super.on_mount();
        renoise.app().show_status(this.mount_message);
    }

    render(rc: RenderContext, m: any) {
        rc.led_page(this.name, this.knobs.map(k => k ? k.display_text() : "---"));
        // this.knobs.forEach((knob, i) => {
        //     if (knob) {
        //         rc.led_text(i, knob.display_text());
        //     }
        // });
    }
}

export class LayerKnobsDelta extends Layer {
    constructor(name: string, knob_delta_handler: KnobDeltaHandler) {
        super(new ModelLayer(), name);
        this.set_knob_delta_handler(knob_delta_handler);
    }
}
