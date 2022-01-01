--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____fire = require("engine.fire")
local Fire = ____fire.Fire
local ____generated_midi = require("engine.generated_midi")
local GeneratedMidi = ____generated_midi.GeneratedMidi
local ____options = require("engine.options")
local Options = ____options.Options
local ____song_data = require("engine.song_data")
local SongData = ____song_data.SongData
____exports.Driver = __TS__Class()
local Driver = ____exports.Driver
Driver.name = "Driver"
function Driver.prototype.____constructor(self, options_filename)
    self.VERSION_STRING = "V: " .. tostring(
        pyre_native:get_version()
    )
    self.song_data = __TS__New(SongData)
    self.coro = nil
    self.is_started = false
    self.generated_midi = __TS__New(GeneratedMidi)
    self.fires = {
        __TS__New(Fire, 0),
        __TS__New(Fire, 1)
    }
    self.options = __TS__New(
        Options,
        options_filename,
        function(options)
            self:on_options_changed(options)
        end
    )
    self.options:load_config()
    renoise.tool().app_new_document_observable:add_notifier(self.on_new_document, self)
    renoise.tool().app_saved_document_observable:add_notifier(self.on_saved_document, self)
    renoise.tool().app_release_document_observable:add_notifier(self.on_release_document, self)
    renoise.tool():add_menu_entry(
        {
            name = "Main Menu:Tools:voidshine pyre:Configure...",
            invoke = function()
                self.options:prompt_configuration()
            end
        }
    )
    renoise.tool():add_menu_entry(
        {
            name = "Main Menu:Tools:voidshine pyre:Reset configuration to default",
            invoke = function()
                self.options:reset_to_default()
            end
        }
    )
end
function Driver.prototype.on_new_document(self)
    rns = renoise.song()
    self.song_data = SongData:load_from_file()
    assert(not self.is_started)
    self:start()
end
function Driver.prototype.on_saved_document(self)
    if __TS__ArraySome(
        self.fires,
        function(____, fire) return fire.is_active end
    ) then
        self.song_data:save_to_file()
    else
        if self.coro == nil then
            self.coro = coroutine.create(
                function()
                    local ____then = os.clock() + 1.5
                    while os.clock() < ____then do
                        coroutine.yield()
                    end
                    renoise.app():show_status("voidshine pyre data not written (no active Fire devices)")
                end
            )
        end
    end
end
function Driver.prototype.on_release_document(self)
    if self.is_started then
        self:stop()
    end
    rns = nil
    pyre_native:shutdown()
end
function Driver.prototype.on_options_changed(self, options)
    if self.is_started then
        __TS__ArrayForEach(
            self.fires,
            function(____, fire, _)
                local fire_config = options:get_fire_config(fire.fire_device_index)
                fire:on_fire_config_changed(fire_config)
            end
        )
        self.generated_midi:on_config_changed(options.config.generated_midi)
    else
        rprint("options changed while not started")
    end
end
function Driver.prototype.on_idle(self)
    if self.coro ~= nil then
        local succeeded, ____error = coroutine.resume(self.coro)
        if not succeeded then
            self.coro = nil
            print("coro", ____error)
        end
    end
    assert(self.is_started and rns)
    __TS__ArrayForEach(
        self.fires,
        function(____, fire, _)
            if fire.is_active then
                fire:on_idle()
            end
        end
    )
end
function Driver.prototype.start(self)
    self.is_started = true
    self:on_options_changed(self.options)
    renoise.tool().app_idle_observable:add_notifier(self.on_idle, self)
end
function Driver.prototype.stop(self)
    renoise.tool().app_idle_observable:remove_notifier(self.on_idle, self)
    self.is_started = false
    __TS__ArrayForEach(
        self.fires,
        function(____, fire, _)
            fire:on_fire_config_changed(nil)
        end
    )
end
function Driver.prototype.invalidate_all_layers(self)
    __TS__ArrayForEach(
        self.fires,
        function(____, fire)
            if fire.is_active then
                fire.root_layer:invalidate()
            end
        end
    )
end
return ____exports
