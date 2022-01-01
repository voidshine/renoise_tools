import { modulo_up } from './utility';

// Theoretically we should have at least 52 bits for an integer in the 64-bit floating point
// representation but experimentation reveals that using any more than 32 bits causes
// strange artifacts. TODO: investigate the underlying cause and fix for a performance boost.
const BITS_PER_ELEMENT = 32;

function isBitmap(maybe: number | MonoBitmap): maybe is MonoBitmap {
    // return !!(maybe as MonoBitmap).bits;
    return typeof(maybe) != "number";
}

// Bit vector bitmap encoding many bits into each number.
// Note, everything is zero-based, not Lua one-based.
export class MonoBitmap {
    width: number;
    height: number;
    bits: number[];
    
    // Provide a (width, height) size or else another MonoBitmap instance to copy from.
    constructor(width_or_copy_from: number | MonoBitmap, height?: number) {
        if (isBitmap(width_or_copy_from)) {
            this.width = width_or_copy_from.width;
            this.height = width_or_copy_from.height;
            this.bits = table.copy(width_or_copy_from.bits);
        } else {
            this.width = width_or_copy_from;
            this.height = height!;
            this.bits = [];
            this.fill(0);
        }
    }

    __eq(rhs: MonoBitmap) {
        // TODO
    }

    clone() {
        return new MonoBitmap(this);
    }

    /** @tupleReturn */
    index_shift_at(x: number, y: number) {
        const bit_index = y * this.width + x;
        const shift = bit_index % BITS_PER_ELEMENT;
        const element_index = (bit_index - shift) / BITS_PER_ELEMENT;
        assert(element_index * BITS_PER_ELEMENT + shift == bit_index, "numerical precision issues");
        // Watch out: Lua!
        //return [1 + element_index, shift];
        return [element_index, shift];
    }

    // color_bit is 0 or 1, not boolean
    fill(color_bit: number) {
        assert(color_bit == 0 || color_bit == 1, "color_bit must be 0 or 1");
        const value = color_bit == 0 ? 0 : bit.bnot(0);
        // for i = 1, math.ceil(this.width * this.height / BITS_PER_ELEMENT) do
        //for i = 1, modulo_up(this.size.area(), BITS_PER_ELEMENT) / BITS_PER_ELEMENT {
        //for (const i of forRange(1, modulo_up(this.size.area(), BITS_PER_ELEMENT) / BITS_PER_ELEMENT)) {
        for (let i = 0; i < modulo_up(this.width * this.height, BITS_PER_ELEMENT) / BITS_PER_ELEMENT; i++) {
            this.bits[i] = value;
        }
    }

    // Returns color_bit 0 or 1
    get(x: number, y: number) {
        const [index, shift] = this.index_shift_at(x, y);
        return bit.band(bit.rshift(this.bits[index], shift), 1);
    }

    // color_bit is 0 or 1, not boolean
    // returns true if changed
    set(x: number, y: number, color_bit: number) {
        assert(color_bit == 0 || color_bit == 1, "color_bit must be 0 or 1");
        const [index, shift] = this.index_shift_at(x, y);
        const mask = bit.lshift(1, shift);
        const was = this.bits[index];
        if (color_bit == 0) {
            this.bits[index] = bit.band(was, bit.bnot(mask));
        } else {
            this.bits[index] = bit.bor(was, mask);
        }
        return this.bits[index] != was;
    }
}
