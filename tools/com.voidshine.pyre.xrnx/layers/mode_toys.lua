--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local ____layer_knobs_selector = require("layers.layer_knobs_selector")
local LayerKnobs = ____layer_knobs_selector.LayerKnobs
local ____knob = require("engine.knob")
local KnobValue = ____knob.KnobValue
local ____fire_led_state = require("engine.fire_led_state")
local FIRE_LED_WIDTH = ____fire_led_state.FIRE_LED_WIDTH
local FIRE_LED_HEIGHT = ____fire_led_state.FIRE_LED_HEIGHT
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local ModelToys = __TS__Class()
ModelToys.name = "ModelToys"
__TS__ClassExtends(ModelToys, ModelLayer)
function ModelToys.prototype.____constructor(self, ...)
    ModelLayer.prototype.____constructor(self, ...)
    self.rect = __TS__New(Rect, 0, 0, 0, 0)
end
function ModelToys.prototype.__eq(self, rhs)
    return ModelLayer.prototype.__eq(self, rhs)
end
local LayerToys = __TS__Class()
LayerToys.name = "LayerToys"
__TS__ClassExtends(LayerToys, Layer)
function LayerToys.prototype.____constructor(self)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelToys),
        "Toys"
    )
    self.knobs = {
        __TS__New(KnobValue, "X", FIRE_LED_WIDTH / 2, 0, FIRE_LED_WIDTH, 1),
        __TS__New(KnobValue, "Y", FIRE_LED_HEIGHT / 2, 0, FIRE_LED_HEIGHT, 1),
        __TS__New(KnobValue, "W", 3, 0, FIRE_LED_WIDTH, 1),
        __TS__New(KnobValue, "H", 19, 0, FIRE_LED_HEIGHT, 1)
    }
    self.children = {
        __TS__New(LayerKnobs, "Toy Knobs", self.knobs)
    }
end
function LayerToys.prototype.update_model(self, m)
    m.rect.left = self.knobs[1]:get_value()
    m.rect.top = self.knobs[2]:get_value()
    m.rect.width = self.knobs[3]:get_value()
    m.rect.height = self.knobs[4]:get_value()
end
function LayerToys.prototype.render(self, rc, m)
    rc:led_box(m.rect, 1)
    rc:led_text(4, driver.VERSION_STRING)
end
____exports.ModeToys = __TS__Class()
local ModeToys = ____exports.ModeToys
ModeToys.name = "ModeToys"
__TS__ClassExtends(ModeToys, Layer)
function ModeToys.prototype.____constructor(self)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        "Toys Mode"
    )
    self.children = {
        __TS__New(LayerToys)
    }
end
return ____exports
