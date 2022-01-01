// Fire LED state control logic.
// TODO: Move dirty trackout out of class; state should be pure.

import { MonoBitmap } from './mono_bitmap';
import { Rect, modulo_down, modulo_up } from './utility';

export const FIRE_LED_WIDTH = 128;
export const FIRE_LED_HEIGHT = 64;
export const FIRE_LED_RECT_FULL: Readonly<Rect> = new Rect(0, 0, FIRE_LED_WIDTH, FIRE_LED_HEIGHT);

const RECT_CLEAR = new Rect(0, 0, 0, 0);

// Class to handle bit packing for MIDI transmission.  Here's an example for how
// the buffer is calculated, using full LED size...
// (128 * 64 pixels) * (1 byte / 8 pixels) = 1024 bytes to hold all pixel data, efficiently packed.
// But each byte is really only good for 7 because the high bit is reserved (MIDI protocol) so it's really:
// 128 * 64 / 7 = 1,170.285714285714 ~= 1171 to hold all pixel data, expanded.
class LedSegmentBitmap {
    rect: Rect;
    bits_size: number;
    bits: number[];

    constructor(source_rect: Rect) {
        // Snap vertical bounds to include full segments (of 8 pixels each)
        const top = modulo_down(source_rect.top, 8)
        const bottom = modulo_up(source_rect.bottom(), 8)
        assert((bottom - top) % 8 == 0)
        this.rect = new Rect(source_rect.left, top, source_rect.width, bottom - top);
        assert(this.rect.height >= 8, "sending update for empty source_rect will not change device state")

        // Only 7 bits per element here, for MIDI protocol.
        this.bits_size = modulo_up(this.rect.area(), 7) / 7
        this.bits = [];
        // for i = 1, this.bits_size do
        for (let i = 0; i < this.bits_size; i++) {
            this.bits[i] = 0;
        }
    }

    // color_bit 0 or 1
    // pos is relative to this.rect
    set_pixel(x: number, y: number, color_bit: number) {
        assert(color_bit == 0 || color_bit == 1);
        assert(this.rect.size().contains_xy(x, y));

        // 128 * 8 = 1024 bits per row
        // //////////////////////-
        // 0  1  2 ...  99 ... 128 (pixel x)
        // //////////////////////-
        // 7 15 23 ... 799 ... 1023
        // 6 14 22 ... 798 ... 1022
        // 5 13 21 ... 797 ... 1021
        // 4 12 20 ... 796 ... 1020
        // 3 11 19 ... 795 ... 1019
        // 2 10 18 ... 794 ... 1018
        // 1  9 17 ... 793 ... 1017
        // 0  8 16 ... 792 ... 1016

        // Note, the roundoff is important here; segment indicates which of the rows of 8 pixels to address.
        // In the full 64-pixel vertical range, there are 8 segments total.
        const segment = modulo_down(y, 8) / 8
        const bit_index = (this.rect.width * 8 * segment) + (x * 8 + (7 - (y % 8)))

        // Each data bytes holds only 7 bits; calculate byte index and shift
        //    0    1    2    3    4    5    6
        //    7    8    9   10   11   12   13
        //   14   15   16   17   18   19   20
        //  ...  ...  ...  ...  ...  ...  ...
        //  791  792  793  794  795  796  797
        //  798  799  800  801  802  803  804
        //  ...  ...  ...  ...  ...  ...  ...
        // 1022 1023
        //const byte_index = 1 + (modulo_down(bit_index, 7) / 7)
        const byte_index = (modulo_down(bit_index, 7) / 7);
        const shift = 6 - (bit_index % 7);

        // Set or clear the targeted bit.
        const mask = bit.lshift(1, shift)
        if (color_bit == 1) {
            this.bits[byte_index] = bit.bor(this.bits[byte_index], mask)
        } else {
            this.bits[byte_index] = bit.band(this.bits[byte_index], bit.bnot(mask))
        }
    }
    
    // Fill bits from selected rectangle within provided bitmap.
    // bitmap is a MonoBitmap instance.
    fill_from(bitmap: MonoBitmap) {
        // TODO: Can optimize here; no need to mask in set_pixel, for example, just build whole bytes.
        const top_left = this.rect.pos();
        // for pos in this.rect.size():iter_range() do
        for (const pos of this.rect.size().iter_range()) {
            // this.set_pixel(pos, bitmap.get(pos + top_left));
            //this.set_pixel(pos, bitmap.get(pos.__add(top_left)));
            this.set_pixel(pos.x, pos.y, bitmap.get(pos.x + top_left.x, pos.y + top_left.y));
        }
    }

    build_sysex() {
        // val data = mutableListOf(SYSEX_BEGIN, SYSEX_AKAI, SYSEX_ALL_CALL, SYSEX_FIRE, SYSEX_FIRE_WRITE_OLED)
        const data = [ 240, 71, 127, 67, 14, ];
        const add = function(e: number) {
            // table.insert(data, e)
            data.push(e);
        }

        // The payload includes both the range spec (4 bytes) plus all the pixel data in bitmap
        const length = this.bits_size + 4;

        add(bit.band(bit.rshift(length, 7), 0x7f));
        add(bit.band(length, 0x7f));

        // Range spec:
        // Start 8-pixel vertical segment
        // Note: taking advantage of guarantee that rect vertical bounds are guaranteed on boundaries (no float issues)
        add(this.rect.top / 8);
        // End 8-pixel vertical segment (inclusive)
        add(this.rect.bottom() / 8 - 1);

        // Start column of update
        add(this.rect.left);
        // End column of update (inclusive)
        add(this.rect.right() - 1);

        // TODO: Faster way to copy?
        this.bits.forEach((b, _) => {
            add(b)
        });

        add(247);
        return data
    }
}

export class FireLedState {
    bitmap: MonoBitmap;
    dirty_bounds: Rect;

    constructor(copy_from: FireLedState | null) {
        if (copy_from) {
            this.bitmap = copy_from.bitmap.clone()
            this.dirty_bounds = copy_from.dirty_bounds.clone()
        } else {
            this.bitmap = new MonoBitmap(FIRE_LED_WIDTH, FIRE_LED_HEIGHT);
            this.dirty_bounds = FIRE_LED_RECT_FULL.clone()
        }
    }

    clone() {
        return new FireLedState(this);
    }

    clear() {
        this.dirty_rect(FIRE_LED_RECT_FULL)
        this.bitmap.fill(0)
    }

    set_pixel(x: number, y: number, color_bit: number) {
        if (this.bitmap.set(x, y, color_bit)) {
            this.dirty_xy(x, y);
        }
    }

    dirty_xy(x: number, y: number) {
        this.dirty_bounds.include_xy(x, y);
    }

    dirty_rect(rect: Rect) {
        this.dirty_xy(rect.left, rect.top);
        this.dirty_xy(rect.right() - 1, rect.bottom() - 1);
    }

    get_sysex() {
        if (this.dirty_bounds.area() == 0) {
            return null
        } else {
            const segment_bitmap = new LedSegmentBitmap(this.dirty_bounds);
            segment_bitmap.fill_from(this.bitmap)
            this.dirty_bounds.set(RECT_CLEAR)
            return segment_bitmap.build_sysex()
        }
    }
}
