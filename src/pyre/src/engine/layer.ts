import * as defs from './fire_defs';
import { ModelLayer } from './model_layer';
import { Rect, } from './utility';
import { RenderContext } from './render_context';
import { Knob } from './knob';
import { MenuItem } from './menu';

// Note the return types here are typically void, but a handler may return true to allow handling to continue as if unhandled, allowing others to receive the message.
export type NoteOnHandler = (note: number, velocity: number) => void | boolean;
export type NoteOffHandler = (note: number) => void | boolean;
export type ControlChangeHandler = (cc: number, value: number) => void | boolean;
export type GridPadHandler = (x: number, y: number, velocity: number | null) => void;

// handler(knob, delta) where knob in [0, 4) and delta is signed integer with large positive values being hard turns clockwise.
export type KnobDeltaHandler = (knob: number, delta: number) => void | boolean;

export interface Handlers<T> {
    [key: number]: T;    
}

// Layer base class offering nested layers with recursive rendering and event handling.
// Each layer owns a model containing *all* state necessary to render its UI. This is
// a plain data table (not a userdata class) and changes to it are tracked by comparison to
// prevent unnecessary renders. A correct and efficient __eq implementation makes it easy
// for the device to stay up to date with current state, but full comparison can
// also be skipped by setting model_is_dirty.
// :render is not the place to change the model; consider it read-only in :render .
// :on_idle or event handlers change the model.
export class Layer<T extends ModelLayer = ModelLayer> {
    name: string;
    children: Layer[] = [];
    note_on_handlers: DirectIndex<NoteOnHandler>;
    note_off_handlers: DirectIndex<NoteOffHandler>;
    cc_handlers: DirectIndex<ControlChangeHandler>;

    // TODO: better model system?
    // model: LayerModel;
    model: T;
    rendered_model: any;

    // model_is_dirty: any;

    // Some models are much more complicated in structure and comparison
    // than in simply rendering them every frame.
    // For such cases, an implementation can set this true to render every frame with no comparisons.
    // TODO: Rendering is fast. May as well get rid of this, as well as model comparison logic.
    always_dirty = true;
    
    constructor(model: T, name: string) {
        this.name = name;
        // this.children = {}
        this.note_on_handlers = [];
        this.note_off_handlers = [];
        this.cc_handlers = [];
        this.model = model;
        // this.model_is_dirty = property(this.get_model_is_dirty, this.set_model_is_dirty);
        this.rendered_model = null;
    }

    set_note_on_handlers(handlers: Handlers<NoteOnHandler>) {
        for (const key in handlers) {
            const v = handlers[key];
            this.note_on_handlers[key] = v;
        }
    }

    set_note_off_handlers(handlers: Handlers<NoteOffHandler>) {
        for (const key in handlers) {
            const v = handlers[key];
            this.note_off_handlers[key] = v;
        }
    }

    set_cc_handlers(handlers: Handlers<ControlChangeHandler>) {
        for (const key in handlers) {
            const v = handlers[key];
            this.cc_handlers[key] = v;
        }
    }

    // Set handler for note on/off events to the rect of the grid specified by range [left, width) x [top, height)
    // Note events call handler(x, y, velocity) where x, y is *relative* to left, top; i.e. position within given rectangle.
    set_note_handlers_grid_rect(rect: Rect, handler: GridPadHandler) {
        const on_handlers: Handlers<NoteOnHandler> = {};
        const off_handlers: Handlers<NoteOffHandler> = {};

        const translate_on = function(note: number, velocity: number) {
            const [x, y] = defs.grid_midi_note_to_xy(note);
            handler(x - rect.left, y - rect.top, velocity);
        }
        const translate_off = function(note: number) {
            const [x, y] = defs.grid_midi_note_to_xy(note);
            handler(x - rect.left, y - rect.top, null);
        }

        for (let y = rect.top; y < rect.top + rect.height; y++) {
            for (let x = rect.left; x < rect.left + rect.width; x++) {
                const index = defs.grid_xy_to_midi_note(x, y);
                on_handlers[index] = translate_on;
                off_handlers[index] = translate_off;
            }
        }

        this.set_note_on_handlers(on_handlers);
        this.set_note_off_handlers(off_handlers);
    }

    // handler(knob, delta) where knob in [0, 4] (left to right, including Select) and
    // delta is signed integer with large positive values being hard turns clockwise.
    set_knob_delta_handler(handler: KnobDeltaHandler) {
        const convert = function(knob: number) {
            return function(cc: number, value: number) {
                return handler(knob, value < 64 ? value : -(128 - value));
            }
        }
        this.set_cc_handlers({
            [defs.FIRE_KNOB.Volume]: convert(0),
            [defs.FIRE_KNOB.Pan]: convert(1),
            [defs.FIRE_KNOB.Filter]: convert(2),
            [defs.FIRE_KNOB.Resonance]: convert(3),
            [defs.FIRE_KNOB.Select]: convert(4),
        });
    }

    set_knob_handler(knob_cc: number, knob_handler: Knob) {
        this.cc_handlers[knob_cc] = function(cc, value) {
            knob_handler.on_turn(value < 64 ? value : -(128 - value));
        }
        this.note_on_handlers[defs.FIRE_KNOB_TO_BUTTON[knob_cc]] = function(note, velocity) {
            knob_handler.on_press();
        }
        this.note_off_handlers[defs.FIRE_KNOB_TO_BUTTON[knob_cc]] = function(note) {
            knob_handler.on_release();
        }
    }

