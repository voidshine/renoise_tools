--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer_common = require("layers.layer_common")
local LayerCommon = ____layer_common.LayerCommon
local ModelCommon = ____layer_common.ModelCommon
local ____utility = require("engine.utility")
local Rect = ____utility.Rect
local ____fire_defs = require("engine.fire_defs")
local FIRE_GRID_WIDTH = ____fire_defs.FIRE_GRID_WIDTH
local FIRE_LIGHT = ____fire_defs.FIRE_LIGHT
local FIRE_BUTTON = ____fire_defs.FIRE_BUTTON
local LIGHT_DARK_RED = ____fire_defs.LIGHT_DARK_RED
local FIRE_GRID_HEIGHT = ____fire_defs.FIRE_GRID_HEIGHT
local ____palette = require("palette")
local PALETTE = ____palette.PALETTE
local ____color = require("engine.color")
local Color = ____color.Color
local ____layer_note_grid = require("layers.layer_note_grid")
local LayerNoteGrid = ____layer_note_grid.LayerNoteGrid
local ____generator = require("generator.generator")
local DerivedTrackOutput = ____generator.DerivedTrackOutput
local TrackModel = ____generator.TrackModel
local ____knob = require("engine.knob")
local KnobQuantizing = ____knob.KnobQuantizing
local KnobQuantizedParameter = ____knob.KnobQuantizedParameter
local ____parameters = require("generator.parameters")
local ParameterTimeBase = ____parameters.ParameterTimeBase
local ParameterDelay = ____parameters.ParameterDelay
local ParameterStepSize = ____parameters.ParameterStepSize
local ParameterGate = ____parameters.ParameterGate
local ParameterStepCount = ____parameters.ParameterStepCount
local ParameterPulseCount = ____parameters.ParameterPulseCount
local ParameterPhase = ____parameters.ParameterPhase
local ParameterVelocity = ____parameters.ParameterVelocity
local ParameterVelocityDelta = ____parameters.ParameterVelocityDelta
local ParameterVelocityRandom = ____parameters.ParameterVelocityRandom
local ParameterPitch = ____parameters.ParameterPitch
local ____layer_knobs_selector = require("layers.layer_knobs_selector")
local LayerKnobsSelector = ____layer_knobs_selector.LayerKnobsSelector
local LayerKnobs = ____layer_knobs_selector.LayerKnobs
local ____menu = require("engine.menu")
local MenuItem = ____menu.MenuItem
local palette = PALETTE.GENERATE_EUCLIDEAN
local SHIFT_SENSITIVITY = 0.15
local function toggle_gen(name)
    return (__TS__StringStartsWith(name, "[gen]") and string.sub(name, #"[gen]" + 1)) or ("[gen]" .. tostring(name))
end
local KnobRandomSeed = __TS__Class()
KnobRandomSeed.name = "KnobRandomSeed"
__TS__ClassExtends(KnobRandomSeed, KnobQuantizing)
function KnobRandomSeed.prototype.____constructor(self, layer)
    KnobQuantizing.prototype.____constructor(self, "Random Seed", SHIFT_SENSITIVITY, 1)
    self.layer = layer
end
function KnobRandomSeed.prototype.on_step(self, steps)
    local track_model = self.layer:get_track_model()
    if track_model then
        track_model.seed = track_model.seed + (steps * 500)
        track_model.is_dirty = true
    end
end
local KnobLinkedParameter = __TS__Class()
KnobLinkedParameter.name = "KnobLinkedParameter"
__TS__ClassExtends(KnobLinkedParameter, KnobQuantizedParameter)
function KnobLinkedParameter.prototype.____constructor(self, layer, name, parameter)
    KnobQuantizedParameter.prototype.____constructor(self, name, SHIFT_SENSITIVITY, parameter)
    self.layer = layer
    parameter.layer = layer
end
function KnobLinkedParameter.prototype.on_press(self)
    self.layer.model.held_parameter = self.parameter
end
function KnobLinkedParameter.prototype.on_release(self)
    self.layer.model.held_parameter = nil
end
local KnobNoteParameter = __TS__Class()
KnobNoteParameter.name = "KnobNoteParameter"
__TS__ClassExtends(KnobNoteParameter, KnobLinkedParameter)
function KnobNoteParameter.prototype.on_press(self)
    KnobLinkedParameter.prototype.on_press(self)
    self.layer:mark_note(
        self.parameter:get()
    )
    self.layer:mount_note_grid(true)
end
function KnobNoteParameter.prototype.on_release(self)
    KnobLinkedParameter.prototype.on_release(self)
    self.layer:mount_note_grid(false)
end
local ModelGenerateEuclidean = __TS__Class()
ModelGenerateEuclidean.name = "ModelGenerateEuclidean"
__TS__ClassExtends(ModelGenerateEuclidean, ModelCommon)
function ModelGenerateEuclidean.prototype.____constructor(self)
    ModelCommon.prototype.____constructor(self)
    self.current_track_model = nil
    self.selected_layer = 0
end
____exports.LayerGenerateEuclidean = __TS__Class()
local LayerGenerateEuclidean = ____exports.LayerGenerateEuclidean
LayerGenerateEuclidean.name = "LayerGenerateEuclidean"
__TS__ClassExtends(LayerGenerateEuclidean, LayerCommon)
function LayerGenerateEuclidean.prototype.____constructor(self)
    LayerCommon.prototype.____constructor(
        self,
        __TS__New(ModelGenerateEuclidean),
        "Generate Euclidean"
    )
    self.track_models = {}
    self.track_output = __TS__New(DerivedTrackOutput)
    self.note_grid = __TS__New(
        LayerNoteGrid,
        "Note Grid: Generate Euclidean",
        __TS__New(Rect, 0, 0, FIRE_GRID_WIDTH, FIRE_GRID_HEIGHT),
        function(v) return v end
    )
    self.always_dirty = true
    self.note_grid.always_dirty = true
    self.note_grid.note_handler = function(note, velocity)
        if velocity then
            self.model.held_parameter:set(note)
        end
    end
    self.layer_knobs_selector = __TS__New(
        LayerKnobsSelector,
        {
            __TS__New(
                LayerKnobs,
                "Time",
                {
                    __TS__New(
                        KnobLinkedParameter,
                        self,
                        "Time Base",
                        __TS__New(ParameterTimeBase)
                    ),
                    __TS__New(
                        KnobLinkedParameter,
                        self,
                        "Delay",
                        __TS__New(ParameterDelay)
                    ),
                    __TS__New(
                        KnobLinkedParameter,
                        self,
                        "Step Size",
                        __TS__New(ParameterStepSize)
                    ),
                    __TS__New(
                        KnobLinkedParameter,
                        self,
                        "Gate",
                        __TS__New(ParameterGate)
                    )
                }
            ),
            __TS__New(
                LayerKnobs,
                "Steps",
                {
                    __TS__New(
                        KnobLinkedParameter,
                        self,
                        "Step Count",
                        __TS__New(ParameterStepCount)
                    ),
                    __TS__New(
                        KnobLinkedParameter,
                        self,
                        "Pulse Count",
                        __TS__New(ParameterPulseCount)
                    ),
                    __TS__New(
                        KnobLinkedParameter,
                        self,
                        "Phase",
                        __TS__New(ParameterPhase)
                    ),
                    __TS__New(
                        KnobLinkedParameter,
                        self,
                        "Phase",
                        __TS__New(ParameterPhase)
                    )
                }
            ),
            __TS__New(
                LayerKnobs,
                "Velocity",
                {
                    __TS__New(
                        KnobLinkedParameter,
                        self,
                        "Velocity",
                        __TS__New(ParameterVelocity)
                    ),
                    __TS__New(
                        KnobLinkedParameter,
                        self,
                        "Velocity Delta",
                        __TS__New(ParameterVelocityDelta)
                    ),
                    __TS__New(
                        KnobLinkedParameter,
                        self,
                        "Velocity Random",
                        __TS__New(ParameterVelocityRandom)
                    ),
                    __TS__New(KnobRandomSeed, self)
                }
            ),
            __TS__New(
                LayerKnobs,
                "Pitch",
                {
                    __TS__New(
                        KnobNoteParameter,
                        self,
                        "Pitch",
                        __TS__New(ParameterPitch)
                    ),
                    __TS__New(
                        KnobNoteParameter,
                        self,
                        "Pitch",
                        __TS__New(ParameterPitch)
                    ),
                    __TS__New(
                        KnobNoteParameter,
                        self,
                        "Pitch",
                        __TS__New(ParameterPitch)
                    ),
                    __TS__New(
                        KnobNoteParameter,
                        self,
                        "Pitch",
                        __TS__New(ParameterPitch)
                    )
                }
            )
        }
    )
    self.children = {self.layer_knobs_selector}
    self:set_note_handlers_grid_rect(
        __TS__New(Rect, 0, 0, FIRE_GRID_WIDTH, 3),
        function(x, y, velocity)
            if not velocity then
                return
            end
            local track_model = self:get_track_model()
            if track_model then
                local spec = track_model.division_specs[y + 1]
                if self.model.alt then
                    spec.phase = x
                elseif self.model.shift then
                    spec.step_count = x + 1
                else
                    spec.pulse_count = x + 1
                end
                spec:clean()
                track_model:apply_division_specs()
                track_model.is_dirty = true
            end
        end
    )
    self:set_note_handlers_grid_rect(
        __TS__New(Rect, 0, 3, FIRE_GRID_WIDTH, 1),
        function(x, y, velocity)
            if not velocity then
                return
            end
            if self.model.held_parameter then
                self.model.held_parameter:set(self.model.held_parameter.min_value + x)
            else
                local left = FIRE_GRID_WIDTH - #self.layer_knobs_selector.knob_layers
                if x >= left then
                    self.layer_knobs_selector:select(x - left)
                end
            end
        end
    )
    self:set_note_on_handlers(
        {
            [FIRE_BUTTON.RowMute0] = function(note, velocity)
                self.model.selected_layer = 0
            end,
            [FIRE_BUTTON.RowMute1] = function(note, velocity)
                self.model.selected_layer = 1
            end,
            [FIRE_BUTTON.RowMute2] = function(note, velocity)
                self.model.selected_layer = 2
            end,
            [FIRE_BUTTON.GridLeft] = function()
                xTrack.jump_to_previous_sequencer_track()
            end,
            [FIRE_BUTTON.GridRight] = function()
                xTrack.jump_to_next_sequencer_track()
            end
        }
    )
    self:hook_notifiers(true)
end
function LayerGenerateEuclidean.prototype.mount_note_grid(self, on)
    if on then
        self:mount({self.layer_knobs_selector, self.note_grid})
    else
        self:mount({self.layer_knobs_selector})
    end
end
function LayerGenerateEuclidean.prototype.build_menu(self, item)
    __TS__ArrayPush(
        item.items,
        __TS__New(
            MenuItem,
            "Toggle track name [gen] prefix",
            {},
            function()
                rns.selected_track.name = toggle_gen(rns.selected_track.name)
            end
        )
    )
end
function LayerGenerateEuclidean.prototype.hook_notifiers(self, hook)
    if rns.selected_track_index_observable:has_notifier(self, self.on_track_changed) then
        rns.selected_track_index_observable:remove_notifier(self, self.on_track_changed)
    end
    if hook then
        rns.selected_track_index_observable:add_notifier(self, self.on_track_changed)
    end
end
function LayerGenerateEuclidean.prototype.on_track_changed(self)
    local track_model = self:get_track_model()
    if track_model then
        track_model.is_dirty = true
    end
end
function LayerGenerateEuclidean.prototype.get_track_model(self)
    local name = rns.selected_track.name
    local track_model = self.track_models[name]
    if (track_model == nil) and __TS__StringStartsWith(name, "[gen]") then
        track_model = __TS__New(TrackModel, name)
        self.track_models[name] = track_model
    end
    return track_model
end
function LayerGenerateEuclidean.prototype.update_model(self)
    self.model.current_track_model = self:get_track_model()
end
function LayerGenerateEuclidean.prototype.on_idle(self)
    LayerCommon.prototype.on_idle(self)
    for key in pairs(self.track_models) do
        local track_model = self.track_models[key]
        if track_model then
            if track_model.is_dirty then
                local start = os.clock()
                track_model.is_dirty = false
                if not track_model:write_to_track(self.track_output) then
                    self.track_models[key] = nil
                    print(
                        "Deleted orphan track model: " .. tostring(key)
                    )
                end
                local ____end = os.clock()
            end
        end
    end
end
function LayerGenerateEuclidean.prototype.render(self, rc, m)
    if m.held_parameter then
        rc:clear_grid(
            __TS__New(Rect, 0, 2, FIRE_GRID_WIDTH, 1)
        )
        local max_x = m.held_parameter.max_value - m.held_parameter.min_value
        local value_x = m.held_parameter:get() - m.held_parameter.min_value
        do
            local x = 0
            while x < FIRE_GRID_WIDTH do
                rc:pad(
                    x,
                    3,
                    ((x <= value_x) and Color:white()) or (((x <= max_x) and Color:gray(32)) or Color:black())
                )
                x = x + 1
            end
        end
    else
        rc:clear_grid(
            __TS__New(Rect, 0, 2, FIRE_GRID_WIDTH, 2)
        )
        local left = FIRE_GRID_WIDTH - #self.layer_knobs_selector.knob_layers
        do
            local x = left
            while x < FIRE_GRID_WIDTH do
                rc:pad(x, 3, (((x - left) == self.layer_knobs_selector.index) and palette.KNOB_SET_SELECTED) or palette.KNOB_SET_UNSELECTED)
                x = x + 1
            end
        end
    end
    rc:light(FIRE_LIGHT.RowMute0, ((m.selected_layer == 0) and palette.LAYER_SELECTED) or palette.LAYER_UNSELECTED)
    rc:light(FIRE_LIGHT.RowMute1, ((m.selected_layer == 1) and palette.LAYER_SELECTED) or palette.LAYER_UNSELECTED)
    rc:light(FIRE_LIGHT.RowMute2, ((m.selected_layer == 2) and palette.LAYER_SELECTED) or palette.LAYER_UNSELECTED)
    rc:light(
        FIRE_LIGHT.RowMute3,
        Color:black()
    )
    local track_model = m.current_track_model
    if track_model then
        local color = Color:rgb(rns.selected_track.color)
        __TS__ArrayForEach(
            track_model.division_specs,
            function(____, division, i)
                local x
                do
                    x = 0
                    while x < division.step_count do
                        rc:pad(
                            x,
                            i,
                            (division:is_occupied_at(x) and color) or palette.UNOCCUPIED_STEP
                        )
                        x = x + 1
                    end
                end
                do
                    while x < FIRE_GRID_WIDTH do
                        rc:pad(x, i, palette.BACKGROUND)
                        x = x + 1
                    end
                end
            end
        )
    else
        rc:clear_grid(
            __TS__New(Rect, 0, 0, FIRE_GRID_WIDTH, 3)
        )
    end
    rc:light(FIRE_LIGHT.GridLeft, LIGHT_DARK_RED)
    rc:light(FIRE_LIGHT.GridRight, LIGHT_DARK_RED)
end
function LayerGenerateEuclidean.prototype.mark_note(self, note)
    self.note_grid.model.marked_note = note
end
function LayerGenerateEuclidean.prototype.get_selected_layer(self)
    return self.model.selected_layer
end
return ____exports
