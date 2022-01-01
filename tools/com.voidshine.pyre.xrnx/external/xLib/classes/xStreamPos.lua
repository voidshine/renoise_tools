cLib.require(_clibroot.."cObservable")cLib.require(_xlibroot.."xPlayPos")cLib.require(_xlibroot.."xSongPos")cLib.require(_xlibroot.."xBlockLoop")cLib.require(_xlibroot.."xPatternSequencer")class'xStreamPos'xStreamPos.WRITEAHEAD_FACTOR=300;xStreamPos.SCHEDULES={"Line","Beat","Bar","Block","Pattern"}xStreamPos.SCHEDULE={LINE=1,BEAT=2,BAR=3,BLOCK=4,PATTERN=5}function xStreamPos:__init()TRACE("xStreamPos:__init()")self.playpos=xPlayPos()self.pos=rns.transport.playback_pos;self.xinc=0;self.block_enabled=rns.transport.loop_block_enabled;self.block_range_coeff=rns.transport.loop_block_range_coeff;self.just_started_playback=0;self.callback_observable=renoise.Document.ObservableBang()self.refresh_observable=renoise.Document.ObservableBang()renoise.tool().app_new_document_observable:add_notifier(function()TRACE("xStreamPos - app_new_document_observable fired...")rns=renoise.song()self:attach_to_song()end)renoise.tool().app_idle_observable:add_notifier(function()self:update()end)end;function xStreamPos:obtain_restart_pos()TRACE("xStreamPos:obtain_restart_pos()")if rns.transport.loop_block_enabled then return rns.transport.loop_block_start_pos else local a=rns.transport.edit_pos;a.line=1;return a end end;function xStreamPos:start(b)TRACE("xStreamPos:start(playmode)",b)rns.transport:start(b)if b==renoise.Transport.PLAYMODE_RESTART_PATTERN then self.pos=self:obtain_restart_pos()self.callback_observable:bang()self:reset()else self:reset()end;self.just_started_playback=os.clock()end;function xStreamPos:do_callback()TRACE("xStreamPos:do_callback()")if self.just_started_playback==0 then self.callback_observable:bang()end end;function xStreamPos:do_refresh()TRACE("xStreamPos:do_refresh()")if self.just_started_playback==0 then self.refresh_observable:bang()end end;function xStreamPos:reset()TRACE("xStreamPos:reset()")self.playpos=xPlayPos()if rns.transport.playing then self.pos=rns.transport.playback_pos else self.pos=rns.transport.edit_pos end;self.xinc=0 end;function xStreamPos:_increase_by(c)TRACE("xStreamPos:_increase_by(lines)",c)TRACE(">>> self.pos",self.pos)self.pos=xSongPos.increase_by_lines(c,self.pos)self.xinc=self.xinc+c end;function xStreamPos:_set_pos(a)TRACE("xStreamPos:_set_pos(pos)",a)if not self.playpos then self.playpos:set(a)end;local d=xStreamPos.determine_writeahead()local e=function(f)return f<=d and true or false end;local g=function(f,h)return f>=h-d end;local i=function(f)return f<=xBlockLoop.get_start()+d end;local j=function(f)local k=xBlockLoop.get_end()return f>=k-d and f<=k end;if rns.transport.loop_block_enabled then self.xblock=xBlockLoop()end;if a.sequence==self.playpos.sequence then if a.line<self.playpos.line then local l=xPatternSequencer.get_number_of_lines(self.playpos.sequence)if e(a.line)and g(self.playpos.line,l)then local m=l-self.playpos.line+a.line;self:_increase_by(m)elseif rns.transport.loop_block_enabled and i(a.line)and j(self.playpos.line)then local m=self.xblock.end_line-self.playpos.line+a.line-self.xblock.start_line+1;self:_increase_by(m)else local n=self.xinc;self:reset()self.xinc=n;self:do_refresh()end elseif a.line>self.playpos.line then local o=a.line-self.playpos.line;self:_increase_by(o)if o>=d then self:do_refresh()end end elseif a.sequence<self.playpos.sequence then if not rns.sequencer.pattern_sequence[self.playpos.sequence]then self.playpos:set(rns.transport.playback_pos)end;local l=xPatternSequencer.get_number_of_lines(self.playpos.sequence)if self.playpos.line>=l-d then local m=l-self.playpos.line+a.line;self:_increase_by(m)self.pos.sequence=a.sequence else local m=a.line-self.playpos.line;self:_increase_by(m)self.pos.sequence=a.sequence;if not self.pos then self.pos=rns.transport.playback_pos end;self.pos.sequence=a.sequence;self.xinc=self.xinc-d;self:do_refresh()end else local m=xSongPos.get_line_diff(a,self.playpos)self:_increase_by(m)self:do_refresh()end;self:do_callback()self.playpos:set(a)end;function xStreamPos:update()if not rns.transport.playing then return end;local p=rns.transport.playback_pos;if self.just_started_playback>0 then if 0.2>os.clock()-self.just_started_playback then self.just_started_playback=0 end elseif self.just_started_playback==0 then if not xSongPos.equal(p,self.playpos)then self:_set_pos(p)end end end;function xStreamPos:get_scheduled_pos(q)TRACE("xStreamPos:get_scheduled_pos(schedule)",q)local r=rns.transport.playing;local a=xSongPos.create(self.playpos)local s={[xStreamPos.SCHEDULE.LINE]=function()local travelled=0;if r then travelled=1 end;return travelled end,[xStreamPos.SCHEDULE.BEAT]=function()local travelled=travelled+xSongPos.next_beat(a)return travelled end,[xStreamPos.SCHEDULE.BAR]=function()local travelled=xSongPos.next_bar(a)return travelled end}if s[q]then local travelled=s[q]()return a,self.xinc+travelled else error("Unsupported schedule type, please use NONE/BEAT/BAR")end end;function xStreamPos:attach_to_song()TRACE("xStreamPos:attach_to_song()")local t=function()self:update()end;local u=function()if rns.transport.playing then self.just_started_playback=os.clock()self:update()end end;cObservable.attach(rns.selected_pattern_index_observable,t)cObservable.attach(rns.transport.playing_observable,u)end;function xStreamPos.determine_writeahead()TRACE("xStreamPos:determine_writeahead()")local v=rns.transport.bpm;local w=rns.transport.lpb;return math.ceil(math.max(2,v*w/xStreamPos.WRITEAHEAD_FACTOR))end;function xStreamPos:__tostring()return type(self)..", playpos="..tostring(self.playpos)..", pos="..tostring(self.pos)end