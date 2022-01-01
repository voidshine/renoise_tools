import { write_file, read_file } from "./utility";
import { Color } from "./color";
import { NoteGridLayout } from "./options";

export const PITCH_CLASS_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
const PITCH_CLASS_COLORS = PITCH_CLASS_NAMES.map((_, i) => Color.hsv([i / PITCH_CLASS_NAMES.length, 0.6, 0.1]));

class TrackData {
    layer_note_layouts: {[key: string]: NoteGridLayout;} = {};
}

export class SongData {
    // This is a shortcut.
    [key: string]: any;

    per_track: {[key: string]: TrackData} = {};

    // 0 = C, 1 = C#, etc.
    root_pitch_class: number = 0;

    rotate_colors_to_root: boolean = true;

    static get_filename() {
        return rns.file_name.replace(".xrns", "_pyre_data.json");        
    }

    static load_from_file(): SongData {
        let [content, error] = read_file(SongData.get_filename());
        return SongData.from_json(content);
    }

    static from_json(json: string | null): SongData {
        const data = new SongData();
        if (json != null) {
            const loaded = lunajson.decode(json);
            for (const key in loaded) {
                data[key] = loaded[key];
            }
        }
        return data;
    }

    save_to_file() {
        write_file(SongData.get_filename(), lunajson.encode(this));
    }

    get_track_data(track_name: string) {
        let data = this.per_track[track_name];
        if (!data) {
            data = new TrackData();
            this.per_track[track_name] = data;
        }
        return data;
    }

    // Color by pitch class.
    note_color(note: number) {
        if (this.rotate_colors_to_root) {
            note += PITCH_CLASS_COLORS.length - this.root_pitch_class;
        }
        return PITCH_CLASS_COLORS[note % PITCH_CLASS_COLORS.length];
    }

    create_or_get_track_note_layout(layer_name: string, track_name: string) {
        // Creates track data on demand, but it may still need to be populated.
        const track_data = this.get_track_data(track_name);
        let layout = track_data.layer_note_layouts[layer_name];
        if (!layout) {
            // Copy the default from tool settings.
            layout = this.clone_note_layout(driver.options.get_note_layout(layer_name));
            track_data.layer_note_layouts[layer_name] = layout;
        }
        return layout;
    }

    // Initialize a copy of given layout.
    clone_note_layout(from_layout: NoteGridLayout): NoteGridLayout {
        const layout = table.rcopy(from_layout);
        if (layout.use_song_root) {
            layout.origin_note += this.root_pitch_class;
        }
        return layout;
    }
}
