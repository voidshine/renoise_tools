import { LayerCommon, ModelCommon } from './layer_common';
import { RenderContext } from '../engine/render_context';
import { ModelLayer } from '../engine/model_layer';
import { Rect, clock_pulse, table_clear } from '../engine/utility';
import * as defs from '../engine/fire_defs';

import { PALETTE } from '../palette';
import { Color } from '../engine/color';
import { RENOISE_MIDI } from '../engine/common';
import { KnobTime, KnobColumnSelect, KnobAlt, KnobQuantizingClosure, Knob } from '../engine/knob';
import { Options } from '../engine/options';

const palette = PALETTE.WIDE_STEP_EDIT;
const PULSE_RATE_SELECTED = 2.5;

interface MultiSelect {
    [key: number]: boolean | null;
}

class ModelWideStepEdit extends ModelCommon {
    __eq(rhs: any) { return super.__eq(rhs); }

    // Number of steps shown on a page.
    steps_per_page = 16;

    // Number of lines per step.
    lines_per_step: number = 1;

    view_start_step = 0;

    // Selection consists of a primary cursor plus a selection mask with offsets that
    //  may be ahead of or behind the cursor.
    cursor_line: number = -1;
    selection_step_offsets: MultiSelect = new ModelLayer() as any;

    page_colors: Color[] = new ModelLayer() as any;
    note_colors: Color[] = new ModelLayer() as any;

    view_page(): number {
        return math.floor(this.view_start_step / this.steps_per_page);
    }

    cursor_step() {
        return math.floor(this.cursor_line / this.lines_per_step);
    }

    cursor_page(): number {
        return math.floor(this.cursor_step() / this.steps_per_page);
    }

    cursor_step_in_page(): number {
        return this.cursor_step() % this.steps_per_page;
    }

    is_step_selected(at: number): boolean {
        return this.selection_step_offsets[at - this.cursor_step()] == true;
    }

    // Line offset *within* current step. Always line_offset() < lines_per_step.
    line_offset(): number {
        return this.cursor_line % this.lines_per_step;
    }

    adjust_line_offset(delta: number) {
        // delta %= this.lines_per_step;
        // const new_line_offset = (this.line_offset() + this.lines_per_step + delta) % this.lines_per_step;
        const new_line_offset = cLib.clamp_value(this.line_offset() + delta, 0, this.lines_per_step - 1);

        // For now, tied to real Renoise cursor.
        const cursor_line = this.cursor_step() * this.lines_per_step + new_line_offset;
        if (cursor_line >= 0 && cursor_line < rns.selected_pattern.number_of_lines) {
            rns.selected_line_index = cursor_line;
        }
    }

    step_line(step: number): number {
        return step * this.lines_per_step + this.line_offset();
    }
}

type StepEdit = (step: number, line: renoise.PatternLine, note_column: renoise.NoteColumn | null) => void;

export class LayerWideStepEdit extends LayerCommon<ModelWideStepEdit> {
    navigation_rect = new Rect(0, 0, defs.FIRE_GRID_WIDTH, 2);

    on_page_hold_count = 0;

    edit_knobs: (Knob | null)[];

