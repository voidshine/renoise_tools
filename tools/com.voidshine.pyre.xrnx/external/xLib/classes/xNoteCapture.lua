cLib.require(_xlibroot.."xPatternSequencer")class'xNoteCapture'function xNoteCapture.nearest(a,b,c)TRACE("xNoteCapture.nearest(notepos,compare_fn,args)",b,a,c)assert(type(a)=="function")if not b then b=xCursorPos()end;if not c then c={}end;local d,e=b:get_column()if d and d.instrument_value<255 then return b,0 else local f,g=nil,nil;if not c.ignore_previous then f,g=xNoteCapture.previous(a,b)end;if f then return f,g elseif not c.ignore_next then return xNoteCapture.next(a,b)end end end;function xNoteCapture.previous(a,b,h)TRACE("xNoteCapture.previous(compare_fn,notepos,end_seq_idx)",a,b,h)assert(type(a)=="function")if not b then b=xCursorPos()end;local i=xCursorPos(b)local j=false;local g=0;local k=h or 1;i.line=i.line-1;while not j do local l=nil;if i.line>0 then l=xNoteCapture.search_track(i,a,true)end;if l then return l,g+b.line-l.line else i.sequence=i.sequence-1;if i.sequence<k then return end;local m=xPatternSequencer.get_number_of_lines(i.sequence)if m then i.line=m;g=g+m else return end end end end;function xNoteCapture.next(a,b,h)TRACE("xNoteCapture.next(compare_fn,notepos,end_seq_idx)",a,b,h)assert(type(a)=="function")if not b then b=xCursorPos()end;local i=xCursorPos(b)local j=false;local g=0;local n=h or#rns.sequencer.pattern_sequence;i.line=i.line+1;while not j do local l=xNoteCapture.search_track(i,a)if l then return l,g+l.line-b.line else i.sequence=i.sequence+1;if i.sequence>n then return end;local m,o,p=xPatternSequencer.get_number_of_lines(i.sequence)if p then i.line=1;g=g+m else return end end end end;function xNoteCapture.search_track(b,a,q)TRACE("xNoteCapture.search_track(notepos,compare_fn)",b,a)assert(type(a)=="function")local p=xPatternSequencer.get_pattern_at_index(b.sequence)local r=p.tracks[b.track]if r.is_empty then return end;local m=p.number_of_lines;local s,t,u=nil;if q then if 1>m then return end;local v=b.line;local w=r:lines_in_range(1,b.line)for x=b.line,1,-1 do local y=xNoteCapture.compare_line(w,v,x,b,a)if y then return y end;v=v-1 end else if b.line>m then return end;local v=1;local w=r:lines_in_range(b.line,m)for x=b.line,m do local y=xNoteCapture.compare_line(w,v,x,b,a)if y then return y end;v=v+1 end end end;function xNoteCapture.compare_line(w,v,x,b,a)TRACE("xNoteCapture.compare_line(lines,count,line_idx,notepos,compare_fn)",v,x,b,a)local z=w[v]if z then local A=z.note_columns[b.column]if A and a(A)then b=xCursorPos(b)b.line=x;return b end end end