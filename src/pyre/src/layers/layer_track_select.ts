import { GridPadHandler, Layer } from '../engine/layer';
import { PALETTE } from '../palette';
import { Rect, clock_pulse } from '../engine/utility';
import { FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT, FIRE_BUTTON } from '../engine/fire_defs';
import { ModelLayer } from '../engine/model_layer';
import { Color } from '../engine/color';
import { RenderContext } from '../engine/render_context';

const palette = PALETTE.TRACK_SELECT;

class ModelTrackSelect extends ModelLayer {
    __eq(rhs: any) { return super.__eq(rhs); }
    offset = 0
    track_colors = new ModelLayer();
    track_mutes = new ModelLayer();
    track_solos = new ModelLayer();
    column_and_device_colors = new ModelLayer();
}

export class LayerTrackSelect extends Layer<ModelTrackSelect> {
    grid_rect: Rect;
    constructor(grid_rect: Rect | null) {
        super(new ModelTrackSelect(), 'Track Select')

        this.grid_rect = grid_rect || new Rect(0, 0, FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT);

        const on_grid_pad: GridPadHandler = (x, y, velocity) => {
            if (velocity) {
                x = x + this.model.offset;

                assert(rns.sequencer_track_count + 1 + rns.send_track_count == rns.tracks.length);
                if (y < 3 && x < rns.tracks.length) {
                    if (y == 0) {
                        // It seems Renoise has this indexing structure: sequencer tracks,) { master track,) { send tracks
                        // if (x >= 0 && x < rns.sequencer_track_count) {
                        if (x >= 0) {
                            // rns.selected_track_index = 1 + x
                            rns.selected_track_index = x;
                        }
                    } else if (y == 1) {
                        //const track = rns.track(1 + x)
                        const track = rns.track(x);
                        if (track && track.type != renoise.Track.TRACK_TYPE.TRACK_TYPE_MASTER) {
                            track.mute_state = (track.mute_state == renoise.Track.MUTE_STATE.MUTE_STATE_ACTIVE ? renoise.Track.MUTE_STATE.MUTE_STATE_MUTED : renoise.Track.MUTE_STATE.MUTE_STATE_ACTIVE)
                        }
                    } else if (y == 2) {
                        //const track = rns.track(1 + x)
                        const track = rns.track(x);
                        if (track && track.type != renoise.Track.TRACK_TYPE.TRACK_TYPE_MASTER) {
                            track.solo_state = !track.solo_state;
                        }
                    }
                } else if (y == 3) {
                    if (x < rns.selected_track.visible_note_columns) {
                        // Note column
                        //rns.selected_note_column_index = x + 1
                        rns.selected_note_column_index = x;
                    } else {
                        x = x - rns.selected_track.visible_note_columns
                        if (x < rns.selected_track.visible_effect_columns) {
                            // Effect column
                            // rns.selected_effect_column_index = x + 1
                            rns.selected_effect_column_index = x;
                        } else {
                            // Track device
                            x = x - rns.selected_track.visible_effect_columns
                            if (x >= 0 && x < rns.selected_track.devices.length) {
                                //rns.selected_track_device_index = x + 1
                                rns.selected_track_device_index = x;
                            }
                        }
                    }
                }
            }
        }
        this.set_note_handlers_grid_rect(this.grid_rect, on_grid_pad);

        this.set_note_on_handlers({
            [FIRE_BUTTON.GridLeft]: () => { this.on_press_grid_left_right(-1); },
            [FIRE_BUTTON.GridRight]: () => { this.on_press_grid_left_right(1); },
        });
    }

    width() {
        return this.grid_rect.width;
    }

    on_press_grid_left_right(delta: number) {
        const max = rns.tracks.length - (rns.tracks.length % this.width());
        this.model.offset = cLib.clamp_value(this.model.offset + this.width() * delta, 0, max);
    }

    // on_mount() {
    //     // TODO: Clear grid && update_model
    // }

    update_model(m: any) {
        m.selected_track_index = rns.selected_track_index
        m.selected_track_device_index = rns.selected_track_device_index
        //for i = 1, this.width() do
        for (let i = 0; i < this.width(); i++) {
            // Tracks
            const track_index: number = i + m.offset;
            //const track = rns.tracks[track_index + 1];
            const track = rns.tracks[track_index];
            let color = track ? Color.rgb(track.color!) : palette.BACKGROUND;
            if (track_index == m.selected_track_index) {
                const hsv = color.to_hsv();
                //hsv[3] = hsv[3] * clock_pulse();
                hsv[2] = hsv[2] * clock_pulse();
                // color = Color.gray(clock_pulse() * 255)
                color = Color.hsv(hsv);
            }
            m.track_colors[i] = color;

            // Mute & Solo
            if (track) {
                // renoise.Track.MUTE_STATE_ACTIVE
                // renoise.Track.MUTE_STATE_OFF
                // renoise.Track.MUTE_STATE_MUTED
                m.track_mutes[i] = (track.mute_state == renoise.Track.MUTE_STATE.MUTE_STATE_ACTIVE) ? palette.TRACK_ACTIVE :
                    ((track.mute_state == renoise.Track.MUTE_STATE.MUTE_STATE_OFF) ? palette.TRACK_OFF : palette.TRACK_MUTE)
                m.track_solos[i] = track.solo_state ? palette.TRACK_SOLO_ON : palette.TRACK_SOLO_OFF;
            } else {
                m.track_mutes[i] = palette.BACKGROUND;
                m.track_solos[i] = palette.BACKGROUND;
            }
        }

        // Note columns
        let offset = 0;
        //for i = 1, rns.selected_track.visible_note_columns do
        for (let i = 0; i < rns.selected_track.visible_note_columns; i++) {
            m.column_and_device_colors[i] = (i == rns.selected_note_column_index) ? palette.NOTE_COLUMN_SELECTED : palette.NOTE_COLUMN;
        }
        offset = offset + rns.selected_track.visible_note_columns;

        // Effect columns
        //for i = 1, rns.selected_track.visible_effect_columns do
        for (let i = 0; i < rns.selected_track.visible_effect_columns; i++) {
            m.column_and_device_colors[offset + i] = (i == rns.selected_effect_column_index) ? palette.EFFECT_COLUMN_SELECTED : palette.EFFECT_COLUMN;
        }
        offset = offset + rns.selected_track.visible_effect_columns;

        // Track devices
        //for i = 1, rns.selected_track.devices.length do
        for (let i = 0; i < rns.selected_track.devices.length; i++) {
            let color;
            if (i == m.selected_track_device_index) {
                color = Color.white();
            } else {
                color = Color.gray(80);
            }
            m.column_and_device_colors[offset + i] = color;
        }
        offset = offset + rns.selected_track.devices.length;

        //for i = offset + 1, this.width() do
        for (let i = offset; i < this.width(); i++) {
            m.column_and_device_colors[i] = Color.black();
        }
    }

    render(rc: RenderContext, m: any) {
        rc.clear_grid(this.grid_rect)
        //for i = 1, this.width() do
        for (let i = 0; i < this.width(); i++) {
            // const x = (i - 1) + this.grid_rect.left;
            const x = i + this.grid_rect.left;
            const y = this.grid_rect.top;
            rc.pad(x, y, m.track_colors[i]);
            rc.pad(x, y + 1, m.track_mutes[i]);
            rc.pad(x, y + 2, m.track_solos[i]);
            rc.pad(x, y + 3, m.column_and_device_colors[i]);
        }
    }
}
