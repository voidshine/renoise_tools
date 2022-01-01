import { FIRE_GRID_HEIGHT } from '../engine/fire_defs';
import { Layer, GridPadHandler } from '../engine/layer';
import { Rect, Vec2 } from '../engine/utility';
import { PALETTE } from '../palette';
import { RenderContext } from '../engine/render_context';
import { ModelLayer } from '../engine/model_layer';

// Must check time because user may navigate by other means than grid pads.
// Give about half a second to double-tap.
const DOUBLE_TAP_TIME_WINDOW = 0.650;

// TODO: Support adaptive width based on lines per beat
const WIDTH = 4;
const HEIGHT = FIRE_GRID_HEIGHT;

export class ModelLineSelect extends ModelLayer {
    __eq(rhs: any) { return super.__eq(rhs); }
    show_value: number = 0;
}

export class LayerLineSelectHorizontal extends Layer<ModelLineSelect> {
    grid_rect: Rect;
    palette: typeof PALETTE.LINE_SELECT;
    // value: any;

    constructor(grid_left: number, palette: typeof PALETTE.LINE_SELECT) {
        super(new ModelLineSelect(), 'Line Select');
        this.grid_rect = new Rect(grid_left, 0, WIDTH, HEIGHT)
        this.palette = palette;
        // this.value = property(this.get_value, this.set_value)

        let last_press_time = os.clock() - DOUBLE_TAP_TIME_WINDOW;
        const last_press = new Vec2(-1, -1);
        const on_grid_pad: GridPadHandler = (x, y, velocity) => {
            if (velocity) {
                [x, y] = this.transform_xy(x, y);
                const now = os.clock();
                let current = this.get_value();
                const segment_value = math.pow(WIDTH, HEIGHT - 1 - y);
                const above_value = segment_value * WIDTH;
                if (last_press.x == x && last_press.y == y && last_press_time + DOUBLE_TAP_TIME_WINDOW > now) {
                    if (x == WIDTH - 1 && y == HEIGHT - 1) {
                        // Special case lower-right corner double tap seeks instantly to end.
                        // This guarantees easy access to last full range. (e.g. 100-1FF)
                        // To get to end of first half of a 0x200 sized pattern,
                        // user can slide right column of buttons.
                        current = this.get_value_count() - 1;
                    } else if (x == 0 && y == 0) {
                        // Special case upper-left corner double tap seeks instantly to beginning.
                        // This guarantees easy access to first full range. (e.g. 00-FF)
                        // To get to the beginning of the second half of a 0x200 sized pattern,
                        // user can slide left column of buttons or double-tap at (1, 0) before pressing (0, 0).
                        current = 0;
                    } else {
                        // seek to beginning of this segment
                        current = current - math.fmod(current, above_value) + segment_value * x;
                    }
                } else {
                    // change this segment but preserve remainder
                    //print(x,y, now, current);
                    current = current - math.fmod(current, above_value) + math.fmod(current, segment_value) + segment_value * x;
                }
                current = cLib.clamp_value(current, 0, this.get_value_count() - 1);
                this.set_value(current);
                //if (current >= 0 && current < this.get_value_count()) {
                    //print(x,y, now, current, 'set');
                    // this.set_value(current);
                //}
                last_press.x = x;
                last_press.y = y;
                last_press_time = now;
            }
        }
        
        this.set_note_handlers_grid_rect(this.grid_rect, on_grid_pad);
    }

    /** @tupleReturn */
    transform_xy(x: number, y: number) {
        return [x, y];
    }

    update_model(m: ModelLineSelect) {
        // rprint("update")
        m.show_value = rns.selected_line_index;
    }

    render(rc: RenderContext, m: ModelLineSelect) {
        // rprint("render")
        const current = m.show_value;
        const xs = [];
        for (let i = 0; i < HEIGHT; i++) {
            const power = HEIGHT - 1 - i
            xs[i] = this.grid_rect.left + math.floor(math.fmod(current, math.pow(WIDTH, power + 1)) / math.pow(WIDTH, power));
        }
        for (const [x, y] of this.grid_rect.iter_xy()) {
            const color = xs[y] == x ? this.palette.FOREGROUND_COLOR : this.palette.BACKGROUND_COLOR;
            rc.pad(x, y, color);
        }
    }

    // get_value and set_value get/set zero-based values (e.g. 0-63) not one-based (1-64).
    get_value() {
        // return rns.selected_line_index - 1;
        //return rns.selected_line_index;
        return this.model.show_value;
    }
    set_value(value: number) {
        // rns.selected_line_index = value + 1;

        // Note, the Renoise value may not update instantly after being set. Simultaneous pad presses would not work correctly
        //  if we depended directly on selected_line_index.
        rns.selected_line_index = value;
        this.model.show_value = value;
    }
    // Returns the number of values that can be accessed; may be zero.
    get_value_count() {
        return rns.selected_pattern.number_of_lines;
    }
}

export class LayerLineSelectVertical extends LayerLineSelectHorizontal {
    /** @tupleReturn */
    transform_xy(x: number, y: number) {
        return [y, x];
    }

    render(rc: RenderContext, m: ModelLineSelect) {
        const current = m.show_value;
        const ys = [];
        for (let i = 0; i < HEIGHT; i++) {
            const power = HEIGHT - 1 - i
            ys[i] = this.grid_rect.top + math.floor(math.fmod(current, math.pow(WIDTH, power + 1)) / math.pow(WIDTH, power));
        }
        for (const [x, y] of this.grid_rect.iter_xy()) {
            const color = ys[x] == y ? this.palette.FOREGROUND_COLOR : this.palette.BACKGROUND_COLOR;
            rc.pad(x, y, color);
        }
    }
}

export class LayerLineSelect extends LayerLineSelectVertical {}
