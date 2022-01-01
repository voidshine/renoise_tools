require('engine/selection')

import { PatternPos, Selection } from './selection'

// In general, Renoise API seems to work track by track, then line by line, THEN by columns.
// e.g.     renoise.NoteColumn
//          renoise.song().patterns[].tracks[].lines[].note_columns[].note_value
export class PatternBuffer {
    selection: Selection;

    constructor(selection: Selection) {
        this.selection = selection.clone();
        this.read();
    }

    read() {
    }

    write_to(pattern_pos: PatternPos) {
    }
}
