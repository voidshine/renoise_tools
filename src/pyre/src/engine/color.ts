
/** @luaTable */
declare class Table<K extends {} = {}, V = any> {
    readonly length: number;
    set(key: K, value: V | undefined): void;
    get(key: K): V | undefined;
}

// Components in [0, 255]
type Rgb = [number, number, number];

// Components in [0, 1]
type Hsv = [number, number, number];

// TODO: Use class Color { ?
// Color = {}
// Color.__index = Color
// Color.__eq = function(a, b)
//     return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
// }

export class Color {
    // TODO: Will Table extension work, or...
    // [1]: number; etc.

    constructor(rgb: Rgb) {
        this.set(1, rgb[0]);
        this.set(2, rgb[1]);
        this.set(3, rgb[2]);
    }

    [component: number]: number;

    get(component: number): number {
        return this[component];
    }
    set(component: number, value: number) {
        this[component] = value;
    }

    __eq(rhs: Color) {
        return this.get(1) == rhs.get(1) && this.get(2) == rhs.get(2) && this.get(3) == rhs.get(3);
    }

    // rgb is the primary representation because it's faster for Fire; hsv is supported through conversion.
    static rgb(rgb: Rgb) {
        //return setmetatable(rgb, this)
        return new Color(rgb);
    }

    static hsv(hsv: Hsv) {
        return new Color(hsv_to_rgb(hsv))
    }

    static black() {
        return new Color([0, 0, 0])
    }

    static white() {
        return new Color([255, 255, 255])
    }

    // shade in range [0, 255], black to white.
    static gray(shade: number) {
        return new Color([shade, shade, shade])
    }

    set_from(rhs: Color) {
        this.set(1, rhs.get(1));
        this.set(2, rhs.get(2));
        this.set(3, rhs.get(3));
    }

    to_hsv(): Hsv {
        // TODO: Optimize
        // return rgb_to_hsv(this)
        return rgb_to_hsv([this.get(1)!, this.get(2)!, this.get(3)!]);
    }

    // Returns a number unique to this complete color value. This can be used as a table key where Color instances
    // would not be acceptable due to Lua table lookup restrictions. (__eq does not seem to be used, only object identity (reference) value).
    to_int(): number {
        return this.get(1)! * 65536 + this.get(2)! * 256 + this.get(3)!;
    }

    with_hsv_value(value: number) {
        const hsv = this.to_hsv();
        hsv[2] = value;
        return Color.hsv(hsv);
    }
}

////////////////////////////////////////////////////////////////////////////////
// Converts an RGB color value to HSV. Conversion formula
// adapted from http://en.wikipedia.org/wiki/HSV_color_space.
// @param rgb (table), the RGB representation
// @return table, the HSV representation
export function rgb_to_hsv(rgb: Rgb): Hsv {
    // const r, g, b = rgb[1] / 255, rgb[2] / 255, rgb[3] / 255
    // const max, min = math.max(r, g, b), math.min(r, g, b)

    const r = rgb[0] / 255;
    const g = rgb[1] / 255;
    const b = rgb[2] / 255;
    const max = math.max(r, g, b);
    const min = math.min(r, g, b);

    let h: number, s, v;
    v = max;

    const d = max - min;
    if (max == 0) {
        s = 0;
    } else {
        s = d / max;
    }

    if (max == min) {
        h = 0; // achromatic
    } else {
        if (max == r) {
            h = (g - b) / d;
            if (g < b) {
                h = h + 6;
            }
        } else if (max == g) {
            h = (b - r) / d + 2;
        // } else if (max == b) {
        } else {    // max == b
            h = (r - g) / d + 4;
        }
        h = h / 6;
    }

    return [ h, s, v ];
}

////////////////////////////////////////////////////////////////////////////////
// Converts an HSV color value to RGB. Conversion formula
// adapted from http://en.wikipedia.org/wiki/HSV_color_space.
// @param hsv (table), the HSV representation
// @return table, the RGB representation
export function hsv_to_rgb(hsv: Hsv): Rgb {

    let [h, s, v] = [hsv[0], hsv[1], hsv[2]];
    // let r = 0, g = 0, b = 0

    //const i = math.floor(h * 6);
    const i = math.floor(h * 6) % 6;
    const f = h * 6 - i;
    const p = v * (1 - s);
    const q = v * (1 - f * s);
    const t = v * (1 - (1 - f) * s);

    // switch (i) {
    //     case 0: [r, g, b] = [v, t, p]; break;
    //     case 1: [r, g, b] = [q, v, p]; break;
    //     case 2: [r, g, b] = [p, v, t]; break;
    //     case 3: [r, g, b] = [p, q, v]; break;
    //     case 4: [r, g, b] = [t, p, v]; break;
    //     case 5: [r, g, b] = [v, p, q]; break;
    // }
    // return [r, g, b];
    
    // if (i == 0) { return [v, t, p]; }
    // if (i == 1) { return [q, v, p]; }
    // if (i == 2) { return [p, v, t]; }
    // if (i == 3) { return [p, q, v]; }
    // if (i == 4) { return [t, p, v]; }
    // //if (i == 5) { return [v, p, q]; }
    // return [v, p, q];

    let [r, g, b] = 
        i == 0 ? [v, t, p] :
        i == 1 ? [q, v, p] :
        i == 2 ? [p, v, t] :
        i == 3 ? [p, q, v] :
        i == 4 ? [t, p, v] :
        [v, p, q];
    return [math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)];
}
