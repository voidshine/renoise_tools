import { MIDI_PORT_NONE } from './midi'; // For the special MIDI_PORT_NONE value
import { load_json, save_json, } from './utility';

export interface NoteGridLayout {
    name: string;
    origin_note: number;
    x_pattern: number[];
    y_pattern: number[];
    use_song_root: boolean;
}

export interface FireConfig {
    enabled: boolean;
    midi_input: string;
    midi_output: string;
    mode_bindings: {
        // Keys of FIRE_BUTTON, values of mode name arrays (see MODES) for modes to cycle through on that button.
        Step: string[];
        Note: string[];
        Drum: string[];
        Perform: string[];
    };
};

export interface GeneratedMidiSpec {
    midi_output: string;
    osc_enabled: boolean;
    osc_address: string;
    osc_port: number;
};

export interface ConfigSpec {
    fires: FireConfig[];
    generated_midi: GeneratedMidiSpec;
    note_grid_layouts: NoteGridLayout[];
    default_note_layout: string;
    default_note_layouts_by_layer: {[key: string]: string};
    knob_sensitivity_main: number;
    knob_sensitivity_alt: number;
};

const config_default: ConfigSpec = {
    fires: [
        {
            enabled: true,
            midi_input: "FL STUDIO FIRE",
            midi_output: "FL STUDIO FIRE",
            mode_bindings: {
                Step: [ "Step Edit", ],
                Note: [ "Line & Note", "Note", ],
                Drum: [ "Generate Euclidean" ],
                Perform: [ "Mixer", "Toys", ],
            },
        },
        {
            enabled: false,
            midi_input: "FL STUDIO FIRE #2",
            midi_output: "FL STUDIO FIRE #2",
            mode_bindings: {
                Step: [ "Step Edit", ],
                Note: [ "Line & Note", "Note", ],
                Drum: [ "Generate Euclidean" ],
                Perform: [ "Mixer", "Toys", ],
            },
        },        
    ],
    generated_midi: {
        midi_output: MIDI_PORT_NONE,
        osc_enabled: false,
        osc_address: "127.0.0.1",
        osc_port: 8086,
    },
    note_grid_layouts: [
        {
            name: "Diatonic Major",
            origin_note: 48,
            x_pattern: [0, 2, 4, 5, 7, 9, 11, 12],
            y_pattern: [0, -12],
            use_song_root: true,
        },
        {
            name: "Diatonic Minor",
            origin_note: 48,
            x_pattern: [0, 2, 3, 5, 7, 8, 10, 12],
            y_pattern: [0, -12],
            use_song_root: true,
        },
        {
            name: "Isomorphic (1, -3) ~ Chromatic",
            origin_note: 48,
            // Can't stack octaves because sometimes we only have a rectangle 12-wide to work with,
            // and one column is required for the EMPTY and OFF special notes, leaving only 11.
            // So stack minor thirds, Bayan-style, which is also very convenient musically.
            x_pattern: [0, 1],
            y_pattern: [0, -3],
            use_song_root: true,
        },
        {
            name: "Isomorphic (3, 1) ~ Button Accordion (Bayan)",
            origin_note: 48,
            x_pattern: [0, 3],
            y_pattern: [0, 1],
            use_song_root: true,
        },
        {
            name: "Isomorphic (2, -5) ~ Wicki-Hayden",
            origin_note: 48,
            // This has the property of letting the octaves drift horizontally on the regular grid,
            // but ensures isomorphism is preserved. The benefit to muscle memory is well worth the trade.
            x_pattern: [0, 2],
            y_pattern: [0, -5],
            use_song_root: true,
        },
        {
            name: "Wrap 11 (1, -11) ~ Drums/Chromatic",
            origin_note: 48,
            x_pattern: [0, 1],
            y_pattern: [0, -11],
            use_song_root: false,
        },
        {
            name: "Wrap 15 (1, -15) ~ Drums/Chromatic",
            origin_note: 48,
            x_pattern: [0, 1],
            y_pattern: [0, -15],
            use_song_root: false,
        },
        {
            name: "Diatonic Major, double-octave (..., -24)",
            origin_note: 48,
            x_pattern: [0, 2, 4, 5, 7, 9, 11, 12],
            y_pattern: [0, -24],
            use_song_root: true,
        },
        {
            name: "Diatonic Minor, double-octave (..., -24)",
            origin_note: 48,
            x_pattern: [0, 2, 3, 5, 7, 8, 10, 12],
            y_pattern: [0, -24],
            use_song_root: true,
        },
        {
            name: "Diatonic Major, with enharmonic rows",
            origin_note: 49,
            x_pattern: [0, 2, 4, 5, 7, 9, 11, 12],
            y_pattern: [0, -1, -12],
            use_song_root: true,
        },
        {
            name: "Diatonic Minor, with enharmonic rows",
            origin_note: 49,
            x_pattern: [0, 2, 3, 5, 7, 8, 10, 12],
            y_pattern: [0, -1, -12],
            use_song_root: true,
        },
    ],
    default_note_layout: "Diatonic Major",
    default_note_layouts_by_layer: {},
    knob_sensitivity_main: 0.6,
    knob_sensitivity_alt: 0.1,
};

