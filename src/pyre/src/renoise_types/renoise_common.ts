// This type marks Lua one-based index values. It doesn't really need to be a separate type
// because the transformer can look at type declarations to determine usage.
type LuaIndex = number;

// It is an intersection type only to avoid being reduced to an alias for number.
// To avoid errors, manually cast as number when doing the shift, or else let the transformer convert automatically.
// type LuaIndex = number & { readonly __tag: unique symbol };
