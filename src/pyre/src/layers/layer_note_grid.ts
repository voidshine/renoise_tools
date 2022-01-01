import '../external/xLib';

import { PALETTE } from '../palette';
import { MIDI, RENOISE_MIDI } from '../engine/common';
import { Color } from '../engine/color';
import { LayerCommon, ModelCommon } from './layer_common';
import { Rect } from '../engine/utility';
import { FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT, FIRE_BUTTON, grid_xy_to_midi_note, FIRE_LIGHT, LIGHT_BRIGHT_GREEN, LIGHT_DARK_GREEN, LIGHT_DARK_RED, LIGHT_OFF } from '../engine/fire_defs';
import { ModelLayer } from '../engine/model_layer';
import { } from '../engine/osc_renoise';
import { FIRE_LED_RECT_FULL } from '../engine/fire_led_state';
import { RenderContext } from '../engine/render_context';
import { NoteGridLayout } from '../engine/options';
import { MenuItem } from '../engine/menu';

const palette = PALETTE.NOTE_GRID;

// X+ goes to right; Y+ goes down. Origin is (0, 0) and the pattern repeats with final value overlapping as a new zero.
// This makes all kinds of isomorphic and irregular (like diatonic) layouts easy to construct.
function map_general(base: number, x_pattern: number[], y_pattern: number[], x: number, y: number) {
    const nx = x_pattern.length - 1;
    const ny = y_pattern.length - 1;
    return base +
        (math.floor(y / ny) * y_pattern[ny]) + y_pattern[y % ny] +
        (math.floor(x / nx) * x_pattern[nx]) + x_pattern[x % nx];
}

let map_note = map_general;

// function note_color_at(m: ModelNoteGrid, x: number, y: number) {
function note_color(m: ModelNoteGrid, note: number) {
    // const note = map_note(m.top_left_note, m.layout.x_pattern, m.layout.y_pattern, x, y);
    if (note == m.marked_note) {
        return palette.MARKED_NOTE;
    } else if (m.note_to_count[note]) {
        return m.edit_mode ? palette.NOTE_ON_WITH_EDIT : palette.NOTE_ON_WITHOUT_EDIT;
    } else if (note < RENOISE_MIDI.NOTE_MIN || note > RENOISE_MIDI.NOTE_MAX) {
        return palette.OUT_OF_BOUNDS;
    } else if (m.cursor_notes.includes(note)) {
        // TODO: Really shouldn't be using live data over the model
        //return palette.CURSOR_NOTE;
        //const column = rns.selected_note_column;
        //if (column && column.note_value == note) {
        if (m.selected_column_note == note) {
            //return palette.CURSOR_NOTE_IN_SELECTED_COLUMN;
            return driver.song_data.note_color(note).with_hsv_value(1.0);
        } else {
            //return palette.CURSOR_NOTE;
            return driver.song_data.note_color(note).with_hsv_value(0.6);
        }
    } else if (note % 12 == 0) {
        // return Color.gray(100)
        //return m.track_color;
        return driver.song_data.note_color(note);
    } else {
        //return Color.black();
        return driver.song_data.note_color(note);
    }
}

export type MapVelocity = (velocity: number) => number;

class ModelNoteGrid extends ModelCommon {
    __eq(rhs: ModelNoteGrid) { return super.__eq(rhs); }
    top_left_note: number = 0;
    note_to_count: {[key: number]: number | null} = new ModelLayer() as any;
    edit_mode = false;
    track_color = Color.white();
    marked_note: number = 1000;
    cursor_notes: number[] = new ModelLayer() as any;
    selected_column_note: number = RENOISE_MIDI.NOTE_VALUE_EMPTY;

    // constructor(layout: NoteGridLayout) {
    //     super();
    //     this.layout = layout;
    //     this.top_left_note = layout.origin_note;
    // }
}

// May return true to pass through to default behavior; otherwise events are considered handled.
type NoteHandler = (note: number, velocity: number | null) => void | boolean;

export class LayerNoteGrid extends LayerCommon<ModelNoteGrid> {
    grid_rect: Rect;
    note_grid_rect: Rect;
    map_velocity: MapVelocity;
    note_handler: NoteHandler;
    layout!: NoteGridLayout;
    grid_to_note: {[key: number]: number | null} = {};
    invalid = false;