type OptionsChangeHandler = (options: Options) => void;

export class Options {
    config: ConfigSpec;
    change_handlers: OptionsChangeHandler[];
    options_filename: string;

    constructor(options_filename: string, handler: OptionsChangeHandler) {
        this.config = config_default;
        this.change_handlers = [handler];
        this.options_filename = options_filename
    }

    load_config() {
        if (!io.exists(this.options_filename)) {
            // write out default config
            save_json(this.options_filename, config_default);
        }        
        
        const [config, error] = load_json(this.options_filename);
        if (error) {
            renoise.app().show_warning(`Error while loading configuration JSON: ${error}`);
        } else {
            // TODO: validation
            // rprint({applying = config})
            this.config = config;
            this.on_config_changed();
        }
    }

    save_config() {
        save_json(this.options_filename, this.config);        
    }

    on_config_changed() {
        this.change_handlers.forEach((handler, _) => {
            handler(this);
        });
    }

    get_fire_config(fire_device_index: number): FireConfig {
        //return this.config[this.names[fire_device_index]];
        return this.config.fires[fire_device_index];
    }

    get_note_layout(for_layer_named: string): NoteGridLayout {
        const layout_name = this.config.default_note_layouts_by_layer[for_layer_named] || this.config.default_note_layout;
        return this.config.note_grid_layouts.find(layout => layout.name == layout_name) || this.config.note_grid_layouts[0];
    }

    reset_to_default() {
        this.config = config_default;
        this.save_config();
        this.on_config_changed();
    }

