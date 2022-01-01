class'xMessage'function xMessage:__init(...)local a=cLib.unpack_args(...)if type(a)~="table"then a={}end;self.timestamp=os.clock()self.values=property(self.get_values,self.set_values)self._values=a.values or{}self.track_index=property(self.get_track_index,self.set_track_index)self._track_index=a.track_index or rns.selected_track_index;self.instrument_index=property(self.get_instrument_index,self.set_instrument_index)self._instrument_index=a.instrument_index or rns.selected_instrument_index;self.note_column_index=property(self.get_note_column_index,self.set_note_column_index)self._note_column_index=a.note_column_index or rns.selected_note_column_index;self.line_index=property(self.get_line_index,self.set_line_index)self._line_index=a.line_index or rns.selected_line_index;self.line_fraction=property(self.get_line_fraction,self.set_line_fraction)self._line_fraction=a.line_fraction or rns.selected_line_index;self.octave=property(self.get_octave,self.set_octave)self._octave=a.octave or rns.transport.octave;self.raw_message=property(self.get_raw_message,self.set_raw_message)self._raw_message=a.raw_message;self._originating_track_index=nil;self._originating_instrument_index=nil;self._originating_octave=nil;self.__def=property(self.get_definition)self._raw_cache=nil end;function xMessage:get_raw_message()return self._raw_message end;function xMessage:set_raw_message(b)self._raw_message=b end;function xMessage:get_values()return self._values end;function xMessage:set_values(b)assert(type(b)=="table","Expected values to be a table")self.values=b end;function xMessage:get_track_index()return self._track_index end;function xMessage:set_track_index(b)assert(type(b)=="number","Expected track_index to be a number")self._track_index=b end;function xMessage:get_instrument_index()return self._instrument_index end;function xMessage:set_instrument_index(b)assert(type(b)=="number","Expected instrument_index to be a number")self._instrument_index=b end;function xMessage:get_note_column_index()return self._note_column_index end;function xMessage:set_note_column_index(b)assert(type(b)=="number","Expected note_column_index to be a number")self._note_column_index=b end;function xMessage:get_line_index()return self._line_index end;function xMessage:set_line_index(b)assert(type(b)=="number","Expected line_index to be a number")self._line_index=b end;function xMessage:get_octave()return self._octave end;function xMessage:set_octave(b)assert(type(b)=="number","Expected octave to be a number")self._octave=b end;function xMessage:create_raw_message()if self._raw_cache then return self._raw_cache else self._raw_cache="hello world!"end end;function xMessage:get_definition()return{values=table.copy(self.values),track_index=self.track_index,instrument_index=self.instrument_index,note_column_index=self.note_column_index,line_index=self.line_index,octave=self.octave,raw_message=self.raw_message,_originating_instrument=self._originating_instrument,_originating_octave=self._originating_octave,_originating_track=self._originating_track}end;function xMessage:__tostring()return type(self)..": "..", timestamp="..tostring(self.timestamp)..", track_index="..tostring(self.track_index)..", instrument_index="..tostring(self.instrument_index)..", note_column_index="..tostring(self.note_column_index)..", line_index="..tostring(self.line_index)..", octave="..tostring(self.octave)..", #values="..tostring(#self.values)end