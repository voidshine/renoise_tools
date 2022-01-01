class'xParameter'function xParameter.set_value(a,b,c,d,e,f)TRACE("xParameter.set_value(param,val,mode,val_min,val_max,msg_type)",a,b,c,d,e,f)assert(type(a)=="DeviceParameter","Expected param to be an instance of DeviceParameter")assert(type(b)=="number","Expected value to be a number")assert(type(c)=="string","Expected mode to be a string")local g=a.value;local h=nil;if c:find("7")then if not d then d=0 end;if not e then e=127 end;h=a.value_max/127 elseif c:find("14")then if not d then d=0 end;if not e then e=16383 end;h=a.value_max/16383 end;if not c then elseif c:find("abs")then g=cLib.scale_value(b,d,e,0,a.value_max)elseif c:find("rel_7")then local i=b;if c=="rel_7_signed"then if i<64 then i=-i elseif i>64 then i=i-64 else i=0 end elseif c=="rel_7_signed2"then if i>64 then i=-(i-64)elseif i<64 then i=i else i=0 end elseif c=="rel_7_offset"then if i<64 then i=-(64-i)elseif i>64 then i=i-64 else i=0 end elseif c=="rel_7_twos_comp"then if i>64 then i=-(128-i)elseif i<65 then i=i else i=0 end end;if i>0 then g=math.min(g+h*i,a.value_max)elseif i<0 then g=math.max(g-h*math.abs(i),0)end elseif c:find("rel_14")then local i=b;local j,k=xMidiMessage.split_mb(b)if f==xMidiMessage.TYPE.NRPN then if c=="rel_14_msb"then if j==0x7F then i=-(0x80-i)elseif j==0x00 then i=i end elseif c=="rel_14_offset"then if j==0x3F then i=-(0x2000-i)elseif j==0x40 then i=i-0x2000 end elseif c=="rel_14_twos_comp"then if j==0x40 then i=-(i-0x2000)elseif j==0x00 then i=i end end elseif f==xMidiMessage.TYPE.CONTROLLER_CHANGE then if c=="rel_14_msb"then if j==0x7F then i=-(0x4000-i)elseif j==0x00 then i=i end elseif c=="rel_14_offset"then if j==0x3F then i=-(0x2000-i)elseif j==0x40 then i=i-0x2000 end elseif c=="rel_14_twos_comp"then if j==0x40 then i=0x2000-i elseif j==0x00 then i=i end end else error("Expected CONTROLLER_CHANGE or NRPN as message-type")end;if i<0 then g=math.max(g-h*math.abs(i),0)else g=math.min(g+h*i,a.value_max)end end;a.value=g end;function xParameter.increment_value(a,b)TRACE("xParameter.increment_value(param,val)",a,b)assert(type(a)=="DeviceParameter","Expected param to be an instance of DeviceParameter")assert(type(b)=="number","Expected value to be a number")local h=a.value_max/127;a.value=math.min(a.value_max,a.value+h*b)end;function xParameter.decrement_value(a,b)TRACE("xParameter.decrement_value(param,val)",a,b)assert(type(a)=="DeviceParameter","Expected param to be an instance of DeviceParameter")assert(type(b)=="number","Expected value to be a number")local h=a.value_max/127;a.value=math.max(a.value_min,a.value-h*b)end