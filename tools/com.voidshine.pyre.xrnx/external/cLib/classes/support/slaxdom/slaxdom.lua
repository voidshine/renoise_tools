function SLAXML:dom(a,b)if not b then b={}end;local c=not b.simple;local d,e=table.insert,table.remove;local f={}local g={type="document",name="#doc",kids={}}local h=g;local i=SLAXML:parser{startElement=function(j,k)local l={type="element",name=j,kids={},el=c and{}or nil,attr={},nsURI=k,parent=c and h or nil}if h==g then if g.root then error(("Encountered element '%s' when the document already has a root '%s' element"):format(j,g.root.name))end;g.root=l end;d(h.kids,l)if h.el then d(h.el,l)end;h=l;d(f,l)end,attribute=function(j,m,k)if not h or h.type~="element"then error(("Encountered an attribute %s=%s but I wasn't inside an element"):format(j,m))end;local n={type='attribute',name=j,nsURI=k,value=m,parent=c and h or nil}if c then h.attr[j]=m end;d(h.attr,n)end,closeElement=function(j)if h.name~=j or h.type~="element"then error(("Received a close element notification for '%s' but was inside a '%s' %s"):format(j,h.name,h.type))end;e(f)h=f[#f]end,text=function(m)if h.type~='document'then if h.type~="element"then error(("Received a text notification '%s' but was inside a %s"):format(m,h.type))end;d(h.kids,{type='text',name='#text',value=m,parent=c and h or nil})end end,comment=function(m)d(h.kids,{type='comment',name='#comment',value=m,parent=c and h or nil})end,pi=function(j,m)d(h.kids,{type='pi',name=j,value=m,parent=c and h or nil})end}i:parse(a,b)return g end;return SLAXML