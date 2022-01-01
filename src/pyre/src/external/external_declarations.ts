/** @forRange */
declare function forRange(start: number, limit: number, step?: number): number[];

// Arrays present indexing off-by-one issues in the conversion between TypeScript and Lua.
// When direct (non-shifted) index access is wanted, use this instead.
// Extending Iterable<T> allows the type to be used in for...of loops.
// When initializing a value of this type, use [] not {}. This keeps TypeScript
// happy and compiles to the same Lua code.
interface DirectIndex<T> extends Iterable<T> { [key: number]: T; };

// For simplicity, bring all external dependencies into
// global scope once at startup. They're treated as part
// of the execution environment. Use Lua conventions here.
require('external/cLib');
require('external/xLib');
require('external/lunajson');

declare namespace lunajson {
    function decode(json: string): any;
    function encode(model: any): string;
}

declare namespace table {
    function copy<T>(t: T): T;
    function rcopy<T>(t: T): T;
    function find(t: any, value: any): any;
    function insert<T>(t: T[], value: T): void;
    function insert<T>(t: T[], position: number, value: T): void;
}

declare namespace io {
    function exists(filename: string): boolean;
}

declare function oprint(message: string): void;

declare class MidiDevice {}

declare namespace cLib {
    function clamp_value(value: number, min: number, max: number): number;
    function round_value(value: number): number;
}

// declare namespace xLib {
    declare namespace xColumns {
        function previous_column(): void;
        function next_column(): void;
        function previous_note_column(wrap_pattern: boolean, wrap_track: boolean, track_index?: LuaIndex): void;
        function next_note_column(wrap_pattern: boolean, wrap_track: boolean, track_index?: LuaIndex): void;
    }
    declare namespace xTrack {
        // Note, these declarations seem to match the implementation, not the comments.
        function get_next_track(track_idx?: LuaIndex, wrap_pattern?: boolean): LuaIndex;
        function get_previous_track(track_idx?: LuaIndex, wrap_pattern?: boolean): LuaIndex;
        function get_next_sequencer_track(track_idx?: LuaIndex, wrap_pattern?: boolean): LuaIndex;
        function get_previous_sequencer_track(track_idx?: LuaIndex, wrap_pattern?: boolean): LuaIndex;

        function jump_to_next_track(track_idx?: LuaIndex, wrap_pattern?: boolean): void;
        function jump_to_previous_track(track_idx?: LuaIndex, wrap_pattern?: boolean): void;
        function jump_to_next_sequencer_track(track_idx?: LuaIndex, wrap_pattern?: boolean): void;
        function jump_to_previous_sequencer_track(track_idx?: LuaIndex, wrap_pattern?: boolean): void;
    }
// }
