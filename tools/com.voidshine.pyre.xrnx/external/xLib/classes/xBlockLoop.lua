cLib.require(_xlibroot.."xPatternSequencer")class'xBlockLoop'xBlockLoop.COEFFS_ALL={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}xBlockLoop.COEFFS_FOUR={1,2,4,8,16}xBlockLoop.COEFFS_THREE={1,2,3,6,12}xBlockLoop.COEFF_MODE={ALL=1,FOUR=2,THREE=3}function xBlockLoop:__init(...)local a=cLib.unpack_args(...)self.start_line=a.start_line or nil;self.end_line=a.end_line or nil;self.length=property(self.get_length)if not self.start_line then self.start_line=xBlockLoop.get_start()end;if not self.end_line then self.end_line=xBlockLoop.get_end()end end;function xBlockLoop:get_length()return self.end_line-self.start_line+1 end;function xBlockLoop.get_block_lines(b)TRACE("xBlockLoop.get_block_lines(seq_idx)",b)local c=xPatternSequencer.get_number_of_lines(b)if c then return math.max(1,c/rns.transport.loop_block_range_coeff),c end end;function xBlockLoop.get_block_index(b,d)TRACE("xBlockLoop.get_block_index(seq_idx,line_idx)",b,d)local e,c=xBlockLoop.get_block_lines(b)if e then local f=math.floor(c/e)return math.ceil(d/c*f),c end end;function xBlockLoop.get_start()if not rns.transport.loop_block_enabled then return end;local g=rns.transport.loop_block_start_pos;return g.line end;function xBlockLoop.get_end()if not rns.transport.loop_block_enabled then return end;local g=rns.transport.loop_block_start_pos;if g.sequence>#rns.sequencer.pattern_sequence then LOG("*** xBlockLoop - fixing out-of-bounds value for end sequence",g.sequence,#rns.sequencer.pattern_sequence)g.sequence=#rns.sequencer.pattern_sequence end;local e,c=xBlockLoop.get_block_lines(g.sequence)return math.floor(g.line+e-1),c end;function xBlockLoop.within(b,d,h)assert(type(b),"number")assert(type(d),"number")if not rns.transport.loop_block_enabled then return false end;if rns.transport.loop_block_start_pos.sequence~=b then return false end;local i=h or xBlockLoop.get_end()return d>=rns.transport.loop_block_start_pos.line and d<=i end;function xBlockLoop.exiting(b,d,j,h)assert(type(b),"number")assert(type(d),"number")assert(type(j),"number")local k=false;if rns.transport.loop_block_enabled and rns.transport.loop_block_start_pos.sequence==b then local i=h or xBlockLoop.get_end()local l=xBlockLoop.within(b,d,i)local m=xBlockLoop.within(b,d+j,i)k=l and not m end;return k end;function xBlockLoop.get_previous_line_index()TRACE("xBlockLoop.get_previous_line_index")if rns.transport.loop_block_enabled then local n=rns.transport.loop_block_range_coeff;local o=rns.transport.loop_block_start_pos.line;local c=rns.selected_pattern.number_of_lines;local p=math.floor(c/n)return o-p end end;function xBlockLoop:get_next_line_index()TRACE("xBlockLoop.get_next_line_index")if rns.transport.loop_block_enabled then local n=rns.transport.loop_block_range_coeff;local o=rns.transport.loop_block_start_pos.line;local c=rns.selected_pattern.number_of_lines;local p=math.floor(c/n)return o+p end end;function xBlockLoop.normalize_line_range(q,r,c,s)TRACE("xBlockLoop.normalize_line_range(start_line,end_line,num_lines,coeffs)",q,r,c,s)assert(type(q)=="number")assert(type(r)=="number")assert(type(c)=="number")assert(q~=r,"start_line and end_line needs to be different")if q>r then q,r=r,q end;assert(q>=1,"start_line should be 1 or higher")assert(r<=c,"end_line should be equal to, or less than num_lines")if not s then s=xBlockLoop.COEFFS_ALL end;local t=r-q;local u=math.floor(c/t)local v=nil;local w=false;local x=s[#s]for y,z in ipairs(s)do if z==u then w=true elseif z>u then if math.ceil(u)==z then x=s[y]else x=s[y-1]end;break end end;if not w then v=x else v=u end;t=math.floor(c/v)r=q+t;local A=t==c;if r>c+1 then local B=c-r+1;q=q+B;r=r+B end;return q,r,v,A end