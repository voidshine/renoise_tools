cLib.require(_clibroot.."cPersistence")class'xEnvelope'(cPersistence)xEnvelope.__PERSISTENCE={"points"}function xEnvelope:__init()TRACE("xEnvelope:__init()")self.points={}self.number_of_lines=property(self._get_number_of_lines)end;function xEnvelope:has_points()TRACE("xEnvelope:has_points()")return#self.points>0 end;function xEnvelope:_get_number_of_lines()TRACE("xEnvelope:_get_number_of_lines()")if table.is_empty(self.points)then return 0 end;local a=self.points[#self.points].time;return cLib.round_value(a-1)end;function xEnvelope:__tostring()return type(self)..",#points="..tostring(#self.points)end