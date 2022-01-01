--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
local ____layer = require("engine.layer")
local Layer = ____layer.Layer
local ____layer_transport = require("layers.layer_transport")
local LayerTransport = ____layer_transport.LayerTransport
local ____model_layer = require("engine.model_layer")
local ModelLayer = ____model_layer.ModelLayer
local ____layer_generate_euclidean = require("layers.layer_generate_euclidean")
local LayerGenerateEuclidean = ____layer_generate_euclidean.LayerGenerateEuclidean
local ____layer_menu_common = require("layers.layer_menu_common")
local LayerMenuCommon = ____layer_menu_common.LayerMenuCommon
____exports.ModeGenerateEuclidean = __TS__Class()
local ModeGenerateEuclidean = ____exports.ModeGenerateEuclidean
ModeGenerateEuclidean.name = "ModeGenerateEuclidean"
__TS__ClassExtends(ModeGenerateEuclidean, Layer)
function ModeGenerateEuclidean.prototype.____constructor(self)
    Layer.prototype.____constructor(
        self,
        __TS__New(ModelLayer),
        "Generate Euclidean Mode"
    )
    self.children = {
        __TS__New(LayerTransport),
        __TS__New(LayerGenerateEuclidean)
    }
    LayerMenuCommon:create_on(self)
end
return ____exports
