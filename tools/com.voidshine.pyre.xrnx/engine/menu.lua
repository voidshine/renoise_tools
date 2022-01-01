--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
require("lualib_bundle");
local ____exports = {}
____exports.MenuItem = __TS__Class()
local MenuItem = ____exports.MenuItem
MenuItem.name = "MenuItem"
function MenuItem.prototype.____constructor(self, text, items, on_select)
    self.index = 0
    self.text = text
    self.items = items or ({})
    self.on_select = on_select or (function()
    end)
end
function MenuItem.prototype.set_indices(self)
    __TS__ArrayForEach(
        self.items,
        function(____, item, i)
            item.index = i
            item:set_indices()
        end
    )
end
return ____exports
