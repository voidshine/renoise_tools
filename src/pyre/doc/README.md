# Akai Fire Renoise Controller
Akai Fire provides hands-on control of Renoise.

## Bugs:
* Start up with no devices connected; then connect one. root_layer is null in midi connection change handler.

* In compilation process / plugin, this works:
            const column = lines[start_line + i].note_column(0);
            column.note_value = value;
    But not this:
            lines[start_line + i].note_column(0).note_value = value;
    Should work!

## TODO:

* Clean up model dirty handling; render is fast; model updates might need to be split across frames, etc.
* Implement LED dirty region handling ... maybe better to use quad tree on actual pixel data, instead of blind dirty rects.

* Better note grid layout persistence. Right now the root/origin note is cloned and modified per track, which may be confusing if the user later changes song root note.

* Once lots of modes are built, support on-the-fly swapping out of modules, driven by the LED display with registered mode layers, and backed by options document. Or...could just support configuration by ordinary Renoise interface using drop-downs. But dynamic seems more powerful! Maybe it's stored per-song, but the global options can configure a default.
* Support multiple Fire devices
* Provide multiple pass-through modes allowing user to create and switch between multiple mapping sets in Renoise (can this be done simply by changing the channel for events coming through?)

* Configure an "Output MIDI Device" to send MIDI note events to directly instead of over OSC.
* Background recording with intelligent memory of where things should go if user chooses to "capture" (by remembering where play starts, pattern, etc.). Can capture to phrases.
* Cut/paste
* In layer_transport, support waiting for first note played to kick off recording.
* Support querying for current modeled state of all keys and pads: FireState:is_button_down and make state accessible to layers?
* Give layers a parent property and ensure mounting always tracks and notifies for every layer.
* Probably most efficient to give each mode its own mode selector for sub-modes and then support popping back out? Too easy to get lost?

* Special key prefix/mode lets user touch buttons to see what they do without actually doing it? Or just do it, with message, and then can undo.
* Various paste modes:
    * Paste at cursor: replace, insert, merge
    * Paste into selection: fit, spread, conform to chord/pitch-classes
* Transpose selection
* Alt key can change the whole pad grid interface; e.g. line select can change color to let user select Edit Step instead of addressing lines.
* Automation/FX modes
* Envelope editor
* Reserve Select knob for changing something selected elsewhere in the interface; e.g. while holding some pads down, select can drive parameters related to those functions.

## Design Principles
* Direct access is better than incremental cursor movement.
* Provided a set of button elements are close to each other, sequences can be learned and repeated very quickly.
* Consistency of color and location is important to muscle memory.

## Development Caveats

### Native/Lua
The native module static links an implementation of Lua that is (hopefully) quite close to the one linked into Renoise: Lua v5.1.5, with minor hacks to avoid disaster.

Strict summary: *No Lua allocations allowed!* -- (or maybe just *table* allocations? strings, closures, and userdata seem fine?)
Renoise must fully manage memory, including garbage collection, string creation, table sizing/resizing, etc.
Garbage collection is disabled deep in the Lua 5.1.5 code, and realloc calls are logged as errors to stderr to aid debugging.

More loosely...the second Lua brain must carefully follow some rules:
* Don't let garbage collection happen; Renoise must do it. This is achieved with modification to the Lua source code.
* Don't reallocate memory with Lua; only trust the Renoise allocator for Lua memory. The Lua state object passed into luaopen_* functions from Renoise has a working frealloc function,
  and that should be used exclusively. mlua does this.
* The native module may manage its own memory allocations, but beware of ownership and lifetimes.
  In particular, with mlua, a LuaTable struct holds a LuaRef that will drop_ref (replace with nil) on drop, allowing garbage collection of the value.
  "The implementation is somewhat biased towards the use case of a relatively small number of short term references being created, and `RegistryKey` being used for long term references."
  So use `create_registry_value` or, at least, store a *clone* of the table (this clones the LuaRef only) somewhere persistent like the main Lua state globals -- before returning it from the native module. This may keep the value from getting garbage collected and things will work until the end when everything is finally cleaned up. Then we discover that use of large tables somehow
  corrupts the heap... probably, mlua's implementation is really biased toward Rust being the host with everything managed neatly by Rust -- and so all the automatic cleanup results in
  use-after-frees or double-frees when Lua collects. So...don't use LuaTables! It's just as well to maintain UserData that gets looked up for copy from Renoise-run Lua code.

If these rules are broken, we get heap corruption and crashes. If these rules are followed, native interop (apparently) works perfectly with no leaks or ill effect.

Seemingly, mlua's UserData mechanism is working well with Renoise Lua garbage collection. The data doesn't get dropped until Lua needs to collect it.
And a way to use tables: pre-allocate the full table in Lua first, then pass it to the native module as a parameter to be filled with output.

### TypeScript/Lua

The TypeScript to Lua Compiler (tstl) adjusts index values automatically so that zero-based
indices in TypeScript correspond to one-based indices in Lua. It works well, but with one
big catch: the compiler must know the types of the array and the index. If the array type is
anything *other* than an array, shift won't happen. If the index is anything other than number,
also shift won't happen. Here is a cautionary example:
```
const track_index = i + m.offset;       // track_index type is any because m is any.
const track = rns.tracks[track_index];  // shift won't happen!
```

```
const track_index: number = i + m.offset;   // track_index type is number.
const track = rns.tracks[track_index];      // shift will happen!
```

A specially developed TypeScript AST transformer was developed to alleviate the burden of
manually shifting index values coming from the Renoise API. Index values coming in through
the API that are known to be one-based are marked as type `LuaIndex` instead of `number`.
This is mostly dealt with in the type declarations, but there are cases where the programmer
provides the type for a value coming from the Lua API. In such a case, LuaIndex must be
used or else the value should be shifted manually. Example:
```
    vb.popup({
        width: 200,
        value: table.find(midi_out_ports, state_generated_midi.midi_output),
        items: midi_out_ports,
        // If `(new_index: number)` were here instead, no shift gets applied.
        notifier: (new_index: LuaIndex) => {
            state_generated_midi.midi_output = midi_out_ports[new_index];
        },
    }),
```

If Renoise seems not to detect or load the tool, it may be because of the early source maps failure.
Simply compiling isn't enough; hacking the source maps to work around a bug is also needed.

Lua bundling does not work. Both the tstl bundling feature, and luabundle fail to produce usable bundles
because they put things within functions without declaring them at root scope. This causes
undeclared variable errors when Renoise loads the bundle.

### Inheritance
Metamethods are not inherited from base classes. Implement and delegate manually to super where appropriate.
