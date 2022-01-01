// import { PatternTrack, PatternSelection } from "../../../renoise_types/renoise_song"
// import { rns } from '../global';
import '../global';
// declare let rns: any;

// function total_visible_columns(track: renoise.PatternTrack) {
function total_visible_columns(track: renoise.Track) {
    return track.visible_note_columns + track.visible_effect_columns;
}

// Considers selected_note_column_index AND selected_effect_column_index to determine singular overall column applicable to selections.
function rns_current_column() {
    let column = rns.selected_note_column_index;
    // if (column == 0) {
    //     column = rns.selected_track.visible_note_columns + rns.selected_effect_column_index
    // }
    if (column < 0) {
        rprint("negative one");
        column = rns.selected_track.visible_note_columns + rns.selected_effect_column_index - 1;
    }
    return column;
}

// A position within a pattern. All values are zero-based.
export class PatternPos {
    track: number;
    column: number;
    line: number;

    constructor(track: number, column: number, line: number) {
        this.track = track;
        this.column = column;
        this.line = line;
    }

    clone() {
        return new PatternPos(this.track, this.column, this.line);
    }

    set_column_last() {
        // TODO: Don't assume?
        // this.column = total_visible_columns(rns.track(this.track) as renoise.PatternTrack)
        this.column = total_visible_columns(rns.track(this.track)) - 1;
    }

    // [static] Create position from current edit cursor
    static current() {
        return new PatternPos(rns.selected_track_index, rns_current_column(), rns.selected_line_index);
    }
}

// A selection defined by start/} PatternPos
export class Selection {
    start_pos: PatternPos;
    end_pos: PatternPos;

    constructor(start_pos: PatternPos, end_pos: PatternPos) {
        this.start_pos = start_pos;
        this.end_pos = end_pos;
    }

    clone() {
        return new Selection(this.start_pos.clone(), this.end_pos.clone());
    }

    is_empty() {
        return this.start_pos.line > this.end_pos.line;
    }

    to_rns_selection(): renoise.PatternSelection | null {
        if (this.is_empty()) {
            return null;
        }

        // TODO: Elminate the manual shifts once the transformer can apply automatically
        //  to object literal property assignments mapping to inferred type.
        return {
            start_track: 1 + math.min(this.start_pos.track, this.end_pos.track),
            end_track: 1 + math.max(this.start_pos.track, this.end_pos.track),

            start_column: 1 + math.min(this.start_pos.column, this.end_pos.column),
            end_column: 1 + math.max(this.start_pos.column, this.end_pos.column),

            start_line: 1 + math.min(this.start_pos.line, this.end_pos.line),
            end_line: 1 + math.max(this.start_pos.line, this.end_pos.line),
        };
    }

    apply() {
        rns.selection_in_pattern = this.to_rns_selection();
    }

    expand_width() {
        if (this.start_pos.track == this.end_pos.track) {
            if (this.start_pos.column == this.end_pos.column) {
                this.start_pos.column = 0;
                this.end_pos.set_column_last();
            } else {
                this.start_pos.track = 0;
                this.start_pos.column = 0;
                this.end_pos.track = rns.sequencer_track_count;
                this.end_pos.set_column_last();
            }
        }
    }

    contract_width() {
        if (this.start_pos.track == this.end_pos.track) {
            if (this.start_pos.column != this.end_pos.column) {
                this.start_pos.column = rns_current_column();
                this.end_pos.column = this.start_pos.column;
            }
        } else {
            this.start_pos.track = rns.selected_track_index;
            this.start_pos.column = 0;
            this.end_pos.track = this.start_pos.track;
            this.end_pos.set_column_last();
        }
    }
}
