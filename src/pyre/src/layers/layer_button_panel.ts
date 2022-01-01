import { grid_xy_to_midi_note } from '../engine/fire_defs';
import {Layer, NoteOnHandler} from '../engine/layer';
import {Rect} from '../engine/utility';
import { RenderContext } from '../engine/render_context';
import { ModelLayer } from '../engine/model_layer';
import { Color } from '../engine/color';

export interface ButtonSpec {
    name?: string;
    color: Color;
    action?(): void;

    x?: number;
    y?: number;
}

export class LayerButtonPanel extends Layer {
    grid_rect: Rect;
    buttons: ButtonSpec[];
    
    constructor(grid_rect: Rect, buttons: ButtonSpec[]) {
        super(new ModelLayer(), 'Button Panel')

        this.grid_rect = grid_rect;
        this.buttons = buttons;

        const iter = this.grid_rect.iter_xy() as any as (() => number[]);
        buttons.forEach((button, i) => {
            // [button.x, button.y] = iter.next().value as number[];   // TODO: ?
            [button.x, button.y] = iter();
            // skip empty placeholder slots
            if (button.action) {
                this.note_on_handlers[grid_xy_to_midi_note(button.x!, button.y!)] = function(note, velocity) {
                    rprint(button.name);
                    button.action!();
                }
            }
        });
    }

    render(rc: RenderContext, m: ModelLayer) {
        this.buttons.forEach((button, _) => {
            rc.pad(button.x!, button.y!, button.color)
        });
    }
}
