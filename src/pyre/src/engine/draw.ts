import { Rect } from "./utility";

const DRAW_CLEAR = 1;
const DRAW_BOX = 2;
const DRAW_TEXT = 3;

export class DrawCommand {
    kind: number;
    constructor(kind: number) {
        this.kind = kind;
    }
}

export class DrawClear extends DrawCommand {
    constructor() {
        super(DRAW_CLEAR);
    }
    static INSTANCE = new DrawClear();
}

export class DrawBox extends DrawCommand {
    rect: Rect;
    color: number;
    // 0 = off, 1 = on
    constructor(rect: Rect, color: number) {
        super(DRAW_BOX);
        this.rect = rect;
        this.color = color;
    }
}

export class DrawText extends DrawCommand {
    font: number;
    rect: Rect;
    text: string;
    constructor(font: number, rect: Rect, text: string) {
        super(DRAW_TEXT);
        this.font = font;
        this.rect = rect;
        this.text = text;
    }
}
