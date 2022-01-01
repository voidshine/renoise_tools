// General purpose utility library

// Rounds up if (necessary to next multiple of m. Keeps calculations in integer domain to avoid floating point issues.
export function modulo_up(i: number, m: number) {
    const r = i % m
    return r == 0 ? i : (i + m - r);
}
export function modulo_down(i: number, m: number) {
    return i - (i % m);
}

export function table_clear(t: any) {
    //for k in pairs(t) {
    for (const k in t) {
        t[k] = null;
    }
}

// function table_extend_keys(t: any, e: any) {
//     for (const key in e) {
//         const v = e[key];
//         t[key] = v
//     }
// }

// export function table_extend_array(t, e) {
//     e.forEach((v, _) => {
//         table.insert(t, v)
//     }
// }

export function select_first_track_column() {
    if (rns.selected_track.visible_note_columns > 0) {
        rns.selected_note_column_index = 0;
    } else {
        rns.selected_effect_column_index = 0;
    }
}

export function select_last_track_column() {
    if (rns.selected_track.visible_effect_columns > 0) {
        rns.selected_effect_column_index = rns.selected_track.visible_effect_columns - 1;
    } else {
        rns.selected_note_column_index = rns.selected_track.visible_note_columns - 1;
    }
}

// xColumns implementation has bugs, so here's a general function.
// delta may be 1 or -1 only.
export function step_note_column(delta: number, wrap_pattern: boolean, wrap_track: boolean) {
    let track = rns.selected_track;
    let column_index = rns.selected_note_column_index;
    if (column_index < 0) {
        // Note column not selected; FX columns are right of note columns
        if (delta > 0) {
            // Act as if on rightmost note column.
            column_index = track.visible_note_columns - 1;
        } else {
            // Prepare to enter note columns on this track.
            column_index = track.visible_note_columns;
        }
    }
    if (wrap_track) {
        column_index = (column_index + delta + track.visible_note_columns) % track.visible_note_columns;
    } else {
        column_index += delta;
        if (column_index < 0) {
            xTrack.jump_to_previous_sequencer_track();
            track = rns.selected_track;
            column_index = track.visible_note_columns - 1;
        } else if (column_index >= track.visible_note_columns) {
            xTrack.jump_to_next_sequencer_track();
            column_index = 0;
        }
    }
    if (column_index >= 0 && column_index < track.max_note_columns) {
        rns.selected_note_column_index = column_index;
    }
}

// steps may be positive or negative to move forward or backward, by tracks, note columns, or else any kind of column.
// TODO: This logic is not fully implemented for all combinations.
export function step_track_column(steps: number, whole_tracks: boolean, skip_collapsed_tracks: boolean, note_columns: boolean) {
    if (skip_collapsed_tracks && rns.tracks.every(track => track.collapsed)) {
        // When all are collapsed, we cannot allow skipping of collapsed tracks; it makes more sense to just take a natural step.
        skip_collapsed_tracks = false;
    }
    const start_track_index = rns.selected_track_index;
    while (steps > 0) {
        steps--;
        do {
            if (rns.selected_track.collapsed) {
                select_last_track_column();
            }

            if (whole_tracks) {
                const track_count = rns.tracks.length;
                rns.selected_track_index = (rns.selected_track_index + 1) % track_count;
            } else if (note_columns) {
                step_note_column(1, true, false);
            } else {
                xColumns.next_column();
            }
        } while (skip_collapsed_tracks && rns.selected_track.collapsed && rns.selected_track_index != start_track_index);
    }
    while (steps < 0) {
        steps++;
        do {
            if (rns.selected_track.collapsed) {
                select_first_track_column();
            }

            if (whole_tracks) {
                const track_count = rns.tracks.length;
                rns.selected_track_index = (rns.selected_track_index + track_count - 1) % track_count;
            } else if (note_columns) {
                step_note_column(-1, true, false);
            } else {
                xColumns.previous_column();
            }
        } while (skip_collapsed_tracks && rns.selected_track.collapsed && rns.selected_track_index != start_track_index);
    }
}

// Saw wave from 1 down to 0 @ n Hz (1 by default)
export function clock_pulse(n: number = 1) {
    return 1 - ((os.clock() * n) % 1);
}

