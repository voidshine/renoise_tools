import { Knob } from "./knob";
import { Layer } from "./layer";

export class MenuItem {
    text: string;
    index: number = 0;
    items: MenuItem[];

    /** @noSelf */
    on_select: () => void;

    constructor(text: string, items?: MenuItem[], on_select?: () => void) {
        this.text = text;
        this.items = items || [];
        this.on_select = on_select || (() => {});
    }

    set_indices() {
        this.items.forEach((item, i) => {
            item.index = i;
            item.set_indices();
        });
    }
}
