-- Tweaked during build to work around sourcemaps issue.
__TS__sourcemap = {};
__TS__originalTraceback = debug.traceback;
--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
require("external.external_declarations")
local ____pyre_native = require("pyre_native")
local PyreNative = ____pyre_native.PyreNative
local ____driver = require("engine.driver")
local Driver = ____driver.Driver
require("palette")
require("global")
pyre_native = __TS__New(PyreNative)
driver = __TS__New(Driver, "fire_config.json")
return ____exports

