--[[===============================================================================================
xStream
===============================================================================================]]--

--[[--

This class can track playback progression in a song.

#

## How to use

Create an instance, and supply it with a steady flow of song-position changes (idle loop). 

]]

--=================================================================================================

cLib.require(_clibroot.."cObservable")
cLib.require(_xlibroot.."xPlayPos")
cLib.require(_xlibroot.."xSongPos")
cLib.require(_xlibroot.."xBlockLoop")
cLib.require(_xlibroot.."xPatternSequencer")

---------------------------------------------------------------------------------------------------

class 'xStreamPos'

xStreamPos.WRITEAHEAD_FACTOR = 300

-- scheduling 
xStreamPos.SCHEDULES = {"Line","Beat","Bar","Block","Pattern"}
xStreamPos.SCHEDULE = {
  LINE = 1,
  BEAT = 2,
  BAR = 3,
  BLOCK = 4,
  PATTERN = 5,
}

---------------------------------------------------------------------------------------------------
-- [Constructor] does not accept any arguments

function xStreamPos:__init()
  TRACE("xStreamPos:__init()")

  --- (xPlayPos) precise playback position
  self.playpos = xPlayPos()

  --- (SongPos) the current stream position 
  self.pos = rns.transport.playback_pos

  --- number, represents the total number of lines since streaming started
  self.xinc = 0

  --- bool, track changes to loop_block_enabled
  -- TODO refactor into xBlockloop
  self.block_enabled = rns.transport.loop_block_enabled
  --self.block_start_pos = rns.transport.loop_block_start_pos
  self.block_range_coeff = rns.transport.loop_block_range_coeff

  --- number, 0 for 'false'
  -- this is a short-lived timestamp indicating that we should ignore 
  -- changes to the playback position, right after playback has started
  -- (the fuzziness is due to API living in separate thread)
  self.just_started_playback = 0

  --- ObservableBang, fired when it's time for output
  self.callback_observable = renoise.Document.ObservableBang()

  --- ObservableBang, fired when we need fresh content
  -- (i.e. when the position has been changed by the user, and 
  -- previously produced content no longer would be valid...)
  self.refresh_observable = renoise.Document.ObservableBang()

  --== notifiers ==--

  renoise.tool().app_new_document_observable:add_notifier(function()
    TRACE("xStreamPos - app_new_document_observable fired...")
    rns = renoise.song()
    self:attach_to_song()
  end)

  renoise.tool().app_idle_observable:add_notifier(function()    
    self:update()
  end)
  

end

---------------------------------------------------------------------------------------------------
-- [Class] If playmode is 'restart', figure out the actual start position 
-- (depends on whether block-loop is enabled)

function xStreamPos:obtain_restart_pos()
  TRACE("xStreamPos:obtain_restart_pos()")

  if (rns.transport.loop_block_enabled) then 
    return rns.transport.loop_block_start_pos
  else 
    local pos = rns.transport.edit_pos
    pos.line = 1 -- start of pattern 
    return pos
  end

end

---------------------------------------------------------------------------------------------------
-- [Class] Start streaming - preferable to calling renoise transport.start(),
-- as this method will allow us to write AND playback the initial line 
-- @param playmode, renoise.Transport.PLAYMODE_xx

function xStreamPos:start(playmode)
  TRACE("xStreamPos:start(playmode)",playmode)

  rns.transport:start(playmode)

  if (playmode == renoise.Transport.PLAYMODE_RESTART_PATTERN) then 
    -- do a quick output before the *actual* streaming starts 
    self.pos = self:obtain_restart_pos()
    self.callback_observable:bang()
    self:reset()
  else 
    self:reset()  
  end 

  -- prevent immediate output 
  self.just_started_playback = os.clock()

end

---------------------------------------------------------------------------------------------------
-- [Class] invoke the callback method 

function xStreamPos:do_callback()
  TRACE("xStreamPos:do_callback()")

  if (self.just_started_playback == 0) then
    self.callback_observable:bang()
  end

end

---------------------------------------------------------------------------------------------------
-- [Class] invoke the refresh method 

function xStreamPos:do_refresh()
  TRACE("xStreamPos:do_refresh()")

  if (self.just_started_playback == 0) then
    self.refresh_observable:bang()
  end

end

