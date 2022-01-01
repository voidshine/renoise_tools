--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____midi = require("engine.midi")
local MIDI_PORT_NONE = ____midi.MIDI_PORT_NONE
local ____utility = require("engine.utility")
local load_json = ____utility.load_json
local save_json = ____utility.save_json
local config_default = {fires = {{enabled = true, midi_input = "FL STUDIO FIRE", midi_output = "FL STUDIO FIRE", mode_bindings = {Step = {"Step Edit"}, Note = {"Line & Note", "Note"}, Drum = {"Generate Euclidean"}, Perform = {"Mixer", "Toys"}}}, {enabled = false, midi_input = "FL STUDIO FIRE #2", midi_output = "FL STUDIO FIRE #2", mode_bindings = {Step = {"Step Edit"}, Note = {"Line & Note", "Note"}, Drum = {"Generate Euclidean"}, Perform = {"Mixer", "Toys"}}}}, generated_midi = {midi_output = MIDI_PORT_NONE, osc_enabled = false, osc_address = "127.0.0.1", osc_port = 8086}, note_grid_layouts = {{name = "Diatonic Major", origin_note = 48, x_pattern = {0, 2, 4, 5, 7, 9, 11, 12}, y_pattern = {0, -12}, use_song_root = true}, {name = "Diatonic Minor", origin_note = 48, x_pattern = {0, 2, 3, 5, 7, 8, 10, 12}, y_pattern = {0, -12}, use_song_root = true}, {name = "Isomorphic (1, -3) ~ Chromatic", origin_note = 48, x_pattern = {0, 1}, y_pattern = {0, -3}, use_song_root = true}, {name = "Isomorphic (3, 1) ~ Button Accordion (Bayan)", origin_note = 48, x_pattern = {0, 3}, y_pattern = {0, 1}, use_song_root = true}, {name = "Isomorphic (2, -5) ~ Wicki-Hayden", origin_note = 48, x_pattern = {0, 2}, y_pattern = {0, -5}, use_song_root = true}, {name = "Wrap 11 (1, -11) ~ Drums/Chromatic", origin_note = 48, x_pattern = {0, 1}, y_pattern = {0, -11}, use_song_root = false}, {name = "Wrap 15 (1, -15) ~ Drums/Chromatic", origin_note = 48, x_pattern = {0, 1}, y_pattern = {0, -15}, use_song_root = false}, {name = "Diatonic Major, double-octave (..., -24)", origin_note = 48, x_pattern = {0, 2, 4, 5, 7, 9, 11, 12}, y_pattern = {0, -24}, use_song_root = true}, {name = "Diatonic Minor, double-octave (..., -24)", origin_note = 48, x_pattern = {0, 2, 3, 5, 7, 8, 10, 12}, y_pattern = {0, -24}, use_song_root = true}, {name = "Diatonic Major, with enharmonic rows", origin_note = 49, x_pattern = {0, 2, 4, 5, 7, 9, 11, 12}, y_pattern = {0, -1, -12}, use_song_root = true}, {name = "Diatonic Minor, with enharmonic rows", origin_note = 49, x_pattern = {0, 2, 3, 5, 7, 8, 10, 12}, y_pattern = {0, -1, -12}, use_song_root = true}}, default_note_layout = "Diatonic Major", default_note_layouts_by_layer = {}, knob_sensitivity_main = 0.6, knob_sensitivity_alt = 0.1}
____exports.Options = __TS__Class()
local Options = ____exports.Options
Options.name = "Options"
function Options.prototype.____constructor(self, options_filename, handler)
    self.config = config_default
    self.change_handlers = {handler}
    self.options_filename = options_filename
end
function Options.prototype.load_config(self)
    if not io.exists(self.options_filename) then
        save_json(self.options_filename, config_default)
    end
    local config, ____error = load_json(self.options_filename)
    if ____error then
        renoise.app():show_warning(
            "Error while loading configuration JSON: " .. tostring(____error)
        )
    else
        self.config = config
        self:on_config_changed()
    end
