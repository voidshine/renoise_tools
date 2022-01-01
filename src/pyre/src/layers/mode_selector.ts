import { ModeLineNote } from './mode_line_note';
import { ModeMixer } from './mode_mixer';
import { ModeNote } from './mode_note';
import { ModeStepEdit } from './mode_step_edit';
import * as defs from '../engine/fire_defs';
import { Layer } from '../engine/layer';
import { RenderContext } from '../engine/render_context';
import { Color } from '../engine/color';
import { ModelLayer } from '../engine/model_layer';
import { ModeGenerateEuclidean } from './mode_generate_euclidean';
import { ModeToys } from './mode_toys';

// Map friendly names to mode constructors so selector can build only the requested modes.
const MODES = {
    "Line & Note": ModeLineNote,
    "Mixer": ModeMixer,
    "Note": ModeNote,
    "Step Edit": ModeStepEdit,
    "Generate Euclidean": ModeGenerateEuclidean,
    "Toys": ModeToys,
}

export interface ModeBindings {
    [noteName: string]: string[];
}

class ModelModeSelector extends ModelLayer {
    __eq(rhs: any) { return super.__eq(rhs); }
    current_mode_light = -1;
}

export class ModeSelector extends Layer<ModelModeSelector> {
    fire_device_index: number;
    button_lights: number[];

    // modes are an available set of layer instances with friendly names like "Note Mode"
    // mode_bindings map FIRE_BUTTON *note names* to the friendly mode names
    constructor(mode_bindings: ModeBindings, fire_device_index: number) {
        super(new ModelModeSelector(), 'Mode Selector');

        this.fire_device_index = fire_device_index;

        // this.model.current_mode_light = null;
        this.button_lights = [];

        for (const button_name in mode_bindings) {
            const mode_list = mode_bindings[button_name];
            const button = (defs.FIRE_BUTTON as any)[button_name];
            // table.insert(this.button_lights, defs.FIRE_BUTTON_TO_LIGHT[button])
            this.button_lights.push((defs.FIRE_BUTTON_TO_LIGHT as any)[button]);

            const modes: Layer[] = [];
            mode_list.forEach((mode_name, i) => {
                const mode = new ((MODES as any)[mode_name])();
                // assert(mode, "Mode " .. mode_name .. " not found. Bound by button_name " .. button_name)
                // table.insert(modes, mode)
                modes.push(mode);
            });
            this.bind_modes(button, modes);
        }
    }

    bind_modes(button: number, modes: Layer[]) {
        const light = defs.FIRE_BUTTON_TO_LIGHT[button];
        assert(light != null);
        // let index = 1;
        let index = 0;
        this.set_note_on_handlers({
            [button]: () => {
                if (this.model.current_mode_light == light) {
                    // Advance in current modes set
                    index = index + 1;
                    if (!modes[index]) {
                        //index = 1
                        index = 0;
                    }
                }
                this.model.current_mode_light = light;
                this.set_mode(modes[index]);
            },
        });
    }

    set_mode(mode: Layer) {
        oprint(`Fire #${this.fire_device_index} set mode: ${mode.name}`);
        this.mount([mode]);
    }

    render(rc: RenderContext, m: any) {
        rc.clear();
        rc.quad_light_select(this.fire_device_index);

        this.button_lights.forEach((button_light, _) => {
            if (m.current_mode_light == button_light) {
                rc.light(button_light, defs.LIGHT_DARK_RED)
            } else {
                rc.light(button_light, defs.LIGHT_DARK_ORANGE)
            }
        });

        // Double complete rainbow.
        for (let y = 0; y < defs.FIRE_GRID_HEIGHT; y++) {
            for (let x = 0; x < defs.FIRE_GRID_WIDTH; x++) {
                rc.pad(x, y, Color.hsv([x / defs.FIRE_GRID_WIDTH, (defs.FIRE_GRID_HEIGHT - y) / defs.FIRE_GRID_HEIGHT, 1]));
            }
        }
    }
}
