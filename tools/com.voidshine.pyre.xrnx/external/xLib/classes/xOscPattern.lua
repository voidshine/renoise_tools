cLib.require(_xlibroot.."xOscRouter")cLib.require(_xlibroot.."xOscValue")class'xOscPattern'xOscPattern.uid_counter=0;function xOscPattern:__init(...)local a=cLib.unpack_args(...)self.pattern_in=property(self.get_pattern_in,self.set_pattern_in)self.pattern_in_observable=renoise.Document.ObservableString("")self.pattern_out=property(self.get_pattern_out,self.set_pattern_out)self.pattern_out_observable=renoise.Document.ObservableString("")self.complete=property(self.get_complete)self.before_modified_observable=renoise.Document.ObservableBang()self.strict=type(a.strict)~="boolean"and true or a.strict;self.precision=type(a.precision)=="number"and a.precision or 10000;self.uid=nil;xOscPattern.uid_counter=xOscPattern.uid_counter+1;self.uid="uid_"..tostring(xOscPattern.uid_counter)self.cacheable=false;self.arguments={}self.arg_names=property(self.get_arg_names,self.set_arg_names)self._arg_names=renoise.Document.ObservableStringList()self.osc_pattern_in=nil;self.osc_pattern_out=nil;self.output_args=nil;if a.pattern_in then self:set_pattern_in(a.pattern_in)end;if a.pattern_out then self:set_pattern_out(a.pattern_out)end;if a.arg_names then self:set_arg_names(a.arg_names)end end;function xOscPattern:get_pattern_in()return self.pattern_in_observable.value end;function xOscPattern:set_pattern_in(b)local c=b~=self.pattern_in_observable.value and true or false;if c then self.before_modified_observable:bang()end;self.pattern_in_observable.value=b;self:parse_input_pattern()self:parse_output_pattern()end;function xOscPattern:get_pattern_out()return self.pattern_out_observable.value end;function xOscPattern:set_pattern_out(b)local c=b~=self.pattern_out_observable.value and true or false;if c then self.before_modified_observable:bang()end;self.pattern_out_observable.value=b;self:parse_output_pattern()end;function xOscPattern:get_arg_names()local d={}for e,f in ipairs(self.arguments)do table.insert(d,f.name or"")end;return d end;function xOscPattern:set_arg_names(b)for e,f in ipairs(self.arguments)do f.name=b[e]and tostring(b[e])or""end end;function xOscPattern:get_complete()local g=xOscPattern.test_pattern(self.pattern_in)if g and self.pattern_out~=""then g=xOscPattern.test_pattern(self.pattern_out)end;return g end;function xOscPattern:match(h)if not self.osc_pattern_in then return false,"No pattern defined"end;if not(h.pattern==self.osc_pattern_in)then return false,"Pattern didn't match:"..tostring(h.pattern)..","..tostring(self.osc_pattern_in)else if not(#h.arguments==#self.arguments)then return false,"Wrong number of arguments, expected "..tostring(#self.arguments)else for e,f in ipairs(self.arguments)do local i=self.arguments[e]if i.value~=nil then local j=false;local k,l=h.arguments[e].value,i.value;if self.precision and i.tag==xOscValue.TAG.FLOAT then j=cLib.float_compare(k,l,self.precision)else j=k==l end;if not j then return false,"Literal value didn't match:"..tostring(i.value)..","..tostring(h.arguments[e].value)elseif self.strict then if h.arguments[e].tag~=i.tag then return false,"Strict mode: tags didn't match"end end else if i.tag=="n"and(h.arguments[e].tag=="i"or h.arguments[e].tag=="f")then elseif h.arguments[e].tag~=i.tag then return false,"Argument tags didn't match:"..tostring(h.arguments[e].tag)..","..tostring(i.tag)end end end;return true end end end;function xOscPattern:parse_input_pattern()self.arguments={}local m={}local n=string.gmatch(self.pattern_in,"[^%s]+")local o=0;for p,q in n do if o==0 then self.osc_pattern_in=p else if not string.match(p,"^%%%a")then local r,s=self:interpret_literal(p)table.insert(self.arguments,xOscValue{tag=r,value=s})else local t,u,v;local w=string.find(p,":",nil,true)if w then t=string.sub(p,2,w-1)u=string.sub(p,w+1,#p)else t=string.sub(p,2)end;table.insert(self.arguments,xOscValue{tag=t,name=u})end end;o=o+1 end;local x=true;for e,f in ipairs(self.arguments)do if f.tag==xOscValue.TAG.FLOAT or f.tag==xOscValue.TAG.NUMBER then x=false;break end end;self.cacheable=x end;function xOscPattern:parse_output_pattern()local d={}if self.pattern_out==""then self.osc_pattern_out=self.osc_pattern_in;for e,f in ipairs(self.arguments)do table.insert(d,e)end else local n=string.gmatch(self.pattern_out,"[^%s]+")for e,q in n do self.osc_pattern_out=e;break end;local y=string.gmatch(self.pattern_out,"$(%d)")for e,f in y do table.insert(d,tonumber(e))end end;self.output_args=d end;function xOscPattern:purely_literal()if self.arguments==0 then return true end;for e,f in ipairs(self.arguments)do if type(f.value)=="nil"then return false end end;return true end;function xOscPattern:generate(a)if not self.osc_pattern_out then return nil,"Can't generate message without an output pattern"end;a=a or self.arguments;local z={}for e,f in ipairs(self.output_args)do local A=self.arguments[f].tag;local B=a[f]and a[f].value or self.arguments[f].value;if A==xOscValue.TAG.NUMBER then A=self:interpret_literal(tostring(B),true)end;table.insert(z,{tag=A,value=B})end;return renoise.Osc.Message(self.osc_pattern_out,z)end;function xOscPattern:interpret_literal(C,D)local E=tonumber(C)if E then if self.strict or D then if string.find(C,".",nil,true)then return xOscValue.TAG.FLOAT,E else return xOscValue.TAG.INTEGER,E end else return xOscValue.TAG.NUMBER,E end else return xOscValue.TAG.STRING,C end end;function xOscPattern:__tostring()return type(self)..": ".."pattern_in="..self.pattern_in..", pattern_out="..self.pattern_out..", osc_pattern_in="..self.osc_pattern_in..", osc_pattern_out="..self.osc_pattern_out..", strict="..tostring(self.strict)..", precision="..tostring(self.precision)..", uid="..tostring(self.uid)end;function xOscPattern.test_pattern(F)if string.sub(F,0,1)~="/"then return false,"An OSC pattern should start with a forward slash"end;local n=string.gmatch(F,"[^%s]+")local o=0;for p,q in n do if o==0 then else if string.match(p,"^%%%a")then else end end end;return true end;function xOscPattern.types_are_matching(G,H)if not(#G.arguments==#H.arguments)then return false,"Number of arguments does not match:"..tostring(#G.arguments)..","..#H.arguments end;if G.osc_pattern_in~=H.osc_pattern_in then return false,"Pattern does not match:"..tostring(G.osc_pattern_in)..","..H.osc_pattern_in end;for e,f in ipairs(G.arguments)do if not(f.tag==H.arguments[e].tag)then return false,"Tags does not match:"..tostring(f.tag)..","..tostring(H.arguments[e].tag)end end;return true end