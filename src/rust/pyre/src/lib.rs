#[macro_use]
extern crate lazy_static;

mod led;
mod prelude;


use std::fs;
use std::ops::DerefMut;
use std::os::raw::c_int;
use std::sync::Mutex;
use std::path::Path;

use mlua::prelude::*;
use mlua::{lua_State, Value};

use crate::prelude::*;
use crate::led::{ LedStateManager, LedRenderModel };
use common::euclid::{point2, size2};
use common::stow::StowPath;
use std::hash::{BuildHasher, Hasher};


struct GlobalState {
    led_state_manager: LedStateManager,
}

impl GlobalState {
    fn new() -> Self {
        Self {
            led_state_manager: LedStateManager::new(),
        }
    }

    fn shutdown(&mut self, lua: &Lua) {
        debug!("pyre shutdown");
    }
}

fn lock_do<F, T>(mut f: F) -> T where F: FnOnce(&mut GlobalState) -> T {
    let mut guard = STATE.lock().expect("mutex lock error");
    f(guard.deref_mut())
}

lazy_static! {
    static ref STATE: Mutex<GlobalState> = Mutex::new(GlobalState::new());
}

// In .lua code, require('pyre') should be called first for common setup; then
// require other modules as needed.
#[no_mangle]
pub extern "C" fn luaopen_pyre(lua_state: *mut mlua::lua_State) -> i32 {
    setup_logger("pyre_log.txt").expect("failed to initialize pyre_log.txt");
    0
}

// fn load_image_sysex_table(lua: &Lua, filename: String) -> LuaResult<Option<LuaTable>> {
//     debug!("load_image_sysex_table");
//     //let sysex = led::load_image_sysex(filename).map_err(mlua::Error::external)?;
//     match led::load_image_sysex(filename) {
//         Ok(sysex) => {
//             let table = lua.create_sequence_from(sysex)?;
//
//             // let now = chrono::Utc::now().to_string();
//             // lua.globals().set(now.as_str(), table.clone())?;
//
//             let key = lua.create_registry_value(table.clone())?;
//             // lua.set_named_registry_value(now.as_str(), table);
//             // let key = lua.create_registry_value(table)?;
//              lock_do(move |state: &mut GlobalState| state.registry_keys.push(key));
//
//             Ok(Some(table))
//             // Ok(Some(lua.named_registry_value(now.as_str())?))
//         }
//         Err(err) => {
//             debug!("Error returned from load_image_sysex: {:?}", err);
//             Ok(None)
//         }
//     }
// }

#[derive(Clone)]
struct ArrayTable(Vec<u8>);

impl LuaUserData for ArrayTable {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_meta_method(LuaMetaMethod::Index, |_, array_table: &ArrayTable, index: usize| -> mlua::Result<LuaValue> {
            // Note: 1-based Lua indexing here.
            if let Some(value) = array_table.0.get(index - 1) {
                Ok(LuaValue::Number(*value as f64))
            } else {
                Ok(LuaNil)
            }
        });
        methods.add_meta_method(LuaMetaMethod::Len, |lua, array_table: &ArrayTable, ()| {
            Ok(array_table.0.len())
        });
    }
}

impl Drop for ArrayTable {
    fn drop(&mut self) {
        // debug!("ArrayTable dropped!");
    }
}

struct LuaRect(ScreenRect);
impl<'lua> FromLua<'lua> for LuaRect {
    fn from_lua(lua_value: Value<'lua>, lua: &'lua Lua) -> LuaResult<Self> {
        if let Value::Table(table) = lua_value {
            Ok(LuaRect(euclid::rect(table.get("left")?, table.get("top")?, table.get("width")?, table.get("height")?)))
        } else {
            Err(LuaError::UserDataTypeMismatch)
        }
    }
}

struct LuaDrawCommand(DrawCommand);
impl<'lua> FromLua<'lua> for LuaDrawCommand {
    fn from_lua(lua_value: Value<'lua>, lua: &'lua Lua) -> LuaResult<Self> {
        if let Value::Table(table) = lua_value {
            let kind: i64 = table.get("kind")?;
            match kind {
                1 => { Ok(LuaDrawCommand(DrawCommand::Clear)) }
                2 => { Ok(LuaDrawCommand(DrawCommand::Box(
                    DrawBox {
                        rect: table.get::<_, LuaRect>("rect")?.0,
                        color: table.get("color")?,
                    }
                ))) }
                3 => { Ok(LuaDrawCommand(DrawCommand::Text(
                    DrawText {
                        font: table.get("font")?,
                        rect: table.get::<_, LuaRect>("rect")?.0,
                        text: table.get("text")?,
                    }
                ))) }
                _ => { Err(LuaError::UserDataTypeMismatch) }
            }
        } else {
            Err(LuaError::UserDataTypeMismatch)
        }
    }
}

