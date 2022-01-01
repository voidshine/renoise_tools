import { FireState } from './fire_state';
import { Rect } from './utility';
import { Color } from './color';
import { DrawClear, DrawText, DrawBox } from './draw';
import { FIRE_LED_HEIGHT, FIRE_LED_WIDTH, FIRE_LED_RECT_FULL } from './fire_led_state';
import { PyreFonts } from '../pyre_native';

// Need 5 lines for 5 knobs. Font is 4x6; at scale=2, line height is 12; add one pixel space between lines. Last line is a little short, but renderable: [52, 64)
//const TEXT_CELL_HEIGHT = FIRE_LED_HEIGHT / 4;
const TEXT_CELL_HEIGHT = 13;

export class RenderContext {
    state: FireState;

    constructor(state: FireState) {
        this.state = state;
    }

    clear() {
        this.state.clear()
    }

    // grid_rect may be null to clear all
    clear_grid(grid_rect: Rect | null) {
        if (grid_rect) {
            const black = Color.black()
            // for x, y in grid_rect.iter_xy() do
            for (const [x, y] of grid_rect.iter_xy()) {
                this.state.grid.at(x, y).set_from(black);
            }
        } else {
            this.state.grid.clear();
        }
    }

    pad(x: number, y: number, color: Color) {
        // TODO: assert is Color instance; or else make it one.
        this.state.grid.at(x, y).set_from(color);
    }

    light(light: number, color: Color) {
        this.state.lights[light].set_from(color);
    }

    // quad_light specifies the four linked lights at top left
    // 0 -> Channel, 1 -> Mixer, 2 -> User1, 3 -> User2
    quad_light_select(which: number) {
        this.state.quad_light = which;
    }

    // Or... set each bit explicitly
    quad_light_bits(channel: boolean, mixer: boolean, user1: boolean, user2: boolean) {
        this.state.quad_light =
            bit.lshift((channel ? 1 : 0), 1) +
            bit.lshift((mixer ? 1 : 0), 2) +
            bit.lshift((user1 ? 1 : 0), 3) +
            bit.lshift((user2 ? 1 : 0), 4) +
            0x10;
    }

    led_clear() {
        // TODO: Can generally replace here, since everything drawn before clear will...get cleared.
        this.state.led_model.draw_commands.push(DrawClear.INSTANCE);
    }

    // color_bit 0 or 1
    led_box(rect: Rect, color_bit: number) {
        this.state.led_model.draw_commands.push(new DrawBox(rect, color_bit));
    }

    // Draw text to the given row, [0, 4) or -1 for full rect
    led_text(row: number, text: string) {
        const rect = row < 0 ? FIRE_LED_RECT_FULL : new Rect(0, row * TEXT_CELL_HEIGHT, FIRE_LED_WIDTH, TEXT_CELL_HEIGHT);
        this.state.led_model.draw_commands.push(new DrawText(PyreFonts.Megaman.handle, rect, text));
    }

    led_page(header: string, lines: string[]) {
        let y = 0;
        const rect = new Rect(0, y, FIRE_LED_WIDTH, 12);
        const step_rect = (height: number) => {
            rect.top = y;
            rect.height = height;
            y += height;
            return rect.clone();
        };
        let font = PyreFonts.FontTiny2;
        this.state.led_model.draw_commands.push(new DrawText(font.handle, step_rect(font.height), header));
        this.state.led_model.draw_commands.push(new DrawBox(step_rect(1), 1));
        step_rect(1);
        font = PyreFonts.MegamanMono;
        lines.forEach((line, i) => {
            this.state.led_model.draw_commands.push(new DrawText(font.handle, step_rect(font.height), line));
        });        
    }

    // Draw horizontal line at bottom of a text cell, width uses normalized_value in [0, 1]
    led_line_parameter(row: number, normalized_value: number) {
        const width = normalized_value * FIRE_LED_WIDTH;
        const rect = new Rect(0, row * TEXT_CELL_HEIGHT + 13, width, 2);
        this.state.led_model.draw_commands.push(new DrawBox(rect, 1));
    }

    on_start() {
        this.clear();
    }
    on_finish() {
    }
}