    prompt_configuration() {
        // const vb: renoise.ViewBuilder = renoise.ViewBuilder();
        const vb: any = renoise.ViewBuilder();

        const midi_in_ports = renoise.Midi.available_input_devices();
        const midi_out_ports = renoise.Midi.available_output_devices();
        table.insert(midi_in_ports, 1, MIDI_PORT_NONE);
        table.insert(midi_out_ports, 1, MIDI_PORT_NONE);

        const states: FireConfig[] = [];
        const fire_views: any[] = [];
        this.config.fires.forEach((fire_config, i) => {
            const closure = (i: number) => {
                // const fire_config = this.get_fire_config(i);
                const state = table.rcopy(fire_config);
                table.insert(states, state);
                const column = [
                    vb.column([
                        vb.row([
                            vb.text({
                                width: 75,
                                text: "Enabled",
                            }),
                            vb.checkbox({
                                value: state.enabled,
                                notifier: (new_value: boolean) => {
                                    state.enabled = new_value;
                                },
                            }),
                        ]),

                        vb.row([
                            vb.text({
                                width: 75,
                                text: "MIDI Input"
                            }),
                            vb.popup({
                                width: 250,
                                value: table.find(midi_in_ports, state.midi_input),
                                items: midi_in_ports,
                                notifier: (new_index: LuaIndex) => {
                                    state.midi_input = midi_in_ports[new_index];
                                },
                            }),
                        ]),

                        vb.row([
                            vb.text({
                                width: 75,
                                text: "MIDI Output"
                            }),
                            vb.popup({
                                width: 250,
                                value: table.find(midi_out_ports, state.midi_output),
                                items: midi_out_ports,
                                notifier: (new_index: LuaIndex) => {
                                    state.midi_output = midi_out_ports[new_index];
                                }
                            }),
                        ]),
                    ]),
                ];
                const fire_view = vb.column({
                    uniform: true,
                    margin: renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN,
                    spacing: renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,

                    // TODO: Will this compile to merge array table with key table?
                    ...column,
                });
                return fire_view;
            };
            table.insert(fire_views, closure(i));
        });

        // rprint(this.config.generated_midi);
        const state_generated_midi = table.rcopy(this.config.generated_midi);
        const view = vb.column([
            vb.text({
                text: "Fire Devices:",
                style: "strong",
            }),
            vb.row(fire_views),
            vb.row([
                vb.text({
                    width: 125,
                    text: "Knob sensitivity, main:",
                    style: "strong",
                }),
                vb.slider({
                    width: 200,
                    min: 0.05,
                    max: 2.0,
                    value: this.config.knob_sensitivity_main,
                    notifier: (new_value: number) => {
                        this.config.knob_sensitivity_main = new_value;
                    },
                }),
            ]),
            vb.row([
                vb.text({
                    width: 125,
                    text: "Knob sensitivity, alt:",
                    style: "strong",
                }),
                vb.slider({
                    width: 200,
                    min: 0.05,
                    max: 2.0,
                    value: this.config.knob_sensitivity_alt,
                    notifier: (new_value: number) => {
                        this.config.knob_sensitivity_alt = new_value;
                    },
                }),
            ]),
            vb.row([
                vb.text({
                    width: 75,
                    text: "Default Note Layout",
                    style: "strong",
                }),
                vb.popup({
                    width: 250,
                    // value: table.find(note_layouts, this.config.note_layout),
                    // items: note_layouts,
                    // notifier: (new_index: LuaIndex) => {
                    //     this.config.note_layout = note_layouts[new_index];
                    // },
                    value: table.find(this.config.note_grid_layouts.map(ngl => ngl.name), this.config.default_note_layout),
                    items: this.config.note_grid_layouts.map(ngl => ngl.name),
                    notifier: (new_index: LuaIndex) => {
                        this.config.default_note_layout = this.config.note_grid_layouts[new_index].name;
                    },
                }),
            ]),
            vb.text({
                width: 75,
                text: "Generated MIDI:",
                style: "strong",
            }),
            vb.row([
                vb.column({
                    tooltip: "MIDI note events generated by playing the Fire can be sent to a MIDI device and/or an OSC address. For OSC, it may be useful to target the Renoise internal OSC server configurable in Edit|Preferences|OSC.",
                    // TODO: Does this produce the right merged array/key table in Lua?
                    ...[
                        vb.row([
                            vb.text({
                                width: 125,
                                text: "Send to MIDI Output:",
                            }),
                            vb.popup({
                                width: 200,
                                value: table.find(midi_out_ports, state_generated_midi.midi_output),
                                items: midi_out_ports,
                                notifier: (new_index: LuaIndex) => {
                                    state_generated_midi.midi_output = midi_out_ports[new_index];
                                },
                            }),
                        ]),
                        vb.column([
                            vb.text({
                                width: 100,
                                text: "Send to OSC:",
                            }),
                            vb.row([
                                vb.space({ width: 50 }),
                                vb.text({
                                    width: 75,
                                    text: "Enabled:"
                                }),
                                vb.checkbox({
                                    value: state_generated_midi.osc_enabled,
                                    notifier: (new_value: boolean) => {
                                        state_generated_midi.osc_enabled = new_value;
                                    },
                                }),
                            ]),
                            vb.row([
                                vb.space({ width: 50 }),
                                vb.text({
                                    width: 75,
                                    text: "Address:"
                                }),
                                vb.textfield({
                                    width: 200,
                                    value: state_generated_midi.osc_address,
                                    notifier: (new_value: string) => {
                                        state_generated_midi.osc_address = new_value;
                                    },
                                }),
                            ]),
                            vb.row([
                                vb.space({ width: 50 }),
                                vb.text({
                                    width: 75,
                                    text: "Port:"
                                }),
                                vb.valuebox({
                                    width: 75,
                                    value: state_generated_midi.osc_port,
                                    min: 0,
                                    max: 65535,
                                    notifier: (new_value: number) => {
                                        state_generated_midi.osc_port = new_value;
                                    },
                                }),
                            ]),
                        ]),
                    ]
                }),
            ]),
        ]);

        if (renoise.app().show_custom_prompt("Configure voidshine pyre", view, ["Save", "Cancel"]) == "Save") {
            states.forEach((state, i) => {
                this.config.fires[i] = state;
            });
            this.config.generated_midi = state_generated_midi

            this.save_config();
            this.on_config_changed();
        }
    }

    // Use slow for horizontal movement that doesn't need to be as fast as vertical in general.
    knob_sensitivity(alt: boolean, slow: boolean) {
        return (alt ? this.config.knob_sensitivity_alt : this.config.knob_sensitivity_main) * (slow ? 0.3 : 1.0);
    }
}
