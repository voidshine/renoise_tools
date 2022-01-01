cLib.require(_xlibroot.."xMessage")cLib.require(_xlibroot.."xOscDevice")class'xOscMessage'(xMessage)function xOscMessage:__init(...)local a=cLib.unpack_args(...)xMessage.__init(self,...)self.device_name=property(self.get_device_name,self.set_device_name)self.device_name_observable=renoise.Document.ObservableString(xOscDevice.DEFAULT_DEVICE_NAME)self.pattern=nil;self.raw_message=nil;if type(a)=="Message"then self.raw_message=a;self._values=table.rcopy(a.arguments)else self.device_name_observable.value=a.device_name and a.device_name or xOscDevice.DEFAULT_DEVICE_NAME;self.raw_message=a.osc_msg;self.pattern=a.pattern end end;function xOscMessage:get_device_name()return self.device_name_observable.value end;function xOscMessage:set_device_name(b)assert(type(b)=="string","Expected device_name to be a string")self.device_name_observable.value=b end;function xOscMessage:create_raw_message()local c=table.rcopy(self.pattern.arguments)for d,e in ipairs(self.values)do if c[d]then c[d].value=e end end;local f=self.pattern:generate(c)return f end;function xOscMessage:get_definition()local g=xMessage.get_definition(self)g.device_name=self.device_name;g.pattern=self.pattern;return g end;function xOscMessage:__tostring()return type(self)..", #values:"..tostring(#self.values)..", device_name:"..tostring(self.device_name)end