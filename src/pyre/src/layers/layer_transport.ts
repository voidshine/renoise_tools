import { LayerCommon, ModelCommon } from './layer_common';
import * as defs from '../engine/fire_defs';
import { PALETTE } from '../palette';
import { RenderContext } from '../engine/render_context';
import { ModelLayer } from '../engine/model_layer';

const palette = PALETTE.TRANSPORT

class ModelTransport extends ModelCommon {
    __eq(rhs: any) { return super.__eq(rhs); }
    playing = false;
    edit_mode = false;
    can_redo = false;
}

export class LayerTransport extends LayerCommon<ModelTransport> {
    constructor() {
        super(new ModelTransport(), 'Transport');

        this.set_note_on_handlers({
            [defs.FIRE_BUTTON.PatternSongMetronome]: (_note, _velocity) => { this.on_press_pattern(); },
            [defs.FIRE_BUTTON.Record]: this.on_press_record,
            [defs.FIRE_BUTTON.Stop]: this.on_press_stop,
            [defs.FIRE_BUTTON.PlayWait]: this.on_press_play,
        });
    }

    on_idle() {
        this.model.playing = rns.transport.playing;
        this.model.edit_mode = rns.transport.edit_mode;
        this.model.can_redo = rns.can_redo();
    }

    render(rc: RenderContext, m: any) {
        // LayerCommon.render(this, rc, m)
        super.render(rc, m);

        rc.light(defs.FIRE_LIGHT.PatternSongMetronome, m.can_redo ? palette.CAN_REDO : palette.UNDO_ONLY)
        rc.light(defs.FIRE_LIGHT.Record, m.edit_mode ? palette.EDIT_MODE : palette.OFF)
        rc.light(defs.FIRE_LIGHT.PlayWait, !m.playing ? palette.PLAYING : palette.OFF)
        rc.light(defs.FIRE_LIGHT.Stop, m.playing ? palette.STOP : palette.OFF)
    }

    on_press_record() {
        rns.transport.edit_mode = !rns.transport.edit_mode;
    }

    on_press_stop() {
        const playing = rns.transport.playing;
        // stop even if (not playing because user may want to turn off all notes
        rns.transport.stop();
        if (!playing) {
            // TODO: jump to start of current pattern
        }
    }

    on_press_play() {
        // TODO: support alternative play mode (with modifier key or double-tap?)

        // rns.transport.start(renoise.Transport.PLAYMODE_CONTINUE_PATTERN)
        rns.transport.start(renoise.Transport.PLAYMODE.PLAYMODE_RESTART_PATTERN);
    }

    on_press_pattern() {
        if (this.model.shift) {
            rns.redo();
        } else {
            rns.undo();
        }
    }
}