    constructor() {
        super(new ModelWideStepEdit(), 'Wide Step Edit');

        // Default selection is just current step.
        this.model.selection_step_offsets[0] = true;

        this.set_note_handlers_grid_rect(this.navigation_rect, (x, y, velocity) => {
            if (velocity) {
                if (y == 0) {
                    const step_in_page = this.model.cursor_step_in_page();
                    this.set_view_start(x * this.model.steps_per_page);
                    this.move_to(this.model.view_start_step + step_in_page);
                } else {
                    if (this.model.shift || this.on_page_hold_count > 0) {
                        const offset = this.model.view_start_step + x - this.model.cursor_step();
                        this.model.selection_step_offsets[offset] = this.model.selection_step_offsets[offset] ? null : true;
                    } else if (this.model.alt) {
                        // Move cursor and reset selection to only this step.
                        this.move_to(this.model.view_start_step + x);
                        table_clear(this.model.selection_step_offsets);
                        this.model.selection_step_offsets[0] = true;
                    } else {
                        // Move cursor, preserving selection.
                        this.move_to(this.model.view_start_step + x);
                    }
                    this.on_page_hold_count++;
                }
            } else {
                if (y == 1) {
                    this.on_page_hold_count--;
                }
            }
        });

        const self = this;
        this.edit_knobs = [
            new KnobAlt(this.model, [new KnobTime(driver.options.knob_sensitivity(false, false)), new KnobTime(driver.options.knob_sensitivity(true, false))]),

            new KnobAlt(this.model, [
                new KnobQuantizingClosure('Line Offset', driver.options.knob_sensitivity(false, true), delta => {
                    self.model.adjust_line_offset(delta);
                    renoise.app().show_status(`Line Offset: ${self.model.line_offset()}`);
                }),
                new KnobQuantizingClosure('Lines per Step', driver.options.knob_sensitivity(false, true), delta => {
                    self.model.lines_per_step = cLib.clamp_value(self.model.lines_per_step + delta, 1, rns.selected_pattern.number_of_lines);
                    renoise.app().show_status(`Lines per Step: ${self.model.lines_per_step}`);
                }),
                new KnobQuantizingClosure('Steps per Page', driver.options.knob_sensitivity(false, true), delta => {
                    self.model.steps_per_page = cLib.clamp_value(self.model.steps_per_page + delta, 1, this.navigation_rect.width);
                    renoise.app().show_status(`Steps per Page: ${self.model.steps_per_page}`);
                }),
            ]),
            //new KnobAlt(this.model, [new KnobColumnSelect(false, false, driver.options.knob_sensitivity(false, true)), new KnobColumnSelect(false, false, driver.options.knob_sensitivity(true, true))]),

            new KnobQuantizingClosure('Note Pitches +/-', driver.options.knob_sensitivity(false, true), delta => self.adjust_selected_steps((step, line, note_column) => {
                if (note_column && RENOISE_MIDI.is_in_note_range(note_column.note_value)) {
                    if (self.model.alt) {
                        // By octaves.
                        delta *= 12;
                    } else if (self.model.shift) {
                        // By fifths.
                        delta *= 7;
                    } // else naturally by semitones.
                    note_column.note_value = RENOISE_MIDI.clamp_note_conservative(note_column.note_value, note_column.note_value + delta);
                }
            })),
            // TODO: Handle knob press to change to heat map visualizing volumes of all steps.
            new KnobQuantizingClosure('Note Volumes +/-', driver.options.knob_sensitivity(false, false), delta => self.adjust_selected_steps((step, line, note_column) => {
                if (note_column) {
                    let value = note_column.volume_value;
                    if (value == RENOISE_MIDI.VOLUME_EMPTY) {
                        value = rns.transport.keyboard_velocity;
                    }
                    note_column.volume_value = cLib.clamp_value(value + delta, RENOISE_MIDI.VOLUME_MIN, RENOISE_MIDI.VOLUME_MAX);
                }
            })),
            null,
        ];
    }

    adjust_selected_steps(edit: StepEdit) {
        // Apply edits to all selected steps.
        for (const [offset, _] of pairs(this.model.selection_step_offsets)) {
            const step = this.model.cursor_step() + offset;
            this.adjust_step(step, edit);
        }
    }

    adjust_step(step: number, edit: StepEdit) {
        if (!rns.transport.edit_mode || rns.selected_note_column_index < 0) {
            return;
        }
        const line_index = this.model.step_line(step);
        if (line_index >= 0 && line_index < rns.selected_pattern.number_of_lines) {
            const pattern_track = rns.selected_pattern_track;
            const line = pattern_track.line(line_index);
            const note_column = line.note_column(rns.selected_note_column_index);
            edit(step, line, note_column);
        }
    }

    adjust_step_note(step: number, from_note: number, note: number) {
        this.adjust_step(step, (step, line, note_column) => {
            if (note_column) {
                if (RENOISE_MIDI.is_in_note_range(from_note) && RENOISE_MIDI.is_in_note_range(note_column.note_value) && RENOISE_MIDI.is_in_note_range(note)) {
                    // Shift current note by difference, iff it stays in valid range.
                    const to = note_column.note_value + note - from_note;
                    if (RENOISE_MIDI.is_in_note_range(to)) {
                        note_column.note_value = to;
                    }
                } else {
                    // Use note as is; may be empty or off.
                    note_column.note_value = note;

                    if (note == RENOISE_MIDI.NOTE_VALUE_EMPTY) {
                        note_column.clear();
                    }
                }
            }
        });
    }

    note_at_step(step: number): number {
        if (rns.selected_note_column_index < 0) {
            return RENOISE_MIDI.NOTE_VALUE_EMPTY;
        }
        return rns.selected_pattern_track.line(this.model.step_line(step)).note_column(rns.selected_note_column_index).note_value;
    }

    on_note(note: number, velocity: number | null): boolean {
        // print(note, velocity);

        // Apply edits to all selected steps.
        const from_note = this.note_at_step(this.model.cursor_step());
        for (const [offset, _] of pairs(this.model.selection_step_offsets)) {
            const step = this.model.cursor_step() + offset;
            this.adjust_step_note(step, from_note, note);
        }

        // Don't allow pass-through to note grid default handler, which might send MIDI, etc.
        return false;
    }

