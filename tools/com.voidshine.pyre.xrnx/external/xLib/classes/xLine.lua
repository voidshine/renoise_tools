cLib.require(_xlibroot.."xLinePattern")cLib.require(_xlibroot.."xLineAutomation")cLib.require(_xlibroot.."xPatternSequencer")class'xLine'xLine.EMPTY_NOTE_COLUMNS={{},{},{},{},{},{},{},{},{},{},{},{}}xLine.EMPTY_EFFECT_COLUMNS={{},{},{},{},{},{},{},{}}xLine.EMPTY_XLINE={note_columns=xLine.EMPTY_NOTE_COLUMNS,effect_columns=xLine.EMPTY_EFFECT_COLUMNS}function xLine:__init(a)self.pattern_line=nil;self.automation=nil;self.note_columns=property(self.get_note_columns)self.effect_columns=property(self.get_effect_columns)self.pattern_line=xLinePattern(a.note_columns,a.effect_columns)if a.automation then self.automation=xLineAutomation(a.automation)end end;function xLine:get_note_columns()return self.pattern_line.note_columns end;function xLine:get_effect_columns()return self.pattern_line.effect_columns end;function xLine:do_write(b,c,d,e,f,g,h,i,j)if self.pattern_line then self.pattern_line.note_columns=self.note_columns;self.pattern_line.effect_columns=self.effect_columns;self.pattern_line:do_write(b,c,d,e,h,i,j)elseif j then self:clear_pattern_line(b,c,d,e)end;if self.automation and f then if type(self.automation)=="table"then self.automation=xLineAutomation(self.automation)end;self.automation:do_write(c,f,g)end end;function xLine:clear_pattern_line(b,c,d,e)local k;if d then k=xLine.resolve_pattern_line(b,c,d)elseif e then k=xLine.resolve_phrase_line(c,e)end;if k then k:clear()end end;function xLine.get_column(c,l,m,n)TRACE("xLine.get_column(line,col_idx,track,visible_only)",c,l,m,n)assert(type(c)=="PatternLine","Expected 'PatternLine' as argument")assert(type(l)=="number","Expected 'col_idx' to be a number")assert(type(m)=="Track"or type(m)=="GroupTrack","Expected 'Track' as argument")if not n then n=true end;if not n then if m.max_note_columns>0 and l<=m.visible_note_columns then return c.note_columns[l]else return c.effect_columns[l]end else local o=nil;if m.max_note_columns>0 and l<=m.visible_note_columns then return c.note_columns[l]elseif l<=m.visible_note_columns+m.visible_effect_columns then return c.effect_columns[l-m.visible_note_columns]else return nil,"Could not resolve column"end end;error("Should not get here")end;function xLine.do_read(b,c,h,d,e)TRACE("xLine.do_read(sequence,line,include_hidden,track_idx,phrase)",b,c,h,d,e)local k,p,q,r,s;if d then k,p,q,r,s=xLine.resolve_pattern_line(b,c,d)elseif e then k=xLine.resolve_phrase_line(c,e)end;if renoise.API_VERSION>3 then assert(type(k)=="PatternLine","Failed to resolve PatternLine")else assert(type(k)=="PatternTrackLine","Failed to resolve PatternLine")end;local t,u,v;if k then local w,x;if not h then if r then w=r.visible_note_columns;x=r.visible_effect_columns elseif e then w=e.visible_note_columns;x=e.visible_effect_columns end else w=renoise.InstrumentPhrase.MAX_NUMBER_OF_NOTE_COLUMNS;x=renoise.InstrumentPhrase.MAX_NUMBER_OF_EFFECT_COLUMNS end;t,u=xLinePattern.do_read(k,w,x)end;return{note_columns=t,effect_columns=u}end;function xLine.resolve_pattern_line(b,c,d)local q,p=xPatternSequencer.get_pattern_at_index(b)local r=rns.tracks[d]assert(q,"The specied track does not exist")local s=q.tracks[d]assert(s,"The specied pattern-track does not exist")local k=s:line(c)assert(k,"The specied pattern-line does not exist")return k,p,q,r,s end;function xLine.resolve_phrase_line(c,e)assert(e,"The specied phrase does not exist")local k=e:line(c)assert(k,"The specied pattern-line does not exist")return k end;function xLine.apply_descriptor(y)if type(y)=="table"then y=xLine(y)elseif type(y)=="xLine"then y.pattern_line:apply_descriptor(y.note_columns,y.effect_columns)if not table.is_empty(y.automation)then y.automation=xLineAutomation(y.automation)end else error("Unexpected xline type")end;return y end;function xLine:__tostring()return type(self)..", line="..tostring(self.pattern_line)..", automation="..tostring(self.automation)end