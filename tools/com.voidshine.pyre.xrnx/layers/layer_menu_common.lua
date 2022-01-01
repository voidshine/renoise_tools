--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer_common = require("layers.layer_common")
local LayerCommon = ____layer_common.LayerCommon
local ModelCommon = ____layer_common.ModelCommon
local ____knob = require("engine.knob")
local KnobLatch = ____knob.KnobLatch
local ____layer_knobs_navigation = require("layers.layer_knobs_navigation")
local KnobFocusedNavigation = ____layer_knobs_navigation.KnobFocusedNavigation
local ____menu = require("engine.menu")
local MenuItem = ____menu.MenuItem
local ____fire_defs = require("engine.fire_defs")
local FIRE_BUTTON = ____fire_defs.FIRE_BUTTON
local FIRE_LIGHT = ____fire_defs.FIRE_LIGHT
local LIGHT_DARK_RED = ____fire_defs.LIGHT_DARK_RED
local LIGHT_BRIGHT_RED = ____fire_defs.LIGHT_BRIGHT_RED
local ____song_data = require("engine.song_data")
local PITCH_CLASS_NAMES = ____song_data.PITCH_CLASS_NAMES
local NULL_ITEM = __TS__New(
    MenuItem,
    "()",
    {},
    function()
        print("Error: Activated null menu item.")
    end
)
local KnobMenu = __TS__Class()
KnobMenu.name = "KnobMenu"
function KnobMenu.prototype.____constructor(self, root)
    self.display_name = "Knob Menu"
    self.stack = {}
    self.root = root
end
function KnobMenu.prototype.display_text(self)
    return self.display_name
end
function KnobMenu.prototype.current(self)
    return self.stack[#self.stack]
end
function KnobMenu.prototype.pop(self)
    if #self.stack > 2 then
        table.remove(self.stack)
        self:status()
        return true
    end
    return false
end
function KnobMenu.prototype.clear(self)
    self.stack = {self.root}
end
function KnobMenu.prototype.enter(self)
    self.stack = {self.root, self.root.items[1]}
end
function KnobMenu.prototype.is_active(self)
    return #self.stack > 1
end
function KnobMenu.prototype.status(self)
    renoise.app():show_status(
        "pyre menu: " .. tostring(
            self:current().text
        )
    )
end
function KnobMenu.prototype.on_toggled(self, active)
    if active then
        self:enter()
        self:status()
    else
        self:clear()
        renoise.app():show_status("")
    end
end
function KnobMenu.prototype.on_turn(self, delta)
    if not self:is_active() then
        return
    end
    local parent = self.stack[(#self.stack - 2) + 1]
    local index = ((self:current().index + delta) + #parent.items) % #parent.items
    self.stack[#self.stack] = parent.items[index + 1]
    self:status()
end
function KnobMenu.prototype.on_press(self)
    local current = self:current()
    current.on_select()
    if #current.items > 0 then
        __TS__ArrayPush(self.stack, current.items[1])
    else
        self:clear()
    end
    self:status()
end
function KnobMenu.prototype.on_release(self)
end
function KnobMenu.prototype.get_menu_stack_text(self)
    return table.concat(
        __TS__ArrayMap(
            self.stack,
            function(____, item) return tostring(item.text) .. tostring(((#item.items > 0) and "..") or " !") end
        ),
        "\n" or ","
    )
end
local ModelMenuCommon = __TS__Class()
ModelMenuCommon.name = "ModelMenuCommon"
__TS__ClassExtends(ModelMenuCommon, ModelCommon)
function ModelMenuCommon.prototype.____constructor(self, ...)
    ModelCommon.prototype.____constructor(self, ...)
    self.browser_color = LIGHT_DARK_RED
end
function ModelMenuCommon.prototype.__eq(self, rhs)
    return ModelCommon.prototype.__eq(self, rhs)
end
____exports.LayerMenuCommon = __TS__Class()
local LayerMenuCommon = ____exports.LayerMenuCommon
LayerMenuCommon.name = "LayerMenuCommon"
__TS__ClassExtends(LayerMenuCommon, LayerCommon)
function LayerMenuCommon.prototype.____constructor(self)
    LayerCommon.prototype.____constructor(
        self,
        __TS__New(ModelMenuCommon),
        "Menu Common"
    )
    self.knob_menu = __TS__New(
        KnobMenu,
        __TS__New(MenuItem, "MENU")
    )
    self.knob_latch = __TS__New(
        KnobLatch,
        {
            __TS__New(KnobFocusedNavigation, self.model),
            self.knob_menu
        }
    )
    self:set_knob_handlers({nil, nil, nil, nil, self.knob_latch})
    local original_select_button_handler
    original_select_button_handler = self.note_on_handlers[FIRE_BUTTON.KnobSelect]
    self:set_note_on_handlers(
        {
            [FIRE_BUTTON.Browser] = function()
                if self.model.alt or (not self.knob_menu:pop()) then
                    self.knob_latch:cycle()
                end
            end,
            [FIRE_BUTTON.KnobSelect] = function(note, velocity)
                local was_active = self.knob_menu:is_active()
                original_select_button_handler(note, velocity)
                if was_active and (not self.knob_menu:is_active()) then
                    self.knob_latch:cycle()
                end
            end
        }
    )
end
function LayerMenuCommon.prototype.build_menu(self, item)
    __TS__ArrayPush(
        item.items,
        __TS__New(
            MenuItem,
            "Pattern",
            {
                __TS__New(
                    MenuItem,
                    "Clone",
                    {},
                    function()
                        rns.sequencer:clone_range((rns.selected_sequence_index - 1) + 1, (rns.selected_sequence_index - 1) + 1)
                    end
                )
            }
        )
    )
    __TS__ArrayPush(
        item.items,
        __TS__New(
            MenuItem,
            "Song Data",
            {
                __TS__New(
                    MenuItem,
                    "Root Pitch",
                    __TS__ArrayMap(
                        PITCH_CLASS_NAMES,
                        function(____, pitch, i) return __TS__New(
                            MenuItem,
                            (tostring(i) .. " = ") .. tostring(pitch),
                            {},
                            function()
                                driver.song_data.root_pitch_class = i
                                driver:invalidate_all_layers()
                            end
                        ) end
                    )
                )
            }
        )
    )
end
function LayerMenuCommon.prototype.update_model(self, m)
    m.browser_color = ((self.knob_latch:index() > 0) and LIGHT_BRIGHT_RED) or LIGHT_DARK_RED
end
function LayerMenuCommon.prototype.render(self, rc, m)
    rc:light(FIRE_LIGHT.Browser, m.browser_color)
    if self.knob_latch:index() > 0 then
        rc:led_clear()
        rc:led_text(
            -1,
            self.knob_menu:get_menu_stack_text()
        )
    end
end
function LayerMenuCommon.create_on(self, layer)
    local menu_layer = __TS__New(____exports.LayerMenuCommon)
    __TS__ArrayPush(layer.children, menu_layer)
    layer:build_menu(menu_layer.knob_menu.root)
    menu_layer.knob_menu.root:set_indices()
end
return ____exports
