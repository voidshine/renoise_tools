cLib.require(_xlibroot.."xMessage")class'xMidiMessage'(xMessage)xMidiMessage.TYPE={SYSEX="sysex",NRPN="nrpn",NRPN_INCREMENT="nrpn_increment",NRPN_DECREMENT="nrpn_decrement",NOTE_ON="note_on",NOTE_OFF="note_off",KEY_AFTERTOUCH="key_aftertouch",CONTROLLER_CHANGE="controller_change",PROGRAM_CHANGE="program_change",CH_AFTERTOUCH="ch_aftertouch",PITCH_BEND="pitch_bend",MTC_QUARTER_FRAME="mtc_quarter_frame",SONG_POSITION="song_position"}xMidiMessage.BIT_DEPTH={SEVEN=7,FOURTEEN=14}xMidiMessage.MODE={ABS="abs",ABS_7="abs_7",ABS_14="abs_14",REL_7_SIGNED="rel_7_signed",REL_7_SIGNED2="rel_7_signed2",REL_7_OFFSET="rel_7_offset",REL_7_TWOS_COMP="rel_7_twos_comp",REL_14_MSB="rel_14_msb",REL_14_OFFSET="rel_14_offset",REL_14_TWOS_COMP="rel_14_twos_comp"}xMidiMessage.VALUE_LABELS={NRPN={"number","value"},NOTE_ON={"note","velocity"},NOTE_OFF={"note","velocity"},KEY_AFTERTOUCH={"note","pressure"},CONTROLLER_CHANGE={"number","value"},PROGRAM_CHANGE={"number","not_used"},CH_AFTERTOUCH={"number","not_used"},PITCH_BEND={"fine","coarse"},SONG_POSITION={"fine","coarse"},MTC_QUARTER_FRAME={"mtc_time_code","not_used"}}xMidiMessage.NRPN_ORDER={MSB_LSB=1,LSB_MSB=2}xMidiMessage.DEFAULT_BIT_DEPTH=xMidiMessage.BIT_DEPTH.SEVEN;xMidiMessage.DEFAULT_CHANNEL=0;xMidiMessage.DEFAULT_PORT_NAME="Unknown port"xMidiMessage.DEFAULT_NRPN_ORDER=xMidiMessage.NRPN_ORDER.MSB_LSB;function xMidiMessage:__init(...)local a=cLib.unpack_args(...)self.message_type=property(self.get_message_type,self.set_message_type)self._message_type=a.message_type or xMidiMessage.TYPE.SYSEX;self.channel=property(self.get_channel,self.set_channel)self._channel=a.channel or xMidiMessage.DEFAULT_CHANNEL;self.bit_depth=property(self.get_bit_depth,self.set_bit_depth)self._bit_depth=a.bit_depth or xMidiMessage.DEFAULT_BIT_DEPTH;self.mode=a.mode;self.port_name=a.port_name or xMidiMessage.DEFAULT_PORT_NAME;self.nrpn_order=a.nrpn_order or xMidiMessage.NRPN_ORDER.MSB_LSB;self.terminate_nrpns=a.terminate_nrpns or xMidiMessage.DEFAULT_NRPN_ORDER;if not self.mode then if self.bit_depth==xMidiMessage.BIT_DEPTH.SEVEN then self.mode=xMidiMessage.MODE.ABS_7 elseif self.bit_depth==xMidiMessage.BIT_DEPTH.FOURTEEN then self.mode=xMidiMessage.MODE.ABS_14 end end;xMessage.__init(self,...)end;function xMidiMessage:get_definition()local b=xMessage.get_definition(self)b.message_type=self.message_type;b.channel=self.channel;b.bit_depth=self.bit_depth;b.port_name=self.port_name;return b end;function xMidiMessage:get_message_type()return self._message_type end;function xMidiMessage:set_message_type(c)self._message_type=c;self._raw_cache=nil end;function xMidiMessage:get_channel()return self._channel end;function xMidiMessage:set_channel(c)assert(c,"No value was provided")assert(c>-1,"Channel needs to be greater than 0")assert(c<16,"Channel needs to 16 or less")self._channel=c;self._raw_midi_cache=nil end;function xMidiMessage:get_bit_depth()return self._bit_depth end;function xMidiMessage:set_bit_depth(c)self._bit_depth=c;self._raw_midi_cache=nil end;function xMidiMessage:create_raw_message()if self._raw_midi_cache then return self._raw_midi_cache else local d={[xMidiMessage.TYPE.NOTE_ON]=function()return{{0x8F+self.channel,self.values[1],self.values[2]}}end,[xMidiMessage.TYPE.NOTE_OFF]=function()return{{0x7F+self.channel,self.values[1],self.values[2]}}end,[xMidiMessage.TYPE.KEY_AFTERTOUCH]=function()return{{0x9F+self.channel,self.values[1],self.values[2]}}end,[xMidiMessage.TYPE.CONTROLLER_CHANGE]=function()if self.bit_depth==xMidiMessage.BIT_DEPTH.SEVEN then return{{0xAF+self.channel,self.values[1],self.values[2]}}elseif self.bit_depth==xMidiMessage.BIT_DEPTH.FOURTEEN then local e,f=self.split_mb(self.values[2])return{{0xAF+self.channel,self.values[1],e},{0xAF+self.channel,self.values[1]+32,f}}else error("Unsupported bit depth")end end,[xMidiMessage.TYPE.PROGRAM_CHANGE]=function()return{{0xBF+self.channel,self.values[1],0}}end,[xMidiMessage.TYPE.CH_AFTERTOUCH]=function()return{{0xCF+self.channel,self.values[1],0}}end,[xMidiMessage.TYPE.PITCH_BEND]=function()if self.bit_depth==xMidiMessage.BIT_DEPTH.SEVEN then return{{0xDF+self.channel,self.values[1],self.values[2]}}elseif self.bit_depth==xMidiMessage.BIT_DEPTH.FOURTEEN then local e,f=self.split_mb(self.values[1])return{{0xDF+self.channel,0,0},{0xDF+self.channel,e,0},{0xDF+self.channel,f,0}}else error("Unsupported bit depth")end end,[xMidiMessage.TYPE.NRPN]=function()local g,h=xMidiMessage.split_mb(self.values[1])local i,j=xMidiMessage.split_mb(self.values[2])local k=self.nrpn_order==xMidiMessage.NRPN_ORDER.MSB_LSB;local l={0xAF+self.channel,0x63,g}local m={0xAF+self.channel,0x62,h}local n={0xAF+self.channel,0x06,i}local o={0xAF+self.channel,0x26,j}local p={k and l or m,k and m or l}if self.bit_depth==xMidiMessage.BIT_DEPTH.SEVEN then table.insert(p,n)else table.insert(p,k and n or o)table.insert(p,k and o or n)end;if self.terminate_nrpns then local q={0xAF+self.channel,0x65,0x7F}local r={0xAF+self.channel,0x64,0x7F}table.insert(p,k and q or r)table.insert(p,k and r or q)end;return p end,[xMidiMessage.TYPE.NRPN_DECREMENT]=function()local g,h=xMidiMessage.split_mb(self.values[1])local i=xMidiMessage.split_mb(self.values[2])return{{{0xAF+self.channel,0x63,g},{0xAF+self.channel,0x62,g},{0xAF+self.channel,0x61,i}}}end,[xMidiMessage.TYPE.NRPN_INCREMENT]=function()local g,h=xMidiMessage.split_mb(self.values[1])local i=xMidiMessage.split_mb(self.values[2])return{{{0xAF+self.channel,0x63,g},{0xAF+self.channel,0x62,g},{0xAF+self.channel,0x60,i}}}end,[xMidiMessage.TYPE.MTC_QUARTER_FRAME]=function()return{{0xF2,self.values[1],0}}end,[xMidiMessage.TYPE.SONG_POSITION]=function()return{{0xF2,self.values[1],self.values[2]}}end,[xMidiMessage.TYPE.SYSEX]=function()local s=table.create()s:insert(0xF0)for t,u in ipairs(self.values)do s:insert(u)end;s:insert(0xF7)return s end}if not d[self.message_type]then error("Cound not convert message, unrecognized type"..tostring(self.message_type))else local v=d[self.message_type]()self._raw_midi_cache=v;return v end end end;function xMidiMessage:__tostring()return type(self)..": message_type="..tostring(self.message_type)..", ch="..tostring(self.channel)..", values[1]="..tostring(self.values[1])..", values[2]="..tostring(self.values[2])..", bits="..tostring(self.bit_depth)..", port="..tostring(self.port_name)..", track="..tostring(self.track_index)..", instr="..tostring(self.instrument_index)..", column="..tostring(self.note_column_index)end;function xMidiMessage.split_mb(c)local e=math.floor(c/0x80)local f=c-e*0x80;return e,f end;function xMidiMessage.merge_mb(e,f)return e*0x80+f end