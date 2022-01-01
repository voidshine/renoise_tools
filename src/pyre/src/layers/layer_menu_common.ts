import { LayerCommon, ModelCommon } from "./layer_common";
import { Knob, KnobAlt, KnobLatch, KnobToggling } from "../engine/knob";
import { KnobFocusedNavigation } from "./layer_knobs_navigation";
import { RenderContext } from "../engine/render_context";
import { MenuItem } from '../engine/menu';
import { Layer } from "../engine/layer";
import { FIRE_BUTTON, FIRE_LIGHT, LIGHT_DARK_ORANGE, LIGHT_DARK_RED, LIGHT_BRIGHT_RED } from "../engine/fire_defs";
import { Color } from "../engine/color";
import { PITCH_CLASS_NAMES } from "../engine/song_data";

const NULL_ITEM = new MenuItem("()", [], () => {
    print("Error: Activated null menu item.");
});

class KnobMenu implements KnobToggling {
    display_name: string = "Knob Menu";
    root: MenuItem;
    stack: MenuItem[] = [];

    constructor(root: MenuItem) {
        this.root = root;
    }

    display_text() {
        return this.display_name;
    }

    current(): MenuItem {
        return this.stack[this.stack.length - 1];
    }

    pop(): boolean {
        if (this.stack.length > 2) {
            this.stack.pop();
            this.status();
            return true;
        }
        return false;
    }

    clear() {
        this.stack = [this.root];
    }

    enter() {
        this.stack = [this.root, this.root.items[0]];
    }

    is_active() {
        // Something is selected?
        //return this.current() != this.root;
        return this.stack.length > 1;
    }

    status() {
        // TODO: Come on, LED!
        renoise.app().show_status(`pyre menu: ${this.current().text}`);
    }

    on_toggled(active: boolean) {
        if (active) {
            this.enter();
            this.status();
        } else {
            // Clear status to avoid confusion.
            this.clear();
            renoise.app().show_status('');
        }
    }

    // Note: Assumes |delta| is never larger than 1, which is true for Select knob only.
    on_turn(delta: number): void {
        if (!this.is_active()) {
            return;
        }
        const parent = this.stack[this.stack.length - 2];
        const index = (this.current().index + delta + parent.items.length) % parent.items.length;
        this.stack[this.stack.length - 1] = parent.items[index];
        this.status();
    }

    on_press(): void {
        const current = this.current();
        current.on_select();
        if (current.items.length > 0) {
            // Branch.
            this.stack.push(current.items[0]);
        } else {
            // Leaf, for effect only. Exit.
            this.clear();
        }
        this.status();
    }

    on_release(): void {
    }

    get_menu_stack_text() {
        return this.stack.map(item => item.text + (item.items.length > 0 ? ".." : " !")).join('\n');
    }
}

class ModelMenuCommon extends ModelCommon {
    __eq(rhs: any) { return super.__eq(rhs); }
    browser_color: Color = LIGHT_DARK_RED;    
}

// A common layer to control menu operations and main display behavior.
export class LayerMenuCommon extends LayerCommon<ModelMenuCommon> {
    knob_menu = new KnobMenu(new MenuItem("MENU"));
    knob_latch: KnobLatch;

    constructor() {
        super(new ModelMenuCommon(), 'Menu Common');
        this.knob_latch = new KnobLatch([
            new KnobFocusedNavigation(this.model),
            this.knob_menu,
        ]);
        this.set_knob_handlers([null, null, null, null, this.knob_latch]);
        const original_select_button_handler = this.note_on_handlers[FIRE_BUTTON.KnobSelect];
        this.set_note_on_handlers({
            [FIRE_BUTTON.Browser]: () => {
                // Alt + press of browser button can fully exit menu.
                if (this.model.alt || !this.knob_menu.pop()) {
                    // Fully exited.
                    this.knob_latch.cycle();
                }
            },

            // Intercept and forward, to decide whether to exit menu...
            [FIRE_BUTTON.KnobSelect]: (note, velocity) => {
                const was_active = this.knob_menu.is_active();
                original_select_button_handler(note, velocity);
                if (was_active && !this.knob_menu.is_active()) {
                    // Menu was exited by final activation when pressing down Select button.
                    this.knob_latch.cycle();
                }
            }
        });
    }

    // Common/global menu items that are useful regardless of context within the tool.
    build_menu(item: MenuItem) {
        item.items.push(new MenuItem("Pattern", [
            new MenuItem("Clone", [], () => {
                rns.sequencer.clone_range(rns.selected_sequence_index, rns.selected_sequence_index);
            }),
        ]));

        item.items.push(new MenuItem("Song Data", [
            // new MenuItem("Root Pitch Class", forRange(0, 11).map(i => new MenuItem(`Pitch ${i}`)))
            new MenuItem("Root Pitch", PITCH_CLASS_NAMES.map((pitch, i) => new MenuItem(`${i} = ${pitch}`, [], () => {
                driver.song_data.root_pitch_class = i;
                driver.invalidate_all_layers();
            })))
        ]));
    }

    update_model(m: ModelMenuCommon) {
        m.browser_color = this.knob_latch.index() > 0 ? LIGHT_BRIGHT_RED : LIGHT_DARK_RED;
    }

    render(rc: RenderContext, m: ModelMenuCommon) {
        rc.light(FIRE_LIGHT.Browser, m.browser_color);
        if (this.knob_latch.index() > 0) {
            rc.led_clear();
            rc.led_text(-1, this.knob_menu.get_menu_stack_text());
        }
    }

    static create_on(layer: Layer) {
        const menu_layer = new LayerMenuCommon();
        layer.children.push(menu_layer);
        layer.build_menu(menu_layer.knob_menu.root);
        menu_layer.knob_menu.root.set_indices();
    }
}