/** @tupleReturn */
export function read_file(path: string): [string | null, string | null] {
    rprint(`Read file: ${path}`);
    if (!io.exists(path)) {
        return [null, `Path not found: ${path}`];
    }
    //const f = assert(io.open(path, "rb")) as any;
    const [f] = io.open(path, "rb");
    // const content = f!.read("*all");
    const content = (f as any).read("*all");
    f!.close();
    return [content, null];
}

export function write_file(path: string, content: any) {
    rprint(`Write file: ${path}; content = ${content}`);
    // NOTE: assert is putting parameters into an object in Lua compiled output; not same semantics as in Lua!
    // const f = assert(io.open(path, "wb")) as any;
    const [f] = io.open(path, "wb");
    f!.write(content);
    f!.close();
}

/** @tupleReturn */
export function load_json(path: string) {
    const [json, error] = read_file(path);
    if (error) {
        return [null, error];
    }
    
    // TODO: trap lunajson errors!
    return [lunajson.decode(json as string), null];
}

export function save_json(path: string, model: any) {
    write_file(path, lunajson.encode(model));
}

function index_by_key(t: any, key: string) {
    const index: any = {}
    for (const key in t) {
        const v = t[key];
        // rprint(v)
        // oprint(v[key])
        index[v[key]] = v;
    }
    return index;
}

// Compares numerically indexed tables item by item.
// function sequences_equal(table_a, table_b)
//     if (#table_a ~= #table_b) {
//         return false
//     }
//     const iter_a, invariant_a, control_a = ipairs(table_a)
//     const iter_b, invariant_b, control_b = ipairs(table_b)

//     const control_a, value_a = iter_a(invariant_a, control_a)
//     const control_b, value_b = iter_b(invariant_b, control_b)
//     while control_a && control_b do
//         rprint {ca = control_a, cb = control_b, va = value_a, vb = value_b}
//         if (control_a ~= control_b or value_a ~= value_b) {
//             return false
//         }
//         control_a, value_a = iter_a(invariant_a, control_a)
//         control_b, value_b = iter_b(invariant_b, control_b)
//     }
//     // At least one of these is null, but is the other also?
//     return control_a == control_b
// }
// TODO: clean up or move tests
// assert(not sequences_equal({5, "", 0.5, false}, {5, "", 0.5, false, 1}))
// assert(sequences_equal({}, {}))
// assert(sequences_equal({5, "", 0.5, false}, {5, "", 0.5, false}))
// assert(not sequences_equal({5, "", 0.5, false, 5}, {5, "", 0.5, false}))
// const x = {99, "true"}
// assert(sequences_equal(x, x))
// assert(sequences_equal({x}, {x}))
// assert(not sequences_equal({{x}}, {{x}}))   // Goes one level deep only; the elements are unique objects.
// const out_of_order = { [2] = "cd", [1] = "ab" }
// assert(sequences_equal({ "ab", "cd" }, out_of_order ))
// assert(sequences_equal({ "ab", "cd" }, { "ab", "cd" }))
// assert(sequences_equal({ "ab", "cd" }, { [2] = "cd", "ab" }))   // "ab" goes to first available index, which is 1

export class Vec2 {
    x: number;
    y: number;


    // If y is omitted, x is considered another Vec2 instance to copy from
    constructor(other: Vec2);
    constructor(x: number, y: number);
    constructor(x: Vec2 | number, y?: number) {
        if (y) {
            this.x = x as number;
            this.y = y;
        } else {
            x = x as Vec2;
            this.x = x.x;
            this.y = x.y;
        }
    }

    __add(rhs: Vec2) {
        return new Vec2(this.x + rhs.x, this.y + rhs.y);
    }

    __sub(rhs: Vec2) {
        return new Vec2(this.x - rhs.x, this.y - rhs.y);
    }

    // Iterates from (0, 0) up to (x, y), *excluding* points at right and bottom bounds (x, *) and (*, y)
    iter_range(): LuaIterable<Vec2> {
        let at_x = 0;
        let at_y = 0;
        return (() => {
            if (at_y < this.y) {
                const pos = new Vec2(at_x, at_y);
                at_x = at_x + 1;
                if (at_x >= this.x) {
                    at_x = 0;
                    at_y = at_y + 1;
                }
                return pos;
            } else {
                return null;
            }
        }) as any;
    }