fn pyre_led(lua: &Lua) -> LuaResult<LuaTable> {
    // TODO: tables are, seeemingly, unstable in general due to mismatches in the separate lua
    //  implementations, but it seems okay to attach it on the global object so that it only gets
    //  cleaned up all together with the whole.
    let exports = lua.create_table()?;

    exports.set("shutdown", lua.create_function(|lua, ()| Ok(lock_do(move |state| state.shutdown(lua))))?)?;
    exports.set("log", lua.create_function(|_, msg: String| {
        info!("log: {}", msg);
        Ok(())
    })?)?;

    let load_image_sysex = |_, filename: String| {
        // debug!("load_image_sysex");
        Ok(lock_do(|state| {
            match led::load_image_sysex(filename).ok() {
                Some(sysex) => { Some(ArrayTable(sysex.0)) }
                None => { None }
            }
        }))
    };
    exports.set("load_image_sysex", lua.create_function(load_image_sysex)?)?;

    let get_full_led_sysex = |_, fire_index: usize| {
        // debug!("get_full_led_sysex");
        let res = Ok(lock_do(|state| {
            ArrayTable(state.led_state_manager.get_full_sysex(fire_index).0)
        }));
        res
    };
    exports.set("get_full_led_sysex", lua.create_function(get_full_led_sysex)?)?;

    let get_led_update_sysex = |_, (fire_index, led_render_model): (usize, LuaTable)| {
        let lua_draw_commands: Vec<LuaDrawCommand> = led_render_model.get("draw_commands")?;
        let model = LedRenderModel {
            // text: led_render_model.get("text")?,
            draw_commands: lua_draw_commands.into_iter().map(|item| item.0).collect(),
        };
        if model.draw_commands.len() > 1000 {
            panic!("Too many draw commands.");
        }
        //let mut led_state_manager = STATE.led_state_manager.lock().map_err(mlua::Error::external)?;
        //Ok(led_state_manager.get_led_update_sysex(fire_index, model))
        let sysex = lock_do(|state| state.led_state_manager.get_led_update_sysex(fire_index, model));
        Ok(sysex.map(|s| ArrayTable(s.0)))
    };
    exports.set("get_led_update_sysex", lua.create_function(get_led_update_sysex)?)?;

    let get_version = |_, tool_path: String| {
        let mut lua_paths = vec![];
        let dir = Path::new(&tool_path);
        // if let Ok(path) = std::env::current_exe() {
        //     return Ok(path.file_name().unwrap().to_string_lossy().to_ascii_lowercase());
        //     if let Some(dir) = path.parent() {
        let mut paths = vec![dir.to_owned()];
        let mut index = 0;
        while index < paths.len() {
            let dir = &paths[index];
            index += 1;
                if let Ok(dir) = dir.read_dir() {
                    for path in dir.filter_map(|r| r.map(|e| e.path()).ok()) {
                        if path.is_dir() {
                            if paths.len() > 100 {
                                // Don't recurse indefinitely.
                                return Err(mlua::Error::external("get_version given deep root"));
                            }
                            paths.push(path);
                        } else if path.extension() == "lua" {
                            lua_paths.push(path);
                        }
                    }
                }
            // }
        // }
        }
        lua_paths.sort();
        // debug!("{:?}", lua_paths);

        // Note, this implementation may vary across releases, but not within a release,
        //  so it's sufficient for self-consistency check within a specific version.
        let mut hasher = std::collections::hash_map::DefaultHasher::new();
        let mut size = 0;
        for path in lua_paths {
            if let Ok(content) = path.read_to_string() {
                size += content.len();
                hasher.write(content.as_bytes());
            }
        }
        let hash = hasher.finish();
        let version_string = format!("s={},h={}", size, hash & 8191);
        info!("{}", version_string);
        Ok(version_string)
    };
    exports.set("get_version", lua.create_function(get_version)?)?;

    Ok(exports)
}

#[no_mangle]
pub extern "C" fn luaopen_pyre_led(lua_state: *mut mlua::lua_State) -> i32 {
    // Leak the Lua purposefully because it's supposed to live for the duration of the program.
    // In fact, it's owned by Renoise host, so as a client DLL, we can assume it's truly 'static.
    let mut lua = unsafe { Lua::init_from_ptr(lua_state) }.into_static();

    let pyre_led = pyre_led(lua).expect("Failed to create pyre_led module export table");
    lua.globals().set("pyre_led", pyre_led).unwrap();

    0
}
