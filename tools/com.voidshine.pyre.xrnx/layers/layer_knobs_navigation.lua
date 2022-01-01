--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____knob = require("engine.knob")
local KnobTime = ____knob.KnobTime
local KnobAlt = ____knob.KnobAlt
local KnobColumnSelect = ____knob.KnobColumnSelect
local KnobInstrumentSelect = ____knob.KnobInstrumentSelect
local ____layer_common = require("layers.layer_common")
local LayerCommon = ____layer_common.LayerCommon
local ModelCommon = ____layer_common.ModelCommon
local ____utility = require("engine.utility")
local step_track_column = ____utility.step_track_column
____exports.KnobFocusedNavigation = __TS__Class()
local KnobFocusedNavigation = ____exports.KnobFocusedNavigation
KnobFocusedNavigation.name = "KnobFocusedNavigation"
function KnobFocusedNavigation.prototype.____constructor(self, source_model)
    self.display_name = "Navigate"
    self.source_model = source_model
end
function KnobFocusedNavigation.prototype.display_text(self)
    return self.display_name
end
function KnobFocusedNavigation.prototype.on_turn(self, delta)
    if self.source_model.alt then
        step_track_column(delta, false, false, false)
    else
        if self.source_model.shift then
            delta = delta * rns.transport.lpb
        end
        rns.selected_line_index = cLib.clamp_value((rns.selected_line_index - 1) + delta, 0, rns.selected_pattern.number_of_lines - 1) + 1
    end
end
function KnobFocusedNavigation.prototype.on_press(self)
    if self.source_model.alt then
        if __TS__ArrayEvery(
            rns.tracks,
            function(____, track) return track.collapsed end
        ) then
            __TS__ArrayForEach(
                rns.tracks,
                function(____, track)
                    track.collapsed = false
                end
            )
        else
            __TS__ArrayForEach(
                rns.tracks,
                function(____, track)
                    track.collapsed = true
                end
            )
        end
    else
        rns.selected_track.collapsed = not rns.selected_track.collapsed
    end
end
function KnobFocusedNavigation.prototype.on_release(self)
end
function KnobFocusedNavigation.prototype.on_toggled(self, active)
end
____exports.LayerKnobsNavigation = __TS__Class()
local LayerKnobsNavigation = ____exports.LayerKnobsNavigation
LayerKnobsNavigation.name = "LayerKnobsNavigation"
__TS__ClassExtends(LayerKnobsNavigation, LayerCommon)
function LayerKnobsNavigation.prototype.____constructor(self)
    LayerCommon.prototype.____constructor(
        self,
        __TS__New(ModelCommon),
        "Knobs (Time)"
    )
    self:set_knob_handlers(
        {
            __TS__New(
                KnobAlt,
                self.model,
                {
                    __TS__New(
                        KnobTime,
                        driver.options:knob_sensitivity(false, false)
                    ),
                    __TS__New(
                        KnobTime,
                        driver.options:knob_sensitivity(true, false)
                    )
                }
            ),
            __TS__New(
                KnobAlt,
                self.model,
                {
                    __TS__New(
                        KnobColumnSelect,
                        false,
                        false,
                        driver.options:knob_sensitivity(false, true)
                    ),
                    __TS__New(
                        KnobColumnSelect,
                        false,
                        false,
                        driver.options:knob_sensitivity(true, true)
                    )
                }
            ),
            __TS__New(KnobInstrumentSelect),
            nil
        }
    )
end
function LayerKnobsNavigation.prototype.update_model(self, m)
end
function LayerKnobsNavigation.prototype.render(self, rc, m)
    rc:led_text(-1, "Nav Time\nNav Column\n\nTODO: Clean up.")
end
return ____exports
