--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____fire_defs = require("engine.fire_defs")
local FIRE_GRID_WIDTH = ____fire_defs.FIRE_GRID_WIDTH
local ____common = require("engine.common")
local RENOISE_MIDI = ____common.RENOISE_MIDI
____exports.DivisionParameter = __TS__Class()
local DivisionParameter = ____exports.DivisionParameter
DivisionParameter.name = "DivisionParameter"
function DivisionParameter.prototype.____constructor(self, min, max, get_with, set_with)
    self.default_value = min
    self.min_value = min
    self.max_value = max
    self.get_with = get_with
    self.set_with = set_with
end
function DivisionParameter.prototype.get(self)
    local track_model = self.layer:get_track_model()
    if track_model then
        local division = track_model.division_specs[self.layer:get_selected_layer() + 1]
        return self.get_with(division)
    else
        return self.default_value
    end
end
function DivisionParameter.prototype.set(self, value)
    local track_model = self.layer:get_track_model()
    if track_model then
        local division = track_model.division_specs[self.layer:get_selected_layer() + 1]
        self.set_with(division, value)
        division:clean()
        track_model:apply_division_specs()
        track_model.is_dirty = true
    end
end
function DivisionParameter.prototype.get_text(self)
    return tostring(
        self:get()
    )
end
____exports.ParameterStepSize = __TS__Class()
local ParameterStepSize = ____exports.ParameterStepSize
ParameterStepSize.name = "ParameterStepSize"
__TS__ClassExtends(ParameterStepSize, ____exports.DivisionParameter)
function ParameterStepSize.prototype.____constructor(self)
    ParameterStepSize.____super.prototype.____constructor(
        self,
        1,
        FIRE_GRID_WIDTH,
        function(d) return d.step_size end,
        function(d, v)
            d.step_size = v
        end
    )
end
____exports.ParameterTimeBase = __TS__Class()
local ParameterTimeBase = ____exports.ParameterTimeBase
ParameterTimeBase.name = "ParameterTimeBase"
__TS__ClassExtends(ParameterTimeBase, ____exports.DivisionParameter)
function ParameterTimeBase.prototype.____constructor(self)
    ParameterTimeBase.____super.prototype.____constructor(
        self,
        1,
        FIRE_GRID_WIDTH,
        function(d) return d.time_base end,
        function(d, v)
            d.time_base = v
        end
    )
end
____exports.ParameterDelay = __TS__Class()
local ParameterDelay = ____exports.ParameterDelay
ParameterDelay.name = "ParameterDelay"
__TS__ClassExtends(ParameterDelay, ____exports.DivisionParameter)
function ParameterDelay.prototype.____constructor(self)
    ParameterDelay.____super.prototype.____constructor(
        self,
        0,
        FIRE_GRID_WIDTH - 1,
        function(d) return d.delay end,
        function(d, v)
            d.delay = v
        end
    )
end
____exports.ParameterStepCount = __TS__Class()
local ParameterStepCount = ____exports.ParameterStepCount
ParameterStepCount.name = "ParameterStepCount"
__TS__ClassExtends(ParameterStepCount, ____exports.DivisionParameter)
function ParameterStepCount.prototype.____constructor(self)
    ParameterStepCount.____super.prototype.____constructor(
        self,
        1,
        FIRE_GRID_WIDTH,
        function(d) return d.step_count end,
        function(d, v)
            d.step_count = v
        end
    )
end
____exports.ParameterPulseCount = __TS__Class()
local ParameterPulseCount = ____exports.ParameterPulseCount
ParameterPulseCount.name = "ParameterPulseCount"
__TS__ClassExtends(ParameterPulseCount, ____exports.DivisionParameter)
function ParameterPulseCount.prototype.____constructor(self)
    ParameterPulseCount.____super.prototype.____constructor(
        self,
        1,
        FIRE_GRID_WIDTH,
        function(d)
            self.max_value = d.step_count
            return d.pulse_count
        end,
        function(d, v)
            d.pulse_count = v
        end
    )
end
____exports.ParameterPhase = __TS__Class()
local ParameterPhase = ____exports.ParameterPhase
ParameterPhase.name = "ParameterPhase"
__TS__ClassExtends(ParameterPhase, ____exports.DivisionParameter)
function ParameterPhase.prototype.____constructor(self)
    ParameterPhase.____super.prototype.____constructor(
        self,
        0,
        FIRE_GRID_WIDTH,
        function(d)
            self.max_value = d.step_count - 1
            return d.phase
        end,
        function(d, v)
            d.phase = v
        end
    )
end
____exports.ParameterPitch = __TS__Class()
local ParameterPitch = ____exports.ParameterPitch
ParameterPitch.name = "ParameterPitch"
__TS__ClassExtends(ParameterPitch, ____exports.DivisionParameter)
function ParameterPitch.prototype.____constructor(self)
    ParameterPitch.____super.prototype.____constructor(
        self,
        RENOISE_MIDI.NOTE_MIN,
        RENOISE_MIDI.NOTE_MAX,
        function(d) return d.pitch end,
        function(d, v)
            d.pitch = v
            self.layer:mark_note(v)
        end
    )
end
____exports.ParameterGate = __TS__Class()
local ParameterGate = ____exports.ParameterGate
ParameterGate.name = "ParameterGate"
__TS__ClassExtends(ParameterGate, ____exports.DivisionParameter)
function ParameterGate.prototype.____constructor(self)
    ParameterGate.____super.prototype.____constructor(
        self,
        0,
        FIRE_GRID_WIDTH - 1,
        function(d) return d.gate end,
        function(d, v)
            d.gate = v
        end
    )
end
____exports.ParameterVelocity = __TS__Class()
local ParameterVelocity = ____exports.ParameterVelocity
ParameterVelocity.name = "ParameterVelocity"
__TS__ClassExtends(ParameterVelocity, ____exports.DivisionParameter)
function ParameterVelocity.prototype.____constructor(self)
    ParameterVelocity.____super.prototype.____constructor(
        self,
        0,
        FIRE_GRID_WIDTH - 1,
        function(d) return d.velocity_index end,
        function(d, v)
            d.velocity_index = v
        end
    )
end
____exports.ParameterVelocityDelta = __TS__Class()
local ParameterVelocityDelta = ____exports.ParameterVelocityDelta
ParameterVelocityDelta.name = "ParameterVelocityDelta"
__TS__ClassExtends(ParameterVelocityDelta, ____exports.DivisionParameter)
function ParameterVelocityDelta.prototype.____constructor(self)
    ParameterVelocityDelta.____super.prototype.____constructor(
        self,
        0,
        FIRE_GRID_WIDTH - 1,
        function(d) return d.velocity_delta_index end,
        function(d, v)
            d.velocity_delta_index = v
        end
    )
end
____exports.ParameterVelocityRandom = __TS__Class()
local ParameterVelocityRandom = ____exports.ParameterVelocityRandom
ParameterVelocityRandom.name = "ParameterVelocityRandom"
__TS__ClassExtends(ParameterVelocityRandom, ____exports.DivisionParameter)
function ParameterVelocityRandom.prototype.____constructor(self)
    ParameterVelocityRandom.____super.prototype.____constructor(
        self,
        0,
        FIRE_GRID_WIDTH - 1,
        function(d) return d.velocity_random end,
        function(d, v)
            d.velocity_random = v
        end
    )
end
return ____exports