    // If grid_rect is null, the whole grid is used.
    // Note: note_handler may receive NOTE_EMPTY or NOTE_OFF special note values.
    constructor(name: string, grid_rect: Rect | null, map_velocity: MapVelocity, note_handler?: NoteHandler) {
        super(new ModelNoteGrid(), name);

        this.grid_rect = grid_rect || new Rect(0, 0, FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT);
        this.note_grid_rect = this.grid_rect.sub_rect(1, 0, this.grid_rect.width - 1, this.grid_rect.height);
        this.map_velocity = map_velocity;

        this.note_handler = (note, velocity) => {
            if (note_handler) {
                if (!note_handler(note, velocity)) {
                    return;
                }
            }
            if (velocity) {
                driver.generated_midi.send_note_on(note, velocity);
            } else {
                driver.generated_midi.send_note_off(note);
            }
        };

        this.set_note_handlers_grid_rect(this.note_grid_rect, (x, y, velocity) => {
            if (velocity) {
                // Note ON
                const note = map_note(this.model.top_left_note, this.layout.x_pattern, this.layout.y_pattern, x, y);
                // rprint([x, y, note, this.layout.name, this.layout.x_pattern]);
                if (note >= 0 && note <= 0xff) {
                    this.grid_to_note[y * FIRE_GRID_WIDTH + x] = note;
                    velocity = this.map_velocity(velocity);
                    this.model.note_to_count[note] = (this.model.note_to_count[note] || 0) + 1;
                    if (this.model.note_to_count[note] == 1) {
                        this.note_handler(note, velocity);
                    }
                    // print(note, 'on', 'gtn');
                    // rprint(this.grid_to_note);
                    // print('ntc');
                    // rprint(this.model.note_to_count);
                }
            } else {
                // Note OFF
                const note = this.grid_to_note[y * FIRE_GRID_WIDTH + x];
                if (note != null) {
                    // note is surely in range because only in-range values are added to grid_to_note.
                    this.model.note_to_count[note] = (this.model.note_to_count[note] || 1) - 1;
                    if (this.model.note_to_count[note] == 0) {
                        this.model.note_to_count[note] = null;
                        this.note_handler(note, velocity);
                    }
                    // print(note, 'off', 'gtn');
                    // rprint(this.grid_to_note);
                    // print('ntc');
                    // rprint(this.model.note_to_count);
                }
            }
        });

        this.set_note_on_handlers({
            [FIRE_BUTTON.RowMute0]: () => { this.transpose(this.model.shift ? 2 : 24) },
            [FIRE_BUTTON.RowMute1]: () => { this.transpose(this.model.shift ? 1 : 12) },
            [FIRE_BUTTON.RowMute2]: () => { this.transpose(this.model.shift ? -1 : -12) },
            [FIRE_BUTTON.RowMute3]: () => { this.transpose(this.model.shift ? -2 : -24) },

            [FIRE_BUTTON.GridLeft]: () => { xColumns.previous_note_column(true, false) },
            [FIRE_BUTTON.GridRight]: () => { xColumns.next_note_column(true, false) },

            // Set reserved lower-left pads for OFF and EMPTY
            [grid_xy_to_midi_note(this.grid_rect.left, this.grid_rect.bottom() - 2)]: () => {
                if (!note_handler || note_handler(RENOISE_MIDI.NOTE_VALUE_OFF, 0) == true) {
                    if (rns.transport.edit_mode) {
                        const note_column = rns.selected_note_column
                        if (note_column) {
                            note_column.note_value = RENOISE_MIDI.NOTE_VALUE_OFF;
                        }
                    }
                }
            },
            [grid_xy_to_midi_note(this.grid_rect.left, this.grid_rect.bottom() - 1)]: () => {
                if (!note_handler || note_handler(RENOISE_MIDI.NOTE_VALUE_EMPTY, 0)) {
                    if (rns.transport.edit_mode) {
                        const note_column = rns.selected_note_column;
                        if (note_column) {
                            note_column.note_value = RENOISE_MIDI.NOTE_VALUE_EMPTY;
                        }
                    }
                }
            },
        });

        this.apply_layout();

        this.transpose(0);
    }

    apply_layout() {
        this.layout = driver.song_data.create_or_get_track_note_layout(this.name, rns.selected_track.name);;
        this.model.top_left_note = this.layout.origin_note;
        //print(`Set ${layout.name} on ${this.name} with origin ${this.model.top_left_note} and rect @ ${this.note_grid_rect.left},${this.note_grid_rect.top}`);
    }

    build_menu(item: MenuItem) {
        item.items.push(
            new MenuItem(`Note Grid Layout for current Track`, driver.options.config.note_grid_layouts.map(layout => new MenuItem(layout.name, [], () => {
                driver.song_data.get_track_data(rns.selected_track.name).layer_note_layouts[this.name] = driver.song_data.clone_note_layout(layout);
                this.invalidate();
            })))
        );
        item.items.push(
            new MenuItem(`Note Grid Layout Default for '${this.name}'`, driver.options.config.note_grid_layouts.map(layout => new MenuItem(layout.name, [], () => {
                if (driver.options.config.default_note_layouts_by_layer[this.name] != layout.name) {
                    driver.options.config.default_note_layouts_by_layer[this.name] = layout.name;
                    driver.options.save_config();
                    this.invalidate();
                }
            })))
        );
    }