---------------------------------------------------------------------------------------------------
-- [Class] Initialize position - 
-- also called when current position is deemed unreliable due to 'crazy navigation' 

function xStreamPos:reset()
  TRACE("xStreamPos:reset()")

  self.playpos = xPlayPos()
  if rns.transport.playing then
    self.pos = rns.transport.playback_pos
  else
    self.pos = rns.transport.edit_pos
  end
  self.xinc = 0

end

---------------------------------------------------------------------------------------------------

function xStreamPos:_increase_by(lines)
  TRACE("xStreamPos:_increase_by(lines)",lines)
  TRACE(">>> self.pos",self.pos)
  self.pos = xSongPos.increase_by_lines(lines,self.pos)
  self.xinc = self.xinc + lines
end 

---------------------------------------------------------------------------------------------------
-- [Class] Update the stream-position as a result of a changed playback position.
-- Most of the time the stream progresses smoothly forward - however, we also look for 
-- 'user events', changes which can cause the position to jump anywhere... 
-- @param pos (renoise.SongPos), the current playback position

function xStreamPos:_set_pos(pos)
  TRACE("xStreamPos:_set_pos(pos)",pos)

  --print("xStreamPos:_set_pos - seq/line:",pos)

  if not self.playpos then
    self.playpos:set(pos)
  end

  local writeahead = xStreamPos.determine_writeahead()

  local near_patt_top = function(line)
    return (line <= writeahead) and true or false
  end
  local near_patt_end = function(line,patt_lines)
    return (line >= (patt_lines-writeahead))
  end

  local near_block_top = function(line)
    return (line <= xBlockLoop.get_start()+writeahead) 
  end
  local near_block_end = function(line)
    local block_end = xBlockLoop.get_end()
    return (line >= block_end-writeahead)
      and (line <= block_end) -- not beyond 
  end

  if rns.transport.loop_block_enabled then
    self.xblock = xBlockLoop()
  end

  if (pos.sequence == self.playpos.sequence) then
    -- within same pattern
    if (pos.line < self.playpos.line) then
      -- move to earlier position 
      local patt_num_lines = xPatternSequencer.get_number_of_lines(self.playpos.sequence)
      if near_patt_top(pos.line) 
        and near_patt_end(self.playpos.line,patt_num_lines) 
      then
        --print("xStreamPos:_set_pos - pattern loop")
        local num_lines = (patt_num_lines-self.playpos.line) + pos.line
        self:_increase_by(num_lines)
      elseif rns.transport.loop_block_enabled 
        and near_block_top(pos.line)  
        and near_block_end(self.playpos.line) 
      then 
        --print("xStreamPos:_set_pos - block loop (enabled)")
        --print("xStreamPos:_set_pos - self.playpos.line",self.playpos.line)
        local num_lines = (self.xblock.end_line-self.playpos.line) + (pos.line-self.xblock.start_line) + 1
        self:_increase_by(num_lines)
      --elseif not rns.transport.loop_block_enabled 
      --  and near_block_end(self.playpos.line)  
      --then 
      --print(">>> conclusion: block loop (disabled)")
      else
        --print("xStreamPos:_set_pos - 'crazy navigation'")
        local xinc = self.xinc
        --local line_diff = self.playpos.line - pos.line
        self:reset()
        self.xinc = xinc
        self:do_refresh()
      end

    elseif (pos.line > self.playpos.line) then

      -- forward progression through pattern - 
      -- figure out how many lines we have progressed
      local line_diff = pos.line - self.playpos.line

      -- always update write-pos 
      self:_increase_by(line_diff)

      -- more than writeahead indicates gaps or forward navigation 
      -- (such as when pressing page down...)
      if (line_diff >= writeahead) then
        --print("xStreamPos:_set_pos - forward navigation - line_diff",line_diff)
        self:do_refresh()
      end

    end
  elseif (pos.sequence < self.playpos.sequence) then
    --print("xStreamPos:_set_pos - earlier pattern, usually caused by seq-loop or song boundary")
    -- special case: if the pattern was deleted from the song, the cached
    -- playpos is referring to a non-existing pattern - in such a case,
    -- we re-initialize the cached playpos to the current position
    if not rns.sequencer.pattern_sequence[self.playpos.sequence] then
      self.playpos:set(rns.transport.playback_pos)
    end

    local patt_num_lines = xPatternSequencer.get_number_of_lines(self.playpos.sequence)
    -- the old position is near the end of the pattern
    -- use the writeahead as the basis for this calculation
    if (self.playpos.line >= (patt_num_lines-writeahead)) then
      --("xStreamPos:_set_pos - reached the end of the former pattern ")
      -- difference is the remaning lines in old position plus the current line 
      local num_lines = (patt_num_lines-self.playpos.line)+pos.line
      self:_increase_by(num_lines)
      self.pos.sequence = pos.sequence
    else
      --print("xStreamPos:_set_pos - changed the position manually, somehow")
      -- disregard the sequence and just use the lines
      local num_lines = pos.line-self.playpos.line
      self:_increase_by(num_lines)
      self.pos.sequence = pos.sequence
      if not self.pos then
        -- ?? why does this happen 
        self.pos = rns.transport.playback_pos
      end
      self.pos.sequence = pos.sequence
      self.xinc = self.xinc-writeahead
      self:do_refresh()
    end

  else
    -- later pattern
    local num_lines = xSongPos.get_line_diff(pos,self.playpos)
    self:_increase_by(num_lines)
    self:do_refresh()
    
  end
  
  --print(">>> set pos POST",pos)
  
  self:do_callback()

  self.playpos:set(pos)

