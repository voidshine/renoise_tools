class'cBitmap'cBitmap.BIT_COUNT={1,4,8,16,24,32}cBitmap.HEADER_SIZE=54;cBitmap.PIXELS_PER_METER=2834;function cBitmap:__init(...)local a=cLib.unpack_args(...)self.width=a.width or 100;self.height=a.height or 100;self.bit_count=a.bit_count or 24;self.pixels={}self.bitmap={}end;function cBitmap:flood(b)self.pixels={}for c=1,self.height*self.width do self.pixels[c]=b end end;function cBitmap.split_bits(d,e)local f=bit.tohex(d)local g={}local h={tonumber(string.sub(f,1,2),16),tonumber(string.sub(f,3,4),16),tonumber(string.sub(f,5,6),16),tonumber(string.sub(f,7,8),16)}if e then for c,i in ripairs(h)do table.insert(g,i)end else g=h end;return g end;function cBitmap:get_bytes_padding()return self.width%4 end;function cBitmap:get_bitmap_size_in_bytes()local j=self:get_bytes_padding()return self.width*self.height*3+j*self.height+2 end;function cBitmap:get_total_size_in_bytes()return cBitmap.HEADER_SIZE+self:get_bitmap_size_in_bytes()end;function cBitmap:create()self.bitmap={}local k=cBitmap.split_bits(self:get_total_size_in_bytes(),true)local l=cBitmap.split_bits(self:get_bitmap_size_in_bytes(),true)local m=cBitmap.split_bits(self.width,true)local n=cBitmap.split_bits(self.height,true)local o=cBitmap.split_bits(cBitmap.PIXELS_PER_METER,true)self.bitmap[1]='B'self.bitmap[2]='M'for p=3,6 do self.bitmap[p]=k[p-2]end;for p=7,10 do self.bitmap[p]=0 end;self.bitmap[11]=cBitmap.HEADER_SIZE;self.bitmap[12]=0;self.bitmap[13]=0;self.bitmap[14]=0;self.bitmap[15]=40;for p=16,18 do self.bitmap[p]=0 end;for p=19,22 do self.bitmap[p]=m[p-18]end;for p=23,26 do self.bitmap[p]=n[p-22]end;self.bitmap[27]=1;self.bitmap[28]=0;self.bitmap[29]=self.bit_count;self.bitmap[30]=0;for p=31,34 do self.bitmap[p]=0 end;for p=35,38 do self.bitmap[p]=l[p-34]end;for p=39,42 do self.bitmap[p]=o[p-38]end;for p=43,46 do self.bitmap[p]=o[p-42]end;for p=47,50 do self.bitmap[p]=0 end;for p=51,54 do self.bitmap[p]=0 end;local q=self:get_bitmap_size_in_bytes()local j=self:get_bytes_padding()local r=1;local s=1;local t=55;local u=self.width*3+j;for p=55,55+q do if p<t then else local v=0;local w;for r=0,self.width-1 do w=self.pixels[s]if w then local t=p+r*3;self.bitmap[t+0]=w[3]self.bitmap[t+1]=w[2]self.bitmap[t+2]=w[1]v=v+3;s=s+1 end end;if w then if v<u then for x=0,j-1 do local t=p+self.width*3+x;self.bitmap[t]=0 end;v=v+j end end;t=#self.bitmap+1 end end end;function cBitmap:save_bmp(y)TRACE("cBitmap.save_bmp(file_path)",y)local z=io.open(y,'wb')if not z then error("failed to create file handler")end;for c,i in ipairs(self.bitmap)do if type(i)=="string"then z:write(string.char(string.byte(i)))else z:write(string.char(i))end end;z:close()end