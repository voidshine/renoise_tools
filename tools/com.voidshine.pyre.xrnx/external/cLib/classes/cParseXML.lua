class'cParseXML'SLAXML=require(_clibroot.."/support/slaxdom/slaxml")SLAXML=require(_clibroot.."/support/slaxdom/slaxdom")function cParseXML.load_and_parse(a)TRACE('cParseXML.load_and_parse(file_path)',a)local b=io.open(a):read('*all')return cParseXML.parse(b)end;function cParseXML.parse(b)TRACE('cParseXML.parse(str_xml)',b)local c=SLAXML:dom(b,{simple=true,stripWhitespace=true})return c end;function cParseXML.get_attribute(c,d)TRACE('cParseXML.get_attribute(doc,attr_name)',c,d)if table.is_empty(c)then return end;if not table.is_empty(c.kids)then for e,f in ipairs(c.kids)do if f.name==d then return f end end end end;function cParseXML.get_node_by_path(c,g)TRACE("cParseXML.get_node_by_path(doc,xpath)",c,g)local h=cString.split(g,"/")local i=c;for e,f in ipairs(h)do i=cParseXML.get_attribute(i,f)end;return i end;function cParseXML.get_node_value(i)TRACE("cParseXML.get_node_value(node)",i)if not i then return end;if i.kids[1]then return i.kids[1].value end end