end

---------------------------------------------------------------------------------------------------
-- [Class] This function is designed to be called in an idle loop

function xStreamPos:update()
  --TRACE("xStreamPos:update()")

  if not rns.transport.playing then
    return
  end 

  local playpos = rns.transport.playback_pos
  if (self.just_started_playback > 0) then
    if (0.2 > (os.clock() - self.just_started_playback)) then
      self.just_started_playback = 0
    end
  elseif (self.just_started_playback == 0) then
    if not xSongPos.equal(playpos,self.playpos) then
      self:_set_pos(playpos)
    end
  end

end

-------------------------------------------------------------------------------
-- return a buffer position which correspond to the desired schedule
-- @param schedule, xStreamPos.SCHEDULE
-- @return SongPos,int (lines travelled)  

function xStreamPos:get_scheduled_pos(schedule)
  TRACE("xStreamPos:get_scheduled_pos(schedule)",schedule)

  local live_mode = rns.transport.playing
  local pos = xSongPos.create(self.playpos)

  local schedules = {
    [xStreamPos.SCHEDULE.LINE] = function()
      local travelled = 0
      if live_mode then
        travelled = 1
      end
      return travelled
    end,
    [xStreamPos.SCHEDULE.BEAT] = function()
      local travelled = travelled + xSongPos.next_beat(pos)
      return travelled
    end,
    [xStreamPos.SCHEDULE.BAR] = function()
      local travelled = xSongPos.next_bar(pos)
      return travelled
    end,
  }

  if schedules[schedule] then
    local travelled = schedules[schedule]()
    return pos, self.xinc + travelled
  else
    error("Unsupported schedule type, please use NONE/BEAT/BAR")
  end

end


---------------------------------------------------------------------------------------------------
-- [Class] Call when a new document becomes available

function xStreamPos:attach_to_song()
  TRACE("xStreamPos:attach_to_song()")

  -- handling changes via observable is quicker than idle notifier
  local pattern_notifier = function()
    self:update()
  end  

  -- track when song is started and stopped
  local playing_notifier = function()
    if rns.transport.playing then
      self.just_started_playback = os.clock()
      self:update()
    end
  end

  cObservable.attach(rns.selected_pattern_index_observable,pattern_notifier)
  cObservable.attach(rns.transport.playing_observable,playing_notifier)

end

---------------------------------------------------------------------------------------------------
-- [Class] Decide the writeahead amount, depending on the song tempo

function xStreamPos.determine_writeahead()
  TRACE("xStreamPos:determine_writeahead()")

  local bpm = rns.transport.bpm
  local lpb = rns.transport.lpb
  return math.ceil(math.max(2,(bpm*lpb)/xStreamPos.WRITEAHEAD_FACTOR))

end

---------------------------------------------------------------------------------------------------

function xStreamPos:__tostring()

  return type(self)
    .. ", playpos=" ..tostring(self.playpos)
    .. ", pos=" ..tostring(self.pos)

end