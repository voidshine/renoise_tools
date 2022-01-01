cLib.require(_xlibroot.."xMidiMessage")class'xMidiInput'function xMidiInput:__init(...)local a=cLib.unpack_args(...)self.callback_fn=a.callback_fn or nil;self.multibyte_enabled=a.multibyte_enabled or false;self.nrpn_enabled=a.nrpn_enabled or false;self.terminate_nrpns=a.terminate_nrpns or false;self.timeout=a.timeout or 0.1;self._multibyte_exempted={}self._nrpn_msb_only={}self._mb_messages={}self._nrpn_messages={}renoise.tool().app_idle_observable:add_notifier(function()self:on_idle()end)end;function xMidiInput:input(b,c)TRACE("xMidiInput:input(msg,port_name)",b,c)assert(type(b)=="table","Expected MIDI message to be a table")assert(#b==3,"Malformed MIDI message, expected 3 parts")assert(type(c)=="string","Expected port_name to be a string")local d,e,f;local g={0,0}if b[1]>=0x80 and b[1]<=0x9F then g[1]=b[2]g[2]=b[3]if b[1]>0x8F then e=b[1]-0x8F;if b[3]==0 then d=xMidiMessage.TYPE.NOTE_OFF else d=xMidiMessage.TYPE.NOTE_ON end else d=xMidiMessage.TYPE.NOTE_OFF;e=b[1]-0x7F end elseif b[1]>=0xA0 and b[1]<=0xAF then d=xMidiMessage.TYPE.KEY_AFTERTOUCH;e=b[1]-0x9F;g[1]=b[2]g[2]=b[3]elseif b[1]>=0xB0 and b[1]<=0xBF then local h=true;e=b[1]-0xAF;if self.nrpn_enabled and(b[2]==0x63 or not table.is_empty(self._nrpn_messages))then if b[2]==0x63 then local i={timestamp=os.clock(),channel=e,num_msb=b[3],port_name=c}table.insert(self._nrpn_messages,i)return end;for j,k in ripairs(self._nrpn_messages)do if k.channel==e then local l=function(m,i)d=xMidiMessage.TYPE.NRPN;g[1]=xMidiMessage.merge_mb(i.num_msb,i.num_lsb)g[2]=xMidiMessage.merge_mb(i.data_msb,i.data_lsb)f=xMidiMessage.BIT_DEPTH.FOURTEEN;h=false;if self.terminate_nrpns==false then table.remove(self._nrpn_messages,m)return true else return false end end;if k.port_name~=c then else if b[2]==0x62 and not k.num_lsb then k.num_lsb=b[3]return elseif k.num_lsb and not k.data_msb and b[2]==0x06 or b[2]==0x61 or b[2]==0x60 then if b[2]==0x06 then k.data_msb=b[3]local n=self:_create_fingerprint(xMidiMessage.TYPE.NRPN,{{0xAF+e,0x63,k.num_msb},{0xAF+e,0x62,k.num_lsb}})if table.find(self._nrpn_msb_only,n)then k.data_lsb=0x00;if not l(j,k)then return end else return end else local d=nil;if b[2]==0x61 then d=xMidiMessage.TYPE.NRPN_DECREMENT elseif b[2]==0x60 then d=xMidiMessage.TYPE.NRPN_INCREMENT end;self.callback_fn(xMidiMessage{message_type=d,channel=e,values={xMidiMessage.merge_mb(k.num_msb,k.num_lsb),b[3]},bit_depth=xMidiMessage.BIT_DEPTH.SEVEN,port_name=c})return end elseif k.data_msb and b[2]==0x026 then k.data_lsb=b[3]if not l(j,k)then return end elseif k.data_msb and b[2]==0x65 and b[3]==0x7f then return elseif k.data_msb and b[2]==0x64 and b[3]==0x7f then if not k.data_lsb then k.data_lsb=0x00 end;table.remove(self._nrpn_messages,j)d=xMidiMessage.TYPE.NRPN;g[1]=xMidiMessage.merge_mb(k.num_msb,k.num_lsb)g[2]=xMidiMessage.merge_mb(k.data_msb,k.data_lsb)f=xMidiMessage.BIT_DEPTH.FOURTEEN else LOG("*** Received malformed NRPN message...")end end end end elseif self.multibyte_enabled and(b[2]>=0 and b[2]<65)then local n=nil;if b[2]<31 then n=self:_create_fingerprint(xMidiMessage.TYPE.CONTROLLER_CHANGE,{b})if not table.find(self._multibyte_exempted,n)then local o=self._mb_messages[n]if o then self.callback_fn(xMidiMessage{message_type=xMidiMessage.TYPE.CONTROLLER_CHANGE,channel=o.channel,values={o.num,o.msb},bit_depth=xMidiMessage.BIT_DEPTH.SEVEN,port_name=o.port_name})self._mb_messages[n]=nil else self._mb_messages[n]={timestamp=os.clock(),type=xMidiMessage.TYPE.CONTROLLER_CHANGE,channel=e,num=b[2],lsb=nil,msb=b[3],port_name=c}return end else end else n=self:_create_fingerprint(xMidiMessage.TYPE.CONTROLLER_CHANGE,{{b[1],b[2]-32,b[3]}})local o=self._mb_messages[n]if o then if o.port_name~=c then else if o.timestamp<os.clock()-self.timeout then return else o.lsb=b[3]d=xMidiMessage.TYPE.CONTROLLER_CHANGE;g[1]=o.num;g[2]=xMidiMessage.merge_mb(o.msb,o.lsb)self._mb_messages[n]=nil;f=xMidiMessage.BIT_DEPTH.FOURTEEN;h=false end end end end end;if h then d=xMidiMessage.TYPE.CONTROLLER_CHANGE;g[1]=b[2]g[2]=b[3]end elseif b[1]>=0xC0 and b[1]<=0xCF then d=xMidiMessage.TYPE.PROGRAM_CHANGE;e=b[1]-0xBF;g[1]=b[2]elseif b[1]>=0xD0 and b[1]<=0xDF then d=xMidiMessage.TYPE.CH_AFTERTOUCH;e=b[1]-0xCF;g[1]=b[2]elseif b[1]>=0xE0 and b[1]<=0xEF then d=xMidiMessage.TYPE.PITCH_BEND;e=b[1]-0xDF;local n=self:_create_fingerprint(d,{b})if self.multibyte_enabled and b[2]>=0 and b[3]==0 then if b[2]==0 and not self._mb_messages[n]then self._mb_messages[n]={timestamp=os.clock(),channel=e,type=d,lsb=nil,msb=nil,port_name=c}return else local p=self._mb_messages[n]if p then if p.port_name~=c then else if p.timestamp<os.clock()-self.timeout then return end;if not p.msb then p.msb=b[2]return end;p.lsb=b[2]g[1]=xMidiMessage.merge_mb(p.msb,p.lsb)f=xMidiMessage.BIT_DEPTH.FOURTEEN;self._mb_messages[n]=nil end end end else self._mb_messages[n]=nil;g[1]=b[2]g[2]=b[3]end elseif b[1]==0xF1 then d=xMidiMessage.TYPE.MTC_QUARTER_FRAME;g[1]=b[2]elseif b[1]==0xF2 then d=xMidiMessage.TYPE.SONG_POSITION;g[1]=b[2]g[2]=b[3]else LOG("Unrecognized MIDI message: "..cLib.serialize_table(b))end;self.callback_fn(xMidiMessage{message_type=d,channel=e,values=g,bit_depth=f,port_name=c})end;function xMidiInput:_create_fingerprint(d,q)local r=nil;if d==xMidiMessage.TYPE.NRPN then r=string.format("%x,%x,%x,%x,%x,%x",q[1][1],q[1][2],q[1][3],q[2][1],q[2][2],q[2][3])elseif d==xMidiMessage.TYPE.CONTROLLER_CHANGE then r=string.format("%x,%x",q[1][1],q[1][2])elseif d==xMidiMessage.TYPE.PITCH_BEND then r=string.format("%x",q[1][1])end;return r end;function xMidiInput:add_multibyte_exempt(d,s)local n=self:_create_fingerprint(d,s)table.insert(self._multibyte_exempted,n)end;function xMidiInput:on_idle()local t=os.clock()if#self._nrpn_messages>0 then for j,k in ripairs(self._nrpn_messages)do if k and k.timestamp<t-self.timeout/2 then if k.data_msb and not k.data_lsb then self.callback_fn(xMidiMessage{message_type=xMidiMessage.TYPE.NRPN,channel=k.channel,values={xMidiMessage.merge_mb(k.num_msb,k.num_lsb),k.data_msb},bit_depth=xMidiMessage.BIT_DEPTH.SEVEN,port_name=k.port_name})table.remove(self._nrpn_messages,j)elseif k.num_msb and not k.num_lsb then self.callback_fn(xMidiMessage{message_type=xMidiMessage.TYPE.CONTROLLER_CHANGE,channel=k.channel,values={0x63,k.data_msb},bit_depth=xMidiMessage.BIT_DEPTH.SEVEN,port_name=k.port_name})table.remove(self._nrpn_messages,j)else table.remove(self._nrpn_messages,j)end end end end;for j,k in pairs(self._mb_messages)do if k.timestamp<t-self.timeout then local u=table.rcopy(k)self._mb_messages[j]=nil;if k.type==xMidiMessage.TYPE.CONTROLLER_CHANGE then self.callback_fn(xMidiMessage{message_type=xMidiMessage.TYPE.CONTROLLER_CHANGE,channel=u.channel,values={u.num,u.msb},port_name=k.port_name,bit_depth=xMidiMessage.BIT_DEPTH.SEVEN})elseif k.type==xMidiMessage.TYPE.PITCH_BEND then self.callback_fn(xMidiMessage{message_type=k.type,channel=k.channel,values={0,0},bit_depth=xMidiMessage.BIT_DEPTH.SEVEN,port_name=k.port_name})else LOG("*** timed out multibyte message with no handler",k)end end end end