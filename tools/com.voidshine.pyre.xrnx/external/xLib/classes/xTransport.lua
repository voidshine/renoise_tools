class'xTransport'xTransport.BPM_MINIMUM=32;xTransport.BPM_MAXIMUM=999;xTransport.LPB_MINIMUM=1;xTransport.LPB_MAXIMUM=256;xTransport.TPL_MINIMUM=1;xTransport.TPL_MAXIMUM=16;function xTransport.forward()local a=rns.transport.playback_pos;a.sequence=a.sequence+1;local b=#rns.sequencer.pattern_sequence;if a.sequence<=b then local c=rns.sequencer.pattern_sequence[a.sequence]local d=rns:pattern(c)if a.line>d.number_of_lines then a.line=1 end;rns.transport.playback_pos=a end end;function xTransport.rewind()local a=rns.transport.playback_pos;a.sequence=a.sequence-1;if a.sequence<1 then a.sequence=1 end;local c=rns.sequencer.pattern_sequence[a.sequence]local d=rns:pattern(c)if a.line>d.number_of_lines then a.line=1 end;rns.transport.playback_pos=a end;function xTransport.pause()rns.transport:stop()end;function xTransport.resume()local e=renoise.Transport.PLAYMODE_CONTINUE_PATTERN;rns.transport:start(e)end;function xTransport.restart()local e=renoise.Transport.PLAYMODE_RESTART_PATTERN;rns.transport:start(e)end;function xTransport.toggle_loop()rns.transport.loop_pattern=not rns.transport.loop_pattern end;function xTransport.toggle_record()rns.transport.edit_mode=not rns.transport.edit_mode end;function xTransport.pattern_is_looped()TRACE("xTransport.pattern_is_looped()")if rns.transport.loop_pattern then return true end;local f=rns.transport.playback_pos.sequence;if rns.transport.loop_sequence_start==f and rns.transport.loop_sequence_end==f then return true end end