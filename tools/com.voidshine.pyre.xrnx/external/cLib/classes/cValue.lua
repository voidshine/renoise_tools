class'cValue'function cValue:__init(...)local a=cLib.unpack_args(...)if type(a.value_default)=="nil"and type(a.value)=="nil"then error("cValue needs value_default and/or value to be defined")end;self.value_default=a.value_default or type(a.value)=="boolean"and false or type(a.value)=="string"and""or type(a.value)=="number"and 0;self.value=property(self.get_value,self.set_value)if type(a.value)=="boolean"then self._value=a.value else self._value=a.value or self.value_default end end;function cValue:get_value()return self._value end;function cValue:set_value(b)self._value=b end;function cValue:__call(c)if not c then return self._value else assert(type(c)=="string")return self[c]end end;function cValue:__len()end