end
function Options.prototype.save_config(self)
    save_json(self.options_filename, self.config)
end
function Options.prototype.on_config_changed(self)
    __TS__ArrayForEach(
        self.change_handlers,
        function(____, handler, _)
            handler(self)
        end
    )
end
function Options.prototype.get_fire_config(self, fire_device_index)
    return self.config.fires[fire_device_index + 1]
end
function Options.prototype.get_note_layout(self, for_layer_named)
    local layout_name = self.config.default_note_layouts_by_layer[for_layer_named] or self.config.default_note_layout
    return __TS__ArrayFind(
        self.config.note_grid_layouts,
        function(____, layout) return layout.name == layout_name end
    ) or self.config.note_grid_layouts[1]
end
function Options.prototype.reset_to_default(self)
    self.config = config_default
    self:save_config()
    self:on_config_changed()
end
function Options.prototype.prompt_configuration(self)
    local vb = renoise.ViewBuilder()
    local midi_in_ports = renoise.Midi.available_input_devices()
    local midi_out_ports = renoise.Midi.available_output_devices()
    table.insert(midi_in_ports, 1, MIDI_PORT_NONE)
    table.insert(midi_out_ports, 1, MIDI_PORT_NONE)
    local states = {}
    local fire_views = {}
    __TS__ArrayForEach(
        self.config.fires,
        function(____, fire_config, i)
            local closure
            closure = function(i)
                local state = table.rcopy(fire_config)
                table.insert(states, state)
                local column = {
                    vb:column(
                        {
                            vb:row(
                                {
                                    vb:text({width = 75, text = "Enabled"}),
                                    vb:checkbox(
                                        {
                                            value = state.enabled,
                                            notifier = function(new_value)
                                                state.enabled = new_value
                                            end
                                        }
                                    )
                                }
                            ),
                            vb:row(
                                {
                                    vb:text({width = 75, text = "MIDI Input"}),
                                    vb:popup(
                                        {
                                            width = 250,
                                            value = table.find(midi_in_ports, state.midi_input),
                                            items = midi_in_ports,
                                            notifier = function(new_index)
                                                new_index = new_index - 1
                                                state.midi_input = midi_in_ports[new_index + 1]
                                            end
                                        }
                                    )
                                }
                            ),
                            vb:row(
                                {
                                    vb:text({width = 75, text = "MIDI Output"}),
                                    vb:popup(
                                        {
                                            width = 250,
                                            value = table.find(midi_out_ports, state.midi_output),
                                            items = midi_out_ports,
                                            notifier = function(new_index)
                                                new_index = new_index - 1
                                                state.midi_output = midi_out_ports[new_index + 1]
                                            end
                                        }
                                    )
                                }
                            )
                        }
                    )
                }
                local fire_view = vb:column(
                    __TS__ObjectAssign(
                        {uniform = true, margin = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN, spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING},
                        __TS__ArrayToObject(column)
                    )
                )
                return fire_view
            end
            table.insert(
                fire_views,
                closure(i)
            )
        end
    )
    local state_generated_midi = table.rcopy(self.config.generated_midi)
    local view = vb:column(
        {
            vb:text({text = "Fire Devices:", style = "strong"}),
            vb:row(fire_views),
            vb:row(
                {
                    vb:text({width = 125, text = "Knob sensitivity, main:", style = "strong"}),
                    vb:slider(
                        {
                            width = 200,
                            min = 0.05,
                            max = 2,
                            value = self.config.knob_sensitivity_main,
                            notifier = function(new_value)
                                self.config.knob_sensitivity_main = new_value
                            end
                        }
                    )
                }
            ),
            vb:row(
                {
                    vb:text({width = 125, text = "Knob sensitivity, alt:", style = "strong"}),
                    vb:slider(
                        {
                            width = 200,
                            min = 0.05,
                            max = 2,
                            value = self.config.knob_sensitivity_alt,
                            notifier = function(new_value)
                                self.config.knob_sensitivity_alt = new_value
                            end
                        }
                    )
                }
            ),
            vb:row(
                {
                    vb:text({width = 75, text = "Default Note Layout", style = "strong"}),
                    vb:popup(
                        {
                            width = 250,
                            value = table.find(
                                __TS__ArrayMap(
                                    self.config.note_grid_layouts,
                                    function(____, ngl) return ngl.name end
                                ),
                                self.config.default_note_layout
                            ),
                            items = __TS__ArrayMap(
                                self.config.note_grid_layouts,
                                function(____, ngl) return ngl.name end
                            ),
                            notifier = function(new_index)
                                new_index = new_index - 1
                                self.config.default_note_layout = self.config.note_grid_layouts[new_index + 1].name
                            end
                        }
                    )
                }
            ),
            vb:text({width = 75, text = "Generated MIDI:", style = "strong"}),
            vb:row(
                {
                    vb:column(
                        __TS__ObjectAssign(
                            {tooltip = "MIDI note events generated by playing the Fire can be sent to a MIDI device and/or an OSC address. For OSC, it may be useful to target the Renoise internal OSC server configurable in Edit|Preferences|OSC."},
                            __TS__ArrayToObject(
                                {
                                    vb:row(
                                        {
                                            vb:text({width = 125, text = "Send to MIDI Output:"}),
                                            vb:popup(
                                                {
                                                    width = 200,
                                                    value = table.find(midi_out_ports, state_generated_midi.midi_output),
                                                    items = midi_out_ports,
                                                    notifier = function(new_index)
                                                        new_index = new_index - 1
                                                        state_generated_midi.midi_output = midi_out_ports[new_index + 1]
                                                    end
                                                }
                                            )
                                        }
                                    ),
                                    vb:column(
                                        {
                                            vb:text({width = 100, text = "Send to OSC:"}),
                                            vb:row(
                                                {
                                                    vb:space({width = 50}),
                                                    vb:text({width = 75, text = "Enabled:"}),
                                                    vb:checkbox(
                                                        {
                                                            value = state_generated_midi.osc_enabled,
                                                            notifier = function(new_value)
                                                                state_generated_midi.osc_enabled = new_value
                                                            end
                                                        }
                                                    )
                                                }
                                            ),
                                            vb:row(
                                                {
                                                    vb:space({width = 50}),
                                                    vb:text({width = 75, text = "Address:"}),
                                                    vb:textfield(
                                                        {
                                                            width = 200,
                                                            value = state_generated_midi.osc_address,
                                                            notifier = function(new_value)
                                                                state_generated_midi.osc_address = new_value
                                                            end
                                                        }
                                                    )
                                                }
                                            ),
                                            vb:row(
                                                {
                                                    vb:space({width = 50}),
                                                    vb:text({width = 75, text = "Port:"}),
                                                    vb:valuebox(
                                                        {
                                                            width = 75,
                                                            value = state_generated_midi.osc_port,
                                                            min = 0,
                                                            max = 65535,
                                                            notifier = function(new_value)
                                                                state_generated_midi.osc_port = new_value
                                                            end
                                                        }
                                                    )
                                                }
                                            )
                                        }
                                    )
                                }
                            )
                        )
                    )
                }
            )
        }
    )
    if renoise.app():show_custom_prompt("Configure voidshine pyre", view, {"Save", "Cancel"}) == "Save" then
        __TS__ArrayForEach(
            states,
            function(____, state, i)
                self.config.fires[i + 1] = state
            end
        )
        self.config.generated_midi = state_generated_midi
        self:save_config()
        self:on_config_changed()
    end
end
function Options.prototype.knob_sensitivity(self, alt, slow)
    return ((alt and self.config.knob_sensitivity_alt) or self.config.knob_sensitivity_main) * ((slow and 0.3) or 1)
end
return ____exports
