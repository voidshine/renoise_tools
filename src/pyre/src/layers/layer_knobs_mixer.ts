import { Layer } from '../engine/layer';
import {} from '../engine/utility';
import { KnobDeltaHandler } from '../engine/layer';
import { RenderContext } from '../engine/render_context';
import { ModelLayer } from '../engine/model_layer';

// TODO: Sensitivity options
const KNOB_VOLUME_SCALING = 0.007;
const KNOB_UNIPOLAR_SCALING = 0.01;

// A layer to control track and device parameters with upper-left knob set.
export class LayerKnobsMixer extends Layer {
    constructor() {
        super(new ModelLayer(), 'Knobs (Mixer)')

        // this.set_note_on_handlers {
        //     [FIRE_BUTTON.KnobVolume] = ,
        //     [FIRE_BUTTON.KnobPan] = ,
        // }

        const on_knob: KnobDeltaHandler = (knob, delta) => {
            let parameter;
            if (knob == 0) {
                parameter = rns.selected_track.prefx_volume;
                delta = delta * KNOB_VOLUME_SCALING;
            } else if (knob == 1) {
                parameter = rns.selected_track.prefx_panning;
                delta = delta * KNOB_UNIPOLAR_SCALING;
            } else if (knob == 2) {
                parameter = rns.selected_track.postfx_volume;
                delta = delta * KNOB_VOLUME_SCALING;
            } else if (knob == 3) {
                parameter = rns.selected_track.postfx_panning;
                delta = delta * KNOB_UNIPOLAR_SCALING;
            } else {
                // Pass through for Select knob.
                return true;
            }
            // TRACE("knob", knob, delta, "parameter", parameter)
            // oprint(parameter)
            // Whew, GlobalMidiActions and Duplex's MidiActions look deep...
            // const message = TriggerMessage()
            // invoke_action("Track Levels:Volume:Current Track (Post) [Set]", message)
            // TRACE(parameter.value, parameter.value_min, parameter.value_max, parameter.value_default, parameter.value_quantum, parameter.value_string)
            parameter.value = cLib.clamp_value(parameter.value + delta, parameter.value_min, parameter.value_max);
        }

        this.set_knob_delta_handler(on_knob);
    }


    update_model(m: any) {
    }

    render(rc: RenderContext, m: any) {
        rc.led_text(-1, "Pre-Volume\nPre-Panning\nPost-Volume\nPost-Panning\nTODO: More here.");
    }
}
