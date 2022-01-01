import { Layer } from '../engine/layer';
import { KnobTime, KnobAlt, KnobColumnSelect, KnobQuantizing, KnobValue, Knob, KnobToggling, KnobInstrumentSelect } from '../engine/knob';
import { FIRE_KNOB } from '../engine/fire_defs';
import { RenderContext } from '../engine/render_context';
import { ModelLayer } from '../engine/model_layer';
import { LayerCommon, ModelCommon, AltShiftState } from './layer_common';
import { step_track_column } from '../engine/utility';

export class KnobFocusedNavigation implements KnobToggling {
    display_name = "Navigate";
    source_model: AltShiftState;
    constructor(source_model: AltShiftState) {
        this.source_model = source_model;
    }
    display_text() {
        // TODO: indicate context/focus?
        return this.display_name;
    }
    on_turn(delta: number): void {
        // TODO: How to determine which panel is focused? Is it the pattern editor or DSP chain or what?

        if (this.source_model.alt) {
            step_track_column(delta, false, false, false);
        } else {
            if (this.source_model.shift) {
                delta *= rns.transport.lpb
            }
            rns.selected_line_index = cLib.clamp_value(rns.selected_line_index + delta, 0, rns.selected_pattern.number_of_lines - 1);
        }
    }
    on_press(): void {
        if (this.source_model.alt) {
            if (rns.tracks.every(track => track.collapsed)) {
                // Expand all.
                rns.tracks.forEach(track => {
                    track.collapsed = false;
                });
            } else {
                // Collapse all.
                rns.tracks.forEach(track => {
                    track.collapsed = true;
                });
            }
        } else {
            // Toggle collapsed here only.
            rns.selected_track.collapsed = !rns.selected_track.collapsed;
        }
    }
    on_release(): void {

    }
    on_toggled(active: boolean) {

    }
}

// A common layer to control time cursor and selected track/column.
export class LayerKnobsNavigation extends LayerCommon<any> {
    constructor() {
        super(new ModelCommon(), 'Knobs (Time)');

        this.set_knob_handlers([
            new KnobAlt(this.model, [new KnobTime(driver.options.knob_sensitivity(false, false)), new KnobTime(driver.options.knob_sensitivity(true, false))]),
            new KnobAlt(this.model, [new KnobColumnSelect(false, false, driver.options.knob_sensitivity(false, true)), new KnobColumnSelect(false, false, driver.options.knob_sensitivity(true, true))]),

            // TODO: variety
            new KnobInstrumentSelect(),
            null,
            //new KnobFocusedNavigation(this.model),
        ]);
    }

    update_model(m: any) {
    }

    render(rc: RenderContext, m: any) {
        rc.led_text(-1, 'Nav Time\nNav Column\n\nTODO: Clean up.');
    }
}
