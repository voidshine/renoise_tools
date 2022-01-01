cLib.require(_xlibroot.."xPatternSequencer")cLib.require(_xlibroot.."xBlockLoop")class'xSongPos'xSongPos.OUT_OF_BOUNDS={CAP=1,LOOP=2,NULL=3,ALLOW=4}xSongPos.LOOP_BOUNDARY={HARD=1,SOFT=2,NONE=3}xSongPos.BLOCK_BOUNDARY={HARD=1,SOFT=2,NONE=3}xSongPos.DEFAULT_BOUNDS_MODE=xSongPos.OUT_OF_BOUNDS.LOOP;xSongPos.DEFAULT_LOOP_MODE=xSongPos.LOOP_BOUNDARY.SOFT;xSongPos.DEFAULT_BLOCK_MODE=xSongPos.BLOCK_BOUNDARY.SOFT;xSongPos.BEATS_PER_BAR=nil;xSongPos.LINES_PER_BEAT=nil;function xSongPos.create(a)TRACE("xSongPos.create(pos)",a)local b=rns.transport.playback_pos;b.sequence=a.sequence;b.line=a.line;return b end;function xSongPos.create_from_beats(c,d)TRACE("xSongPos.create_from_beats(beats,args)",c,d)assert(type(c)=="number")d=xSongPos._init_args(d)local e=0;for f=1,#rns.sequencer.pattern_sequence do local g=xPatternSequencer.get_number_of_lines(f)local h=g/d.lines_per_beat;if h+e>c then local i=(c-e)*d.lines_per_beat;return{line=i+1,sequence=f}end;e=e+h end end;function xSongPos.get_number_of_beats(a,d)TRACE("xSongPos.get_number_of_beats(pos,args)",a,d)d=xSongPos._init_args(d)local j=(a.line-1)/d.lines_per_beat;for f=2,a.sequence do local g=xPatternSequencer.get_number_of_lines(f-1)if not g then break end;j=j+g/d.lines_per_beat end;return j end;function xSongPos.get_defaults()TRACE("xSongPos.get_defaults()",xSongPos.BLOCK_BOUNDARY)return{bounds_mode=xSongPos.DEFAULT_BOUNDS_MODE,loop_boundary=xSongPos.DEFAULT_LOOP_MODE,block_boundary=xSongPos.DEFAULT_BLOCK_MODE,beats_per_bar=rns.transport.metronome_beats_per_bar,lines_per_beat=rns.transport.lpb,loop_sequence_range=rns.transport.loop_sequence_range}end;function xSongPos.set_defaults(k)TRACE("xSongPos.set_defaults(val)",k)xSongPos.DEFAULT_BOUNDS_MODE=k.bounds_mode;xSongPos.DEFAULT_LOOP_MODE=k.loop_boundary;xSongPos.DEFAULT_BLOCK_MODE=k.block_boundary end;function xSongPos.apply_to_edit_pos(a)TRACE("xSongPos.apply_to_edit_pos(pos)",a)local l=rns.transport.edit_pos;l.sequence=a.sequence;l.line=a.line;rns.transport.edit_pos=l end;function xSongPos.normalize(a,d)TRACE("xSongPos.normalize(pos,args)",a,d)local f=a.sequence;local m=a.line;local n=cLib.clamp_value(f,1,#rns.sequencer.pattern_sequence)local g=xPatternSequencer.get_number_of_lines(f)if m<1 then return xSongPos.decrease_by_lines(m-g,a,d)elseif m>g then local o={sequence=a.sequence,line=g}return xSongPos.increase_by_lines(m-g,o,d)else return xSongPos.create(a)end end;function xSongPos.increase_by_lines(p,a,d)TRACE("xSongPos.increase_by_lines(num_lines,pos,args)",p,a,d)assert(type(p)=="number")if p==0 then return xSongPos.create(a)end;d=xSongPos._init_args(d)local q=false;local f=a.sequence;local m=a.line;local r=false;if rns.transport.loop_block_enabled and d.block_boundary~=xSongPos.BLOCK_BOUNDARY.NONE then r=xBlockLoop.exiting(f,m,p)or false end;local g=xPatternSequencer.get_number_of_lines(f)if m+p<=g or r then return{sequence=f,line=xSongPos.enforce_block_boundary({sequence=f,line=m},p,d.block_boundary)}else local s=p-(g-m)while s>0 do f=f+1;f,m,q=xSongPos.enforce_boundary("increase",{sequence=f,line=s},d)if q then if not f then if d.bounds_mode==xSongPos.OUT_OF_BOUNDS.NULL then return else error("*** not supposed to get here")end elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.CAP then return{sequence=f,line=m}elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.ALLOW then return{sequence=f,line=a.line+s}end;break end;g=xPatternSequencer.get_number_of_lines(f)s=s-g;if s<0 then m=s+g;break end end;return{sequence=f,line=m}end;error("*** not supposed to get here")end;function xSongPos.decrease_by_lines(p,a,d)TRACE("xSongPos.decrease_by_lines(num_lines,pos,args)",p,a,d)assert(type(p)=="number")if p==0 then return xSongPos.create(a)end;d=xSongPos._init_args(d)local q=false;local f=a.sequence;local m=a.line;local r=d.block_boundary~=xSongPos.BLOCK_BOUNDARY.NONE and xBlockLoop.exiting(f,m,-p)or false;if a.line-p>0 or r then return{sequence=f,line=xSongPos.enforce_block_boundary({sequence=f,line=a.line},-p,d.block_boundary)}else local g=xPatternSequencer.get_number_of_lines(f)local s=p-m;local t=true;while t or s>0 do t=false;f=f-1;f,m,q=xSongPos.enforce_boundary("decrease",{sequence=f,line=s},d)if q then if not f and d.bounds_mode==xSongPos.OUT_OF_BOUNDS.NULL then return elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.CAP then return{sequence=f,line=m}elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.ALLOW then return{sequence=f,line=-s}end;break end;g=xPatternSequencer.get_number_of_lines(f)s=s-g;if s<=0 then m=-s;if m<1 then local o={sequence=f,line=m}xSongPos.decrease_by_lines(1,o,d)f=o.sequence;m=o.line end;break end end;return{sequence=f,line=m}end end;function xSongPos.next_beat(a,d)TRACE("xSongPos.next_beat(pos,args)",a,d)d=xSongPos._init_args(d)local u=math.floor(xSongPos.get_number_of_beats(a))+1;local o=xSongPos.create_from_beats(u)if o then local v=xSongPos.get_line_diff(a,o)return xSongPos.increase_by_lines(v,a,d),v else if d.bounds_mode==xSongPos.OUT_OF_BOUNDS.LOOP then local v=xSongPos.get_line_diff(a,{line=1,sequence=1})return xSongPos.decrease_by_lines(v,a,d),v elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.CAP then elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.ALLOW then elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.NULL then return end end end;function xSongPos.previous_beat(a,d)TRACE("xSongPos.previous_beat(pos,args)",a,d)d=xSongPos._init_args(d)local u=xSongPos.get_number_of_beats(a)local w=nil;if cLib.fraction(u)==0 then w=u-1 else w=math.floor(u)end;local o=xSongPos.create_from_beats(w)if w>=0 then local v=xSongPos.get_line_diff(a,o)return xSongPos.decrease_by_lines(v,a,d),v else if d.bounds_mode==xSongPos.OUT_OF_BOUNDS.LOOP then local x=#rns.sequencer.pattern_sequence;local g=xPatternSequencer.get_number_of_lines(x)local o={sequence=x,line=g}return xSongPos.previous_beat(o,d)elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.CAP then local o={sequence=1,line=1}local v=xSongPos.get_line_diff(a,o)return o,v elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.ALLOW then local v=xSongPos.get_line_diff(a,o)return o,v elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.NULL then return end end end;function xSongPos.next_bar(a,d)TRACE("xSongPos.next_bar(pos,args)",a,d)d=xSongPos._init_args(d)local y=math.floor(xSongPos.get_number_of_beats(a)/d.beats_per_bar)+1;local o=xSongPos.create_from_beats(y*d.beats_per_bar)if o then local v=xSongPos.get_line_diff(a,o)return xSongPos.increase_by_lines(v,a,d),v else if d.bounds_mode==xSongPos.OUT_OF_BOUNDS.LOOP then local z=xSongPos.get_last_line_in_song()local v=1+xSongPos.get_line_diff(a,z)return{line=1,sequence=1},v elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.CAP then local z=xSongPos.get_last_line_in_song()local v=xSongPos.get_line_diff(a,z)return z,v elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.ALLOW then elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.NULL then return end end end;function xSongPos.previous_bar(a,d)TRACE("xSongPos.previous_bar(pos,args)",a,d)d=xSongPos._init_args(d)local y=xSongPos.get_number_of_beats(a)/d.beats_per_bar;local A=nil;if cLib.fraction(y)==0 then A=y-1 else A=math.floor(y)end;local o=xSongPos.create_from_beats(A*d.beats_per_bar)if A>=0 then local v=xSongPos.get_line_diff(a,o)return xSongPos.decrease_by_lines(v,a,d),v else if d.bounds_mode==xSongPos.OUT_OF_BOUNDS.LOOP then local x=#rns.sequencer.pattern_sequence;local g=xPatternSequencer.get_number_of_lines(x)local o={sequence=x,line=g}return xSongPos.previous_bar(o,d)elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.CAP then local o={sequence=1,line=1}local v=xSongPos.get_line_diff(a,o)return o,v elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.ALLOW then local v=xSongPos.get_line_diff(a,o)return o,v elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.NULL then return end end end;function xSongPos.next_block(a,d)TRACE("xSongPos.next_block(pos,args)",a,d)d=xSongPos._init_args(d)local B=xBlockLoop.get_block_lines(a.sequence)local C=math.ceil(a.line/B)local D=1+C*B;local v=D-a.line;local o=xSongPos.increase_by_lines(v,a,d)if o and xSongPos.less_than(o,a)then v=1+xSongPos.get_line_diff(a,xSongPos.get_last_line_in_song())elseif o and xSongPos.equal(a,o)then v=0 end;if o then return o,v end end;function xSongPos.previous_block(a,d)TRACE("xSongPos.previous_block(pos,args)",a,d)d=xSongPos._init_args(d)local B=xBlockLoop.get_block_lines(a.sequence)local E=math.ceil(a.line/B)-1;local i=1+E*B;local o,v;if i==a.line then v=B else v=a.line-i end;local F={}if not(d.bounds_mode==xSongPos.OUT_OF_BOUNDS.ALLOW)then F={bounds_mode=xSongPos.OUT_OF_BOUNDS.NULL}else F=d end;o=xSongPos.decrease_by_lines(v,a,F)if not o then if d.bounds_mode==xSongPos.OUT_OF_BOUNDS.LOOP then local G;o,G=xSongPos.get_last_block_in_song()local v=1+a.line+G;return o,v elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.CAP then return{sequence=1,line=1},a.line-1 end else return o,v end end;function xSongPos.next_pattern(a,d)TRACE("xSongPos.next_pattern(pos,args)",a,d)d=xSongPos._init_args(d)local g=xPatternSequencer.get_number_of_lines(a.sequence)local D=1+g;local v=D-a.line;local o=xSongPos.increase_by_lines(v,a,d)if o and xSongPos.less_than(o,a)then v=1+xSongPos.get_line_diff(a,xSongPos.get_last_line_in_song())elseif o and xSongPos.equal(a,o)then v=0 end;if o then return o,v end end;function xSongPos.previous_pattern(a,d)TRACE("xSongPos.previous_pattern(pos,args)",a,d)d=xSongPos._init_args(d)local i=a.line;if a.line==1 then local g=xPatternSequencer.get_number_of_lines(a.sequence-1)if g then i=i+g elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.LOOP then local g=xPatternSequencer.get_number_of_lines(#rns.sequencer.pattern_sequence)i=i+g end;return xSongPos.decrease_by_lines(i-a.line,a,d)else return xSongPos.decrease_by_lines(a.line-1,a,d)end end;function xSongPos.enforce_boundary(H,a,d)TRACE("xSongPos.enforce_boundary(direction,pos,args)",H,a,d)assert(type(H)=="string")d=xSongPos._init_args(d)local f=a.sequence;local m=a.line;if d.loop_boundary~=xSongPos.LOOP_BOUNDARY.NONE then local I,J;if rns.transport.loop_pattern then local K=rns.transport.playing and rns.transport.playback_pos or rns.transport.edit_pos;I=K.sequence;J=K.sequence else I=d.loop_sequence_range[1]J=d.loop_sequence_range[2]end;if I and I~=0 then local L=d.loop_boundary==xSongPos.LOOP_BOUNDARY.HARD;if H=="increase"then if L then if f>J or f<I then return I,m,false end end elseif H=="decrease"then if L then if f>J or f<I then return J,m,false end end end end end;local q=false;if not xSongPos.within_bounds(a)then if H=="increase"then if d.bounds_mode==xSongPos.OUT_OF_BOUNDS.CAP then f=#rns.sequencer.pattern_sequence;local g=xPatternSequencer.get_number_of_lines(f)m=g;q=true elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.ALLOW then f=#rns.sequencer.pattern_sequence;m=nil;q=true elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.LOOP then f=1 elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.NULL then f=nil;m=nil;q=true end elseif H=="decrease"then if d.bounds_mode==xSongPos.OUT_OF_BOUNDS.CAP then f=1;m=1;q=true elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.ALLOW then f=1;m=nil;q=true elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.LOOP then f=#rns.sequencer.pattern_sequence;local M=xPatternSequencer.get_number_of_lines(f)m=M-m elseif d.bounds_mode==xSongPos.OUT_OF_BOUNDS.NULL then f=nil;m=nil;q=true end end end;return f,m,q end;function xSongPos.enforce_block_boundary(a,N,O)TRACE("xSongPos.enforce_block_boundary(pos,line_delta,boundary)",a,N,O)assert(type(N)=="number")if N==0 then return a.line end;if not O then O=xSongPos.DEFAULT_BLOCK_MODE end;if rns.transport.loop_block_enabled then if O==xSongPos.BLOCK_BOUNDARY.NONE then return a.line+N end;local P=rns.transport.loop_block_start_pos;if a.sequence~=P.sequence then return a.line+N end;local Q=xBlockLoop.get_end()local L=O==xSongPos.BLOCK_BOUNDARY.HARD;local R=xBlockLoop.within(P.sequence,a.line,Q)local S=xBlockLoop.within(P.sequence,a.line+N,Q)if N>0 then if L and not R then return rns.transport.loop_block_start_pos.line end;if R and not S then return-1+P.line+a.line+N-Q end else if L and not R then return Q end;if R and not S then return 1+Q+a.line+N-rns.transport.loop_block_start_pos.line end end end;return a.line+N end;function xSongPos.within_bounds(a)if not xPatternSequencer.within_bounds(a.sequence)then return false elseif a.sequence<1 or a.sequence==1 and a.line<1 then return false else local T=#rns.sequencer.pattern_sequence;if a.sequence==T then local p=xPatternSequencer.get_number_of_lines(T)if a.line>p then return false end end end;return true end;function xSongPos.get_last_line_in_song()TRACE("xSongPos.get_last_line_in_song()")local x=#rns.sequencer.pattern_sequence;return{sequence=x,line=xPatternSequencer.get_number_of_lines(x)}end;function xSongPos.get_last_block_in_song()local x=#rns.sequencer.pattern_sequence;local o={sequence=x,line=xPatternSequencer.get_number_of_lines(x)}return xSongPos.previous_block(o)end;function xSongPos.get_line_diff(U,V)TRACE("xSongPos.get_line_diff(pos1,pos2)",U,V)local p=0;if xSongPos.equal(U,V)then return p end;local W,X;if not xSongPos.less_than(U,V)then W,X=V,U else W,X=U,V end;if U.sequence==V.sequence then return X.line-W.line else for f=W.sequence,X.sequence do local g=xPatternSequencer.get_number_of_lines(f)if f==W.sequence then p=p+g-W.line elseif f==X.sequence then p=p+X.line else p=p+g end end;return p end end;function xSongPos.less_than(U,V)if U.sequence==V.sequence then return U.line<V.line else return U.sequence<V.sequence end end;function xSongPos.equal(U,V)if U.sequence==V.sequence and U.line==V.line then return true else return false end end;function xSongPos.less_than_or_equal(U,V)if U.sequence==V.sequence then if U.line==V.line then return true else return U.line<V.line end else return U.sequence<V.sequence end end;function xSongPos._init_args(d)if not d then return xSongPos.get_defaults()end;if not d.bounds_mode then d.bounds_mode=xSongPos.DEFAULT_BOUNDS_MODE end;if not d.loop_boundary then d.loop_boundary=xSongPos.DEFAULT_LOOP_MODE end;if not d.block_boundary then d.block_boundary=xSongPos.DEFAULT_BLOCK_MODE end;if not d.beats_per_bar then d.beats_per_bar=rns.transport.metronome_beats_per_bar end;if not d.lines_per_beat then d.lines_per_beat=rns.transport.lpb end;if not d.loop_sequence_range then d.loop_sequence_range=rns.transport.loop_sequence_range end;return d end