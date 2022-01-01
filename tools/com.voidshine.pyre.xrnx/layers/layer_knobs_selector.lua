--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____fire_defs = require("engine.fire_defs")
local FIRE_BUTTON = ____fire_defs.FIRE_BUTTON
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
____exports.LayerKnobsSelector = __TS__Class()
local LayerKnobsSelector = ____exports.LayerKnobsSelector
LayerKnobsSelector.name = "LayerKnobsSelector"
__TS__ClassExtends(LayerKnobsSelector, Layer)
function LayerKnobsSelector.prototype.____constructor(self, knob_layers)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        "Knobs (Selector)"
    )
    self.index = 0
    self.button_down = false
    self.last_index = 1
    assert(#knob_layers >= 2)
    self.knob_layers = knob_layers
    local convert
    convert = function(n) return function(note, velocity)
        if self.button_down then
            self:select(n)
        end
        return true
    end end
    self:set_note_on_handlers(
        {
            [FIRE_BUTTON.ChannelMixerUserButton] = function()
                self.button_down = true
                self:select(self.index + 1)
            end,
            [FIRE_BUTTON.KnobVolume] = convert(0),
            [FIRE_BUTTON.KnobPan] = convert(1),
            [FIRE_BUTTON.KnobFilter] = convert(2),
            [FIRE_BUTTON.KnobResonance] = convert(3)
        }
    )
    self:set_note_off_handlers(
        {
            [FIRE_BUTTON.ChannelMixerUserButton] = function()
                self.button_down = false
            end
        }
    )
    self:mount_selection()
    self.always_dirty = true
end
function LayerKnobsSelector.prototype.mount_selection(self)
    self:mount({self.knob_layers[self.index + 1]})
end
function LayerKnobsSelector.prototype.all_on_midi_note(self, note, velocity)
    if self.button_down then
        return self:on_midi_note(note, velocity)
    end
    return Layer.prototype.all_on_midi_note(self, note, velocity)
end
function LayerKnobsSelector.prototype.select(self, new_index)
    self.last_index = self.index
    self.index = new_index % #self.knob_layers
    self:mount_selection()
end
function LayerKnobsSelector.prototype.update_model(self, m)
end
function LayerKnobsSelector.prototype.render(self, rc, m)
    rc:quad_light_select(self.index)
end
____exports.LayerKnobs = __TS__Class()
local LayerKnobs = ____exports.LayerKnobs
LayerKnobs.name = "LayerKnobs"
__TS__ClassExtends(LayerKnobs, Layer)
function LayerKnobs.prototype.____constructor(self, name, knobs)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        name
    )
    self.knobs = knobs
    self:set_knob_handlers(knobs)
    self.mount_message = table.concat(
        __TS__ArrayMap(
            knobs,
            function(____, knob) return ("[" .. tostring((knob and knob.display_name) or "_")) .. "]" end
        ),
        " " or ","
    )
end
function LayerKnobs.prototype.on_mount(self)
    Layer.prototype.on_mount(self)
    renoise.app():show_status(self.mount_message)
end
function LayerKnobs.prototype.render(self, rc, m)
    rc:led_page(
        self.name,
        __TS__ArrayMap(
            self.knobs,
            function(____, k) return (k and k:display_text()) or "---" end
        )
    )
end
____exports.LayerKnobsDelta = __TS__Class()
local LayerKnobsDelta = ____exports.LayerKnobsDelta
LayerKnobsDelta.name = "LayerKnobsDelta"
__TS__ClassExtends(LayerKnobsDelta, Layer)
function LayerKnobsDelta.prototype.____constructor(self, name, knob_delta_handler)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        name
    )
    self:set_knob_delta_handler(knob_delta_handler)
end
return ____exports
