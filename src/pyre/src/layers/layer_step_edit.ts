import { Selection, PatternPos } from '../engine/selection';
import { ButtonSpec, LayerButtonPanel } from './layer_button_panel';
import { PALETTE } from '../palette';
import { Layer } from '../engine/layer';
import { LayerLineSelect } from './layer_line_select';
import { Rect } from '../engine/utility';
import { FIRE_GRID_HEIGHT, FIRE_KNOB } from '../engine/fire_defs';
import { RenderContext } from '../engine/render_context';
import { ModelLayer } from '../engine/model_layer';

const palette = PALETTE.STEP_EDIT

// A mode to provide detailed control of line content.
export class LayerStepEdit extends Layer {
    selection: Selection;
    cursor: LayerLineSelect;
    button_panel: LayerButtonPanel;

    constructor() {
        super(new ModelLayer(), 'Step Edit');

        this.selection = new Selection(new PatternPos(1, 1, 1), new PatternPos(1, 1, 1));
        this.cursor = new LayerLineSelect(0, PALETTE.LINE_SELECT);

        const buttons: ButtonSpec[] = [
            {
                name: "Contract Selection Width",
                color: palette.CONTRACT_SELECTION_WIDTH,
                action: () => {
                    this.selection.contract_width();
                    this.selection.apply();
                }
            },
            {
                name: "Expand Selection Width",
                color: palette.EXPAND_SELECTION_WIDTH,
                action: () => {
                    this.selection.expand_width();
                    this.selection.apply();
                }
            },
            {
                color: palette.BACKGROUND,
            },
            {
                color: palette.BACKGROUND,
            },
            {
                name: "Deselect",
                color: palette.DESELECT,
                action: () => {
                    rns.selection_in_pattern = null;
                },
            },
            {
                name: "Cursor --> Select Start",
                color: palette.SELECT_START,
                action: () => {
                    this.selection.start_pos = PatternPos.current();
                    this.selection.apply();
                },
            },
            {
                name: "Cursor --> Select End",
                color: palette.SELECT_END,
                action: () => {
                    this.selection.end_pos = PatternPos.current();
                    this.selection.apply();
                },
            },
            {
                color: palette.BACKGROUND,
            },
        ];
        this.button_panel = new LayerButtonPanel(new Rect(4, 0, 4, FIRE_GRID_HEIGHT), buttons)

        this.mount([
            this.cursor,
            this.button_panel,
        ]);
    }

    on_idle() {
    }

    render(rc: RenderContext, m: any) {
        rc.clear_grid(null);
    }
}
