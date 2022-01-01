use std::os::raw::{c_char, c_int, c_void};
use crate::ffi;
use crate::lua_State;
use crate::ffi::lua_CFunction;

pub enum LightLuaValue {
    Integer(i64),
    CFunction(lua_CFunction),
}

impl From<i64> for LightLuaValue {
    fn from(v: i64) -> LightLuaValue {
        LightLuaValue::Integer(v)
    }
}

impl From<LightLuaValue> for i64 {
    fn from(v: LightLuaValue) -> i64 {
        match v {
            LightLuaValue::Integer(i) => { i }
            _ => { panic!("wrong type: not i64") }
        }
    }
}

impl From<LightLuaValue> for lua_CFunction {
    fn from(v: LightLuaValue) -> lua_CFunction {
        match v {
            LightLuaValue::CFunction(f) => { f }
            _ => { panic!("wrong type: not lua_CFunction") }
        }
    }
}

pub struct LightLua {
    lua_state: *mut lua_State,
}

impl LightLua {
    pub fn from(lua_state: *mut lua_State) -> Self {
        LightLua { lua_state }
    }

    pub fn do_0_0<F: FnOnce()>(&self, f: F) -> c_int {
        assert_eq!(0, self.top());
        f();
        0
    }

    pub fn do_1_1<P1: From<LightLuaValue>, R1: Into<LightLuaValue>, F: FnOnce(P1) -> R1>(&self, f: F) -> c_int {
        assert_eq!(1, self.top());
        let p1 = self.value_at(1);
        let r1 = f(p1.into());
        self.push_value(r1.into());
        1
    }

    fn top(&self) -> c_int {
        unsafe { ffi::lua_gettop(self.lua_state) }
    }

    pub fn value_at(&self, idx: c_int) -> LightLuaValue {
        unsafe {
            //LightLuaValue::Integer(ffi::lua_tointeger(self.lua_state, idx))
            let typ = ffi::lua_type(self.lua_state, idx);
            println!("lua_type {}", typ);
            match typ {
                ffi::LUA_TFUNCTION => { LightLuaValue::CFunction(ffi::lua_tocfunction(self.lua_state, idx)) }
                _ => { LightLuaValue::Integer(0) }
            }
        }
    }

    pub fn at<T: From<LightLuaValue>>(&self, idx: c_int) -> T {
        self.value_at(idx).into()
    }

    pub fn push<T: Into<LightLuaValue>>(&self, data: T) {
        self.push_value(data.into());
    }

    pub fn push_value(&self, value: LightLuaValue) {
        unsafe { ffi::lua_pushinteger(self.lua_state, value.into()) }
    }

    // Out Stack: [table]
    pub fn push_vec(&self, v: Vec<u8>) {
        unsafe {
            ffi::lua_createtable(self.lua_state, v.len() as c_int, 0);
            for (i, e) in (1..).zip(v) {
                ffi::lua_pushinteger(self.lua_state, i as i64);
                ffi::lua_pushinteger(self.lua_state, e as i64);
                ffi::lua_settable(self.lua_state, -3);
            }
        }
    }

    fn pop(&self, n: c_int) {
        unsafe { ffi::lua_pop(self.lua_state, n) }
    }

    pub fn push_cfunction(&self, f: ffi::lua_CFunction) {
        unsafe {
            ffi::lua_pushcfunction(self.lua_state, f)
        }
    }

    // In Stack:  [table, f1_name, f2_name, f3_name, ...].
    // Out Stack: [table]
    pub fn bind<I>(&self, functions: I) where
        I: DoubleEndedIterator<Item=ffi::lua_CFunction>,
    {
        unsafe {
            for f in functions.rev() {
                ffi::lua_pushcfunction(self.lua_state, f);
                ffi::lua_settable(self.lua_state, 1);
            }
        }
    }
}
