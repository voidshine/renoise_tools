cLib.require(_xlibroot.."xValue")class'xOscValue'(xValue)xOscValue.TAG={FLOAT="f",INTEGER="i",STRING="s",NUMBER="n"}function xOscValue:__init(...)xValue.__init(self,...)local a=cLib.unpack_args(...)self.tag=property(self.get_tag,self.set_tag)self.tag_observable=renoise.Document.ObservableString(a.tag or"")end;function xOscValue:get_tag()return self.tag_observable.value end;function xOscValue:set_tag(b)assert(table.find(xOscValue.TAG,b)~=nil,"Expected tag to be one of xOscValue.TAG")self.tag_observable.value=b end;function xOscValue:__tostring()local c=xValue.__tostring(self)return type(self)..string.sub(c,17)..", tag="..tostring(self.tag)end