    invalidate() {
        super.invalidate();
        this.invalid = true;
    }

    on_track_changed() {
        this.invalidate();
    }

    on_mount() {
        super.on_mount();
        rns.selected_track_observable.add_notifier(this.on_track_changed, this);
    }

    on_unmount() {
        super.on_unmount();
        rns.selected_track_observable.remove_notifier(this.on_track_changed, this);
        this.all_off();
    }

    all_off() {
        // for k in pairs(this.model.note_to_count) do
        for (const k in this.model.note_to_count) {
            //osc_renoise_send_note_off(k as number);
            // TODO: This works in Lua?
            osc_renoise_send_note_off(k as unknown as number);
            this.model.note_to_count[k] = null;
        }
        for (const k in this.grid_to_note) {
            this.grid_to_note[k] = null;
        }
    }

    transpose(delta: number) {
        // TODO: Let held grid pads carry out until released.
        this.all_off();

        //this.model.top_left_note = cLib.clamp_value(this.model.top_left_note + delta, RENOISE_MIDI.NOTE_MIN, RENOISE_MIDI.NOTE_MAX);
        const layout = driver.song_data.create_or_get_track_note_layout(this.name, rns.selected_track.name);
        layout.origin_note = RENOISE_MIDI.clamp_note_conservative(this.model.top_left_note, this.model.top_left_note + delta);
        this.model.top_left_note = layout.origin_note;
    }

    update_model(m: ModelNoteGrid) {
        if (this.invalid) {
            this.invalid = false;
            this.apply_layout();        
        }

        m.edit_mode = rns.transport.edit_mode;
        m.track_color = Color.rgb(rns.selected_track.color!);
        const columns = rns.selected_line.note_columns;
        rns.selected_note_column_index
        columns.forEach((note_column, i) => {
            m.cursor_notes[i] = note_column.note_value;
            if (i == rns.selected_note_column_index) {
                m.selected_column_note = note_column.note_value;
            }
        });
        m.cursor_notes.length = columns.length;            
    }

    render(rc: RenderContext, m: ModelNoteGrid) {
        super.render(rc, m);

        // TRACE("render", m)
        // rc.box(Rect(32, 32, 20, 20), 1)
        // rc.led_box(FIRE_LED_RECT_FULL, 0);

        // for x, y in this.note_grid_rect.iter_xy() do
        for (const [x, y] of this.note_grid_rect.iter_xy()) {
            const note = map_note(m.top_left_note, this.layout.x_pattern, this.layout.y_pattern, x - this.note_grid_rect.left, y - this.note_grid_rect.top);
            const color = note_color(m, note);
            rc.pad(x, y, color);

            // if (m.note_to_count[note] != null && m.note_to_count[note]! > 0) {
            //     rc.led_box(new Rect(8 * x, 16 * y, 8, 16), 1);
            // }
        }
        const x = this.grid_rect.left;
        const y = this.grid_rect.bottom() - 1;
        rc.pad(x, y, palette.NOTE_VALUE_EMPTY);
        rc.pad(x, y - 1, palette.NOTE_VALUE_OFF);
        if (this.note_grid_rect.height > 2) {
            rc.pad(x, y - 2, Color.black());
            rc.pad(x, y - 3, Color.black());
        }

        rc.light(FIRE_LIGHT.RowMute0, LIGHT_BRIGHT_GREEN);
        rc.light(FIRE_LIGHT.RowMute1, LIGHT_DARK_GREEN);
        rc.light(FIRE_LIGHT.RowMute2, LIGHT_DARK_GREEN);
        rc.light(FIRE_LIGHT.RowMute3, LIGHT_BRIGHT_GREEN);

        rc.light(FIRE_LIGHT.GridLeft, LIGHT_DARK_RED);
        rc.light(FIRE_LIGHT.GridRight, LIGHT_DARK_RED);

        rc.light(FIRE_LIGHT.RowSelect0, LIGHT_OFF);
        rc.light(FIRE_LIGHT.RowSelect1, LIGHT_OFF);
        rc.light(FIRE_LIGHT.RowSelect2, LIGHT_OFF);
        rc.light(FIRE_LIGHT.RowSelect3, LIGHT_OFF);
        const octave_index = math.floor((m.top_left_note - 24) / 12);
        if (octave_index >= 0 && octave_index < 8) {
            rc.light(FIRE_LIGHT.RowSelect0 + 3 - math.floor(octave_index / 2), bit.band(octave_index, 1) > 0 ? LIGHT_BRIGHT_GREEN : LIGHT_DARK_GREEN);
        }
    }
}
