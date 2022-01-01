//LayerModel = {}

// Use Lua native types for model contents. Luabind classes won't work due to
// complexities around userdata comparison and cloning. For efficiency you can
// simply extend the base layer class's model with derived class's model fields,
// giving care to how each field is used. Use a plain Lua table for fields that
// get reassigned on change because reference comparison is sufficient. When
// deep __eq checking is needed, use a nested LayerModel and modify its fields
// or else use tables with an appropriate __eq implementation.

export class ModelLayer {
    // Note: table.rcopy doesn't work with userdata luabind classes, so we use Lua table.
    // new(obj) {
    //     this.__index = this
    //     return setmetatable(obj, this)
    // }

    // [key: string]: any;

    __eq(rhs: any) {
        // rprint(`__eq called: ${this}`);
        for (const key in this) {
            const v = (this as any)[key];
            // rprint(`[${key}] => ${v} : ${rhs[key]}`);
            if (rhs[key] != v) {
                return false;
            }
        }
        // TODO: This whole checking both ways technique is inefficient. Perhaps order keys and iterate instead.
        for (const key in rhs) {
            const v = rhs[key];
            if ((this as any)[key] != v) {
                return false;
            }
        }
        return true;
    }

    clone() {
        // TODO: This will *not* actually work for simple tables since they'll be guaranteed unique. Shallow copy,) {, but use clone where available?
        return table.rcopy(this);
    }
}