    set_knob_handlers(knobs: (Knob | null)[]) {
        //assert(knobs.length == defs.FIRE_KNOB_COUNT, `Specify knobs for exactly ${defs.FIRE_KNOB_COUNT} knobs on layer ${this.name}.`);
        // NOTE: Lua table arrays might end with nil, which will result in reduced length...so we can't assert on length; just tolerate nulls.
        if (knobs[0]) this.set_knob_handler(defs.FIRE_KNOB.Volume, knobs[0]);
        if (knobs[1]) this.set_knob_handler(defs.FIRE_KNOB.Pan, knobs[1]);
        if (knobs[2]) this.set_knob_handler(defs.FIRE_KNOB.Filter, knobs[2]);
        if (knobs[3]) this.set_knob_handler(defs.FIRE_KNOB.Resonance, knobs[3]);
        if (knobs[4]) this.set_knob_handler(defs.FIRE_KNOB.Select, knobs[4]);
    }

    get_model_is_dirty() {
        return this.always_dirty || this.model != this.rendered_model;
    }

    set_model_is_dirty(dirty: boolean) {
        if (dirty || this.always_dirty) {
            this.rendered_model = null
        } else {
            // const start = os.clock();
            this.rendered_model = this.model.clone()
            // const end = os.clock();
            // print(`model clone ${end - start}`);

            // TODO: clean this up
            // Expensive check but may be valuable during development.
            if (this.get_model_is_dirty()) {
                // TRACE(this.model, ";", this.rendered_model)
                // rprint(this.model.track_colors)
                // rprint(this.rendered_model.track_colors)
            }
            assert(!this.get_model_is_dirty(), `On layer ${this.name}, model is still dirty after clone! This will cause rendering on every idle call.`);
        }
    }

    // rc is the RenderContext used to change the FireState, and m is the model to render.
    // Note: In render implementations, this should *not* be used for *any* non-const property or method access.
    //  The rule is: if (it's render accessible and can ever change, it comes through model m, which can
    //  be kept up to date elsewhere (on_idle, event handlers, etc.).
    render(rc: RenderContext, m: ModelLayer) {
    }

    // Handles rendering recursively. Implementations should usually just override :render .
    all_render(rc: RenderContext) {
        // const start = os.clock();
        if (this.get_model_is_dirty()) {
            this.render(rc, this.model);
            this.set_model_is_dirty(false);
        }
        this.children.forEach((child, _) => {
            child.all_render(rc);
        });
        // const end = os.clock();
        // print(`ar ${end - start}`);
    }

    all_on_midi_note(note: number, velocity: number | null) {
        // Give children the chance to override handling first; then handle ourselves if not handled.
        //this.children.forEach((child, _) => {
        for (let i = 0; i < this.children.length; i++) {
            if (this.children[i].all_on_midi_note(note, velocity)) {
                // print(`${note},${velocity} handled by ${this.children[i].name}`);
                return true;
            }
        }
        return this.on_midi_note(note, velocity);
    }

    // Handles note on and off events. Note on events have velocity, while note off events have velocity = null .
    on_midi_note(note: number, velocity: number | null) {
        if (velocity) {
            // Note ON
            const handler = this.note_on_handlers[note];
            if (handler) {
                if (handler(note, velocity)) {
                    return false;
                }
                // print(`winner: ${this.name}`);
                return true;
            }
        } else {
            // Note OFF
            const handler = this.note_off_handlers[note];
            if (handler) {
                if (handler(note)) {
                    return false;
                }
                return true;
            }
        }
        return false;
    }

    all_on_midi_cc(cc: number, value: number) {
        // Give children the chance to override handling first; then handle ourselves if not handled.
        // this.children.forEach((child, _) => {
        for (let i = 0; i < this.children.length; i++) {
            if (this.children[i].all_on_midi_cc(cc, value)) {
                return true;
            }
        }
        return this.on_midi_cc(cc, value);
    }

    // Handles control change events
    on_midi_cc(cc: number, value: number) {
        const handler = this.cc_handlers[cc];
        if (handler) {
            if (handler(cc, value)) {
                return false;
            }
            return true;
        }
        return false
    }

    // Override this to access rns or other bits of state that should be shown by render.
    // Note: by default it is called from on_idle so be quick or override on_idle.
    // Passes this.model for convenience.
    update_model(m: ModelLayer) {
    }

    on_idle() {
        this.update_model(this.model)
    }

    all_on_idle() {
        this.on_idle()
        this.children.forEach((child, _) => {
            child.all_on_idle()
        });
    }

    // For performance-critical visitation, a dedicated all_* method is preferred,
    // but for infrequent visitations, this method can be used flexibly.
    all_visit(method_name: string) {
        (this as any)[method_name](this);
        this.children.forEach((child, _) => {
            child.all_visit(method_name)
        });
    }

    // Fully specify the new set of mounted children.
    mount(children: Layer[]) {
        // TODO: No way to compare luabind class objects of different types? Could map names, but seems slow/hackish.
        // if (sequences_equal(this.children, children)) {
        //     rprint("equal sequences; mount bypassed")
        //     return
        // }

        this.children.forEach((child, _) => {
            child.all_visit("on_unmount");
        });

        this.children = children
        this.children.forEach((child, _) => {
            child.all_visit("on_mount");
        });
    }

    // Called when a layer joins the live tree that updates and renders.
    on_mount() {
        // idle early and ensure render will happen.
        this.on_idle();
        this.set_model_is_dirty(true);
    }

    // Called when a layer is removed from the live tree that updates and renders.
    on_unmount() {
    }

    // This may be called occasionally when members not in the model change, and the
    // layer should make no assumptions about what is shown, simply do a full reset and render.
    invalidate() {
        this.set_model_is_dirty(true);
        this.children.forEach(child => child.invalidate());
    }

    build_menu(item: MenuItem) {
        this.children.forEach(child => {
            child.build_menu(item);
        });
    }
}
