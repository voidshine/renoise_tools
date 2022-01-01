import './renoise_common';
// import * as renoise_document from './renoise_document';
// import * as renoise_scripting_tool from './renoise_scripting_tool';
// import * as renoise_application from './renoise_application';
// import * as renoise_song from './renoise_song';
// import * as renoise_midi from './renoise_midi';
// import * as renoise_osc from './renoise_osc';
// import * as renoise_socket from './renoise_socket';
// import * as renoise_view_builder from './renoise_view_builder';

import './renoise_document';
import './renoise_scripting_tool';
import './renoise_application';
import './renoise_song';
import './renoise_midi';
import './renoise_osc';
import './renoise_socket';
import './renoise_view_builder';

// /** @noSelf */
//declare interface Renoise {
    // Application: renoise_application.Application;
    // type ScriptingTool = renoise_scripting_tool.ScriptingTool;
    // type Song = renoise_song.Song;
    // type Track = renoise_song.Track;
    // type PatternTrack = renoise_song.PatternTrack;
    // type PatternSelection = renoise_song.PatternSelection;
    // type Transport = renoise_song.Transport;
    // type Midi = renoise_midi.Midi;
    // type Socket = renoise_socket.Socket;
    // type ViewBuilder = renoise_view_builder.ViewBuilder;

    // const API_VERSION: number;
    // const RENOISE_VERSION: string;

    // function app(): Application;
    // function song(): Song;
    // function tool(): ScriptingTool;

    // namespace Transport {
    //     // Strip the enum type specifier in compiled output.
    //     /** @compileMembersOnly */
    //     enum PLAYMODE {
    //         PLAYMODE_RESTART_PATTERN,
    //         PLAYMODE_CONTINUE_PATTERN,
    //     }
    // }
    
    // namespace Track {
    //     /** @compileMembersOnly */
    //     enum TRACK_TYPE {
    //         TRACK_TYPE_SEQUENCER,
    //         TRACK_TYPE_MASTER,
    //         TRACK_TYPE_SEND,
    //         TRACK_TYPE_GROUP,
    //     }

    //     /** @compileMembersOnly */
    //     enum MUTE_STATE {
    //         MUTE_STATE_ACTIVE,
    //         MUTE_STATE_OFF,
    //         MUTE_STATE_MUTED,
    //     }
    // }

    // namespace Document {
    //     type Observable = renoise_document.Observable;
    // }
    
    // namespace Osc {
    //     type IMessage = renoise_osc.IMessage;
    //     type IBundle = renoise_osc.IBundle;
    //     type TagValue = renoise_osc.TagValue;

    //     // TODO: Merge constructor function and interface?
    //     export function Message(pattern: string, arguments: TagValue[]): IMessage;

    // }

    // namespace Socket {
    //     /** @compileMembersOnly */
    //     enum PROTOCOL {
    //         PROTOCOL_TCP,
    //         PROTOCOL_UDP,
    //     }
    // }
//}

// Don't declare the instance here because it will cause tstl to produce a Lua require, so...
// Somewhere in your project:
//   import type { Renoise } from "path/to/renoise_types"
//   declare const renoise: Renoise;

// export declare const renoise: Renoise;
// declare global {
//     export const renoise: Renoise;
// }

declare global {
    // //export namespace renoise {
    //     type Application = renoise_application.Application;

    //     type ScriptingTool = renoise_scripting_tool.ScriptingTool;

    //     type Song = renoise_song.Song;
    //     type PatternTrack = renoise_song.PatternTrack;
    //     type PatternSelection = renoise_song.PatternSelection;
    //     type Transport = renoise_song.Transport;
    // //}

    /** @noSelf */
    function rprint(what: any): void;
}

declare global {
    // Open up the renoise namespace everywhere.
    export namespace renoise {
        // export type Application = renoise_application.Application;
        // export type ScriptingTool = renoise_scripting_tool.ScriptingTool;
        // export type Song = renoise_song.Song;
        // export type Track = renoise_song.Track;
        // export type PatternTrack = renoise_song.PatternTrack;
        // export type PatternSelection = renoise_song.PatternSelection;
        // export type Transport = renoise_song.Transport;
        // export type Midi = renoise_midi.Midi;
        // export type Socket = renoise_socket.Socket;
        // export type ViewBuilder = renoise_view_builder.ViewBuilder;

        export const API_VERSION: number;
        export const RENOISE_VERSION: string;

        export function app(): Application;
        export function song(): Song;
        export function tool(): ScriptingTool;
    }

    // This is not officially part of the renoise API, but its type and usage is implied in the documentation.
    export type MidiMessage = number[];
}