    move_to(step: number) {
        const line_index = this.model.step_line(step);
        if (line_index >= 0 && line_index < rns.selected_pattern.number_of_lines) {
            this.model.cursor_line = line_index;
            rns.selected_line_index = line_index;
        }
    }

    set_view_start(start_step: number) {
        this.model.view_start_step = start_step;
    }

    update_model(m: ModelWideStepEdit) {
        m.cursor_line = rns.selected_line_index;

        if (rns.transport.follow_player) {
            if (m.cursor_step() < m.view_start_step || m.cursor_step() >= (m.view_start_step + m.steps_per_page)) {
                this.set_view_start(m.steps_per_page * math.floor(m.cursor_step() / m.steps_per_page));
            }
        }

        const pattern_track = rns.selected_pattern_track;
        const lines = pattern_track.lines;
        const note_column_index = rns.selected_note_column_index;
        const view_page = m.view_page();

        for (let page = 0; page < this.navigation_rect.width; page++) {
            let page_color = palette.BACKGROUND_VOID;
            if (page * m.steps_per_page * m.lines_per_step < lines.length) {
                page_color = palette.BACKGROUND_EMPTY;
                if (page == view_page) {
                    for (let step_in_page = 0; step_in_page < this.navigation_rect.width; step_in_page++) {
                        if (step_in_page < m.steps_per_page) {
                            const step = page * m.steps_per_page + step_in_page;
                            const line = m.step_line(step);
                            if (line >= lines.length) {
                                break;
                            }
                            const note = note_column_index >= 0 ? lines[line].note_column(note_column_index).note_value : RENOISE_MIDI.NOTE_VALUE_EMPTY;
    
                            m.note_colors[step_in_page] =
                                note == RENOISE_MIDI.NOTE_VALUE_OFF ? palette.NOTE_OFF :
                                note == RENOISE_MIDI.NOTE_VALUE_EMPTY ? palette.BACKGROUND_EMPTY :
                                //palette.NOTE;
                                driver.song_data.note_color(note);
                            if (step == m.cursor_step()) {
                                //m.note_colors[i] = m.note_colors[i].with_hsv_value(clock_pulse());
                                if (m.is_step_selected(step)) {
                                    m.note_colors[step_in_page] = m.note_colors[step_in_page].with_hsv_value(clock_pulse(PULSE_RATE_SELECTED));
                                } else {
                                    m.note_colors[step_in_page] = m.note_colors[step_in_page].with_hsv_value(clock_pulse());
                                }
                            } else if (m.is_step_selected(step)) {
                                m.note_colors[step_in_page] = m.note_colors[step_in_page].with_hsv_value(clock_pulse(PULSE_RATE_SELECTED) / 5);
                            }
                        } else {
                            m.note_colors[step_in_page] = palette.BACKGROUND_VOID;
                        }
                    }
                } else {
                    for (let step_in_page = 0; step_in_page < m.steps_per_page; step_in_page++) {
                        const step = page * m.steps_per_page + step_in_page;
                        const line = m.step_line(step);
                        if (line >= lines.length) {
                            break;
                        }
                        const note = note_column_index >= 0 ? lines[line].note_column(note_column_index).note_value : RENOISE_MIDI.NOTE_VALUE_EMPTY;

                        // if (note != RENOISE_MIDI.NOTE_VALUE_EMPTY) {
                        //     color = palette.OCCUPIED_PAGE;
                        // }
                        if (page_color == palette.BACKGROUND_EMPTY && RENOISE_MIDI.is_in_note_range(note)) {
                            page_color = driver.song_data.note_color(note);
                        }
                    }
                }
            }
            if (view_page == page) {
                // Mark selected page with pulse.
                page_color = page_color.with_hsv_value(clock_pulse() % 1);
            }
            m.page_colors[page] = page_color;
        }
    }

    render(rc: RenderContext, m: ModelWideStepEdit) {
        rc.clear_grid(this.navigation_rect);
        for (let x = this.navigation_rect.left; x < this.navigation_rect.right(); x++) {
            rc.pad(x, 0, m.page_colors[x] || palette.BACKGROUND_VOID);
        }
        for (let x = this.navigation_rect.left; x < this.navigation_rect.right(); x++) {
            rc.pad(x, 1, m.note_colors[x] || palette.BACKGROUND_VOID);
        }
        // m.page_colors.forEach((page, i) => {
        //     rc.pad(i, 0, page);
        // });
        // m.note_colors.forEach((note, i) => {
        //     rc.pad(i, 1, note);
        // });
    }
}