    area() {
        return this.x * this.y
    }

    contains_xy(x: number, y: number) {
        return x >= 0 && y >= 0 && x < this.x && y < this.y;
    }

    contains_pos(pos: Vec2) {
        return pos.x >= 0 && pos.y >= 0 && pos.x < this.x && pos.y < this.y;
    }
}

export class Rect {
    left: number;
    top: number;
    width: number;
    height: number;

    // Constructor forms: Rect(left, top, width, height) with scalars; or Rect(pos, size) with `Vec2`s
    constructor(pos: Vec2, size: Vec2);
    constructor(left: number, top: number, width: number, height: number);
    constructor(left_or_pos: number | Vec2, top_or_size: number | Vec2, width?: number, height?: number) {
        if (width) {
            this.left = left_or_pos as number;
            this.top = top_or_size as number;
            this.width = width;
            this.height = height as number;
        } else {
            const pos = left_or_pos as Vec2;
            const size = top_or_size as Vec2;
            this.left = pos.x;
            this.top = pos.y;
            this.width = size.x;
            this.height = height = size.y;
        }
    }

    clone() {
        return new Rect(this.left, this.top, this.width, this.height);
    }

    set(from: Rect) {
        this.left = from.left
        this.top = from.top
        this.width = from.width
        this.height = from.height
    }

    // TODO: Investigate @tupleReturn for performance?
    // iter_xy(): LuaTupleIterable<number[]> {
    iter_xy(): LuaIterable<[number, number]> {
        let at_x = this.left;
        let at_y = this.top;
        // return (/** @tupleReturn */() => {
        return (() => {
            if (at_y < this.top + this.height) {
                let x = at_x;
                let y = at_y;
                at_x = at_x + 1;
                if (at_x >= this.left + this.width) {
                    at_x = this.left;
                    at_y = at_y + 1;
                }
                return [x, y];
            } else {
                return null;
            }
        }) as any;// as unknown as LuaTupleIterable<number[]>;
    }

    // TODO: Test this.
    iter_pos(): LuaIterable<Vec2> {
        const iter_xy = this.iter_xy();
        return (() => {
            const [x, y] = (iter_xy as any)();
            print(`${x}, ${y}`);
            if (x) {
                return [new Vec2(x, y)];
            } else {
                return null;
            }
        }) as any;// as unknown as LuaIterable<Vec2>;
    }

    // iter_x(): LuaIterable<number> {
    //     let x = -1;
    //     return (() => {
    //         x++;
    //         if (x < this.width) {
    //             return x + this.left;
    //         } else {
    //             return null;
    //         }
    //     }) as any;
    // }

    // Exclusive bounds; not included in the rectangle.
    right() {
        return this.left + this.width
    }
    bottom() {
        return this.top + this.height
    }

    sub_rect(x: number, y: number, w: number, h: number) {
        return new Rect(this.left + x, this.top + y, w, h);
    }

    area() {
        return this.width * this.height
    }

    contains(pos: Vec2) {
        return pos.x >= this.left && pos.y >= this.top && pos.x < this.right() && pos.y < this.bottom()
    }

    pos() {
        return new Vec2(this.left, this.top);
    }

    size() {
        return new Vec2(this.width, this.height);
    }

    include_xy(x: number, y: number) {
        this.left = math.min(this.left, x);
        this.top = math.min(this.top, y);
        this.width = math.max(this.width, x - this.left + 1);
        this.height = math.max(this.height, y - this.top + 1);
    }

    // expand bounds to include pos
    include_pos(pos: Vec2) {
        this.left = math.min(this.left, pos.x);
        this.top = math.min(this.top, pos.y);
        this.width = math.max(this.width, pos.x - this.left + 1);
        this.height = math.max(this.height, pos.y - this.top + 1);
    }

    corners() {
        return [[this.left, this.top], [this.right(), this.top], [this.right(), this.bottom()], [this.left, this.bottom()]];
    }
}
