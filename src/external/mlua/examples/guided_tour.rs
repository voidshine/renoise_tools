use std::f32;
use std::iter::FromIterator;

use mlua::{Function, Lua, MetaMethod, Result, UserData, UserDataMethods, Variadic};

fn main() -> Result<()> {
    // You can create a new Lua state with `Lua::new()`.  This loads the default Lua std library
    // *without* the debug library.
    let lua = Lua::new();

    // You can get and set global variables.  Notice that the globals table here is a permanent
    // reference to _G, and it is mutated behind the scenes as Lua code is loaded.  This API is
    // based heavily around sharing and internal mutation (just like Lua itself).

    let globals = lua.globals();

    globals.set("string_var", "hello")?;
    globals.set("int_var", 42)?;

    assert_eq!(globals.get::<_, String>("string_var")?, "hello");
    assert_eq!(globals.get::<_, i64>("int_var")?, 42);

    // You can load and evaluate Lua code.  The returned type of `Lua::load` is a builder
    // that allows you to change settings before running Lua code.  Here, we are using it to set
    // the name of the laoded chunk to "example code", which will be used when Lua error
    // messages are printed.

    lua.load(
        r#"
            global = 'foo'..'bar'
        "#,
    )
    .set_name("example code")?
    .exec()?;
    assert_eq!(globals.get::<_, String>("global")?, "foobar");

    assert_eq!(lua.load("1 + 1").eval::<i32>()?, 2);
    assert_eq!(lua.load("false == false").eval::<bool>()?, true);
    assert_eq!(lua.load("return 1 + 2").eval::<i32>()?, 3);

    // You can create and manage Lua tables

    let array_table = lua.create_table()?;
    array_table.set(1, "one")?;
    array_table.set(2, "two")?;
    array_table.set(3, "three")?;
    assert_eq!(array_table.len()?, 3);

    let map_table = lua.create_table()?;
    map_table.set("one", 1)?;
    map_table.set("two", 2)?;
    map_table.set("three", 3)?;
    let v: i64 = map_table.get("two")?;
    assert_eq!(v, 2);

    // You can pass values like `Table` back into Lua

    globals.set("array_table", array_table)?;
    globals.set("map_table", map_table)?;

    lua.load(
        r#"
            for k, v in pairs(array_table) do
                print(k, v)
            end

            for k, v in pairs(map_table) do
                print(k, v)
            end
        "#,
    )
    .exec()?;

    // You can load Lua functions

    let print: Function = globals.get("print")?;
    print.call::<_, ()>("hello from rust")?;

    // This API generally handles variadics using tuples.  This is one way to call a function with
    // multiple parameters:

    print.call::<_, ()>(("hello", "again", "from", "rust"))?;

    // But, you can also pass variadic arguments with the `Variadic` type.

    print.call::<_, ()>(Variadic::from_iter(
        ["hello", "yet", "again", "from", "rust"].iter().cloned(),
    ))?;

    // You can bind rust functions to Lua as well.  Callbacks receive the Lua state inself as their
    // first parameter, and the arguments given to the function as the second parameter.  The type
    // of the arguments can be anything that is convertible from the parameters given by Lua, in
    // this case, the function expects two string sequences.

    let check_equal = lua.create_function(|_, (list1, list2): (Vec<String>, Vec<String>)| {
        // This function just checks whether two string lists are equal, and in an inefficient way.
        // Lua callbacks return `mlua::Result`, an Ok value is a normal return, and an Err return
        // turns into a Lua 'error'.  Again, any type that is convertible to Lua may be returned.
        Ok(list1 == list2)
    })?;
    globals.set("check_equal", check_equal)?;

    // You can also accept runtime variadic arguments to rust callbacks.

    let join = lua.create_function(|_, strings: Variadic<String>| {
        // (This is quadratic!, it's just an example!)
        Ok(strings.iter().fold("".to_owned(), |a, b| a + b))
    })?;
    globals.set("join", join)?;

    assert_eq!(
        lua.load(r#"check_equal({"a", "b", "c"}, {"a", "b", "c"})"#)
            .eval::<bool>()?,
        true
    );
    assert_eq!(
        lua.load(r#"check_equal({"a", "b", "c"}, {"d", "e", "f"})"#)
            .eval::<bool>()?,
        false
    );
    assert_eq!(lua.load(r#"join("a", "b", "c")"#).eval::<String>()?, "abc");

    // Callbacks receive a Lua state as their first parameter so that they can use it to
    // create new Lua values, if necessary.

    let create_table = lua.create_function(|lua, ()| {
        let t = lua.create_table()?;
        t.set(1, 1)?;
        t.set(2, 2)?;
        Ok(t)
    })?;
    globals.set("create_table", create_table)?;

    assert_eq!(lua.load(r#"create_table()[2]"#).eval::<i32>()?, 2);

    // You can create userdata with methods and metamethods defined on them.
    // Here's a worked example that shows many of the features of this API
    // together

    #[derive(Copy, Clone)]
    struct Vec2(f32, f32);

    impl UserData for Vec2 {
        fn add_methods<'lua, M: UserDataMethods<'lua, Self>>(methods: &mut M) {
            methods.add_method("magnitude", |_, vec, ()| {
                let mag_squared = vec.0 * vec.0 + vec.1 * vec.1;
                Ok(mag_squared.sqrt())
            });

            methods.add_meta_function(MetaMethod::Add, |_, (vec1, vec2): (Vec2, Vec2)| {
                Ok(Vec2(vec1.0 + vec2.0, vec1.1 + vec2.1))
            });
        }
    }

    let vec2_constructor = lua.create_function(|_, (x, y): (f32, f32)| Ok(Vec2(x, y)))?;
    globals.set("vec2", vec2_constructor)?;

    assert!(
        (lua.load("(vec2(1, 2) + vec2(2, 2)):magnitude()")
            .eval::<f32>()?
            - 5.0)
            .abs()
            < f32::EPSILON
    );

    // We were able to run our 'sketchy' function inside the scope just fine.  However, if we
    // try to run our 'sketchy' function outside of the scope, the function we created will have
    // been invalidated and we will generate an error.  If our function wasn't invalidated, we
    // might be able to improperly access the freed `rust_val` which would be unsafe.
    assert!(lua.load("sketchy()").exec().is_err());

    Ok(())
}
