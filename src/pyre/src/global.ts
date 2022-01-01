// import type { Renoise } from "../../renoise_types"
// import { Song } from "../../renoise_types/renoise_song";
// export declare const renoise: Renoise;

// The current renoise.song() instance // a seemingly standard name used directly by other libraries.
// Note, song does not exist when tool is first loaded (Renoise startup).
declare let rns: renoise.Song;

// TODO: Fix this hack.
rns = null as unknown as renoise.Song;
