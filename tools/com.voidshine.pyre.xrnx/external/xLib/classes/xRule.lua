cLib.require(_clibroot.."cSandbox")cLib.require(_clibroot.."cString")cLib.require(_xlibroot.."xRules")cLib.require(_xlibroot.."xLib")cLib.require(_xlibroot.."xTrack")cLib.require(_xlibroot.."xPhraseManager")cLib.require(_xlibroot.."xScale")cLib.require(_xlibroot.."xAutomation")cLib.require(_xlibroot.."xAudioDevice")cLib.require(_xlibroot.."xPlayPos")cLib.require(_xlibroot.."xParameter")cLib.require(_xlibroot.."xTransport")cLib.require(_xlibroot.."xOscPattern")cLib.require(_xlibroot.."xMidiMessage")cLib.require(_xlibroot.."xOscMessage")cLib.require(_xlibroot.."xRuleset")class'xRule'xRule.ASPECT={SYSEX="sysex",PORT_NAME="port_name",DEVICE_NAME="device_name",CHANNEL="channel",TRACK_INDEX="track_index",INSTRUMENT_INDEX="instrument_index",MESSAGE_TYPE="message_type",VALUE_1="value_1",VALUE_2="value_2",VALUE_3="value_3",VALUE_4="value_4",VALUE_5="value_5",VALUE_6="value_6",VALUE_7="value_7",VALUE_8="value_8",VALUE_9="value_9"}xRule.VALUES={"value_1","value_2","value_3","value_4","value_5","value_6","value_7","value_8","value_9"}xRule.ASPECT_DEFAULTS={SYSEX="F0 * F7",DEVICE_NAME={},PORT_NAME={},CHANNEL={},TRACK_INDEX={},INSTRUMENT_INDEX={},MESSAGE_TYPE=cLib.stringify_table(xMidiMessage.TYPE),VALUE_1=1,VALUE_2=1,VALUE_3=1,VALUE_4=1,VALUE_5=1,VALUE_6=1,VALUE_7=1,VALUE_8=1,VALUE_9=1}for a=1,16 do table.insert(xRule.ASPECT_DEFAULTS.CHANNEL,a)end;for a=1,256 do table.insert(xRule.ASPECT_DEFAULTS.TRACK_INDEX,a)table.insert(xRule.ASPECT_DEFAULTS.INSTRUMENT_INDEX,a)end;xRule.ASPECT_BASETYPE={SYSEX="string",PORT_NAME="string",DEVICE_NAME="string",MESSAGE_TYPE="string"}xRule.ASPECT_TYPE_OPERATORS={xRule.ASPECT.SYSEX,xRule.ASPECT.PORT_NAME,xRule.ASPECT.DEVICE_NAME,xRule.ASPECT.MESSAGE_TYPE}xRule.LOGIC={AND=1,OR=2}xRule.OPERATOR={BETWEEN="between",EQUAL_TO="equal_to",NOT_EQUAL_TO="not_equal_to",LESS_THAN="less_than",LESS_THAN_OR_EQUAL_TO="less_than_or_equal_to",GREATER_THAN="greater_than",GREATER_THAN_OR_EQUAL_TO="greater_than_or_equal_to"}xRule.TYPE_OPERATORS={xRule.OPERATOR.EQUAL_TO,xRule.OPERATOR.NOT_EQUAL_TO}xRule.VALUE_OPERATORS={xRule.OPERATOR.EQUAL_TO,xRule.OPERATOR.NOT_EQUAL_TO,xRule.OPERATOR.LESS_THAN,xRule.OPERATOR.LESS_THAN_OR_EQUAL_TO,xRule.OPERATOR.GREATER_THAN,xRule.OPERATOR.GREATER_THAN_OR_EQUAL_TO,xRule.OPERATOR.BETWEEN}xRule.ACTIONS={CALL_FUNCTION="call_function",OUTPUT_MESSAGE="output_message",ROUTE_MESSAGE="route_message",SET_CHANNEL="set_channel",SET_INSTRUMENT="set_instrument",SET_BIT_DEPTH="set_bit_depth",SET_MESSAGE_TYPE="set_message_type",SET_PORT_NAME="set_port_name",SET_DEVICE_NAME="set_device_name",SET_TRACK="set_track",SET_VALUE="set_value",INCREASE_INSTRUMENT="increase_instrument",INCREASE_TRACK="increase_track",INCREASE_CHANNEL="increase_channel",INCREASE_VALUE="increase_value",DECREASE_INSTRUMENT="decrease_instrument",DECREASE_TRACK="decrease_track",DECREASE_CHANNEL="decrease_channel",DECREASE_VALUE="decrease_value"}xRule.ACTIONS_FULL={CALL_FUNCTION=xRule.ACTIONS.CALL_FUNCTION,OUTPUT_MESSAGE=xRule.ACTIONS.OUTPUT_MESSAGE,ROUTE_MESSAGE=xRule.ACTIONS.ROUTE_MESSAGE,SET_CHANNEL=xRule.ACTIONS.SET_CHANNEL,SET_INSTRUMENT=xRule.ACTIONS.SET_INSTRUMENT,SET_PORT_NAME=xRule.ACTIONS.SET_PORT_NAME,SET_DEVICE_NAME=xRule.ACTIONS.SET_DEVICE_NAME,SET_TRACK=xRule.ACTIONS.SET_TRACK,SET_BIT_DEPTH=xRule.ACTIONS.SET_BIT_DEPTH,SET_MESSAGE_TYPE=xRule.ACTIONS.SET_MESSAGE_TYPE,SET_VALUE_1="set_value_1",SET_VALUE_2="set_value_2",SET_VALUE_3="set_value_3",SET_VALUE_4="set_value_4",SET_VALUE_5="set_value_5",SET_VALUE_6="set_value_6",SET_VALUE_7="set_value_7",SET_VALUE_8="set_value_8",SET_VALUE_9="set_value_9",INCREASE_INSTRUMENT=xRule.ACTIONS.INCREASE_INSTRUMENT,INCREASE_TRACK=xRule.ACTIONS.INCREASE_TRACK,INCREASE_CHANNEL=xRule.ACTIONS.INCREASE_CHANNEL,INCREASE_VALUE_1="increase_value_1",INCREASE_VALUE_2="increase_value_2",INCREASE_VALUE_3="increase_value_3",INCREASE_VALUE_4="increase_value_4",INCREASE_VALUE_5="increase_value_5",INCREASE_VALUE_6="increase_value_6",INCREASE_VALUE_7="increase_value_7",INCREASE_VALUE_8="increase_value_8",INCREASE_VALUE_9="increase_value_9",DECREASE_INSTRUMENT=xRule.ACTIONS.DECREASE_INSTRUMENT,DECREASE_TRACK=xRule.ACTIONS.DECREASE_TRACK,DECREASE_CHANNEL=xRule.ACTIONS.DECREASE_CHANNEL,DECREASE_VALUE_1="decrease_value_1",DECREASE_VALUE_2="decrease_value_2",DECREASE_VALUE_3="decrease_value_3",DECREASE_VALUE_4="decrease_value_4",DECREASE_VALUE_5="decrease_value_5",DECREASE_VALUE_6="decrease_value_6",DECREASE_VALUE_7="decrease_value_7",DECREASE_VALUE_8="decrease_value_8",DECREASE_VALUE_9="decrease_value_9"}xRule.ACTIONS_TO_ASPECT_MAP={SET_INSTRUMENT=xRule.ASPECT.INSTRUMENT_INDEX,SET_TRACK=xRule.ASPECT.TRACK_INDEX,SET_CHANNEL=xRule.ASPECT.CHANNEL,SET_VALUE_1=xRule.ASPECT.VALUE_1,SET_VALUE_2=xRule.ASPECT.VALUE_2,SET_VALUE_3=xRule.ASPECT.VALUE_3,SET_VALUE_4=xRule.ASPECT.VALUE_4,SET_VALUE_5=xRule.ASPECT.VALUE_5,SET_VALUE_6=xRule.ASPECT.VALUE_6,SET_VALUE_7=xRule.ASPECT.VALUE_7,SET_VALUE_8=xRule.ASPECT.VALUE_8,SET_VALUE_9=xRule.ASPECT.VALUE_9,INCREASE_INSTRUMENT=xRule.ASPECT.INSTRUMENT_INDEX,INCREASE_TRACK=xRule.ASPECT.TRACK_INDEX,INCREASE_CHANNEL=xRule.ASPECT.CHANNEL,INCREASE_VALUE_1=xRule.ASPECT.VALUE_1,INCREASE_VALUE_2=xRule.ASPECT.VALUE_2,INCREASE_VALUE_3=xRule.ASPECT.VALUE_3,INCREASE_VALUE_4=xRule.ASPECT.VALUE_4,INCREASE_VALUE_5=xRule.ASPECT.VALUE_5,INCREASE_VALUE_6=xRule.ASPECT.VALUE_6,INCREASE_VALUE_7=xRule.ASPECT.VALUE_7,INCREASE_VALUE_8=xRule.ASPECT.VALUE_8,INCREASE_VALUE_9=xRule.ASPECT.VALUE_9,DECREASE_INSTRUMENT=xRule.ASPECT.INSTRUMENT_INDEX,DECREASE_TRACK=xRule.ASPECT.TRACK_INDEX,DECREASE_CHANNEL=xRule.ASPECT.CHANNEL,DECREASE_VALUE_1=xRule.ASPECT.VALUE_1,DECREASE_VALUE_2=xRule.ASPECT.VALUE_2,DECREASE_VALUE_3=xRule.ASPECT.VALUE_3,DECREASE_VALUE_4=xRule.ASPECT.VALUE_4,DECREASE_VALUE_5=xRule.ASPECT.VALUE_5,DECREASE_VALUE_6=xRule.ASPECT.VALUE_6,DECREASE_VALUE_7=xRule.ASPECT.VALUE_7,DECREASE_VALUE_8=xRule.ASPECT.VALUE_8,DECREASE_VALUE_9=xRule.ASPECT.VALUE_9}xRule.ACTION_BASETYPE={CALL_FUNCTION="string",OUTPUT_MESSAGE="string",ROUTE_MESSAGE="string",SEND_MESSAGE="string"}function xRule:__init(b)if not b then b={}end;self.conditions=b.conditions or{}self.actions=b.actions or{}self.osc_pattern=nil;self.name=property(self.get_name,self.set_name)self.name_observable=renoise.Document.ObservableString(b.name or"")self.match_any=property(self.get_match_any,self.set_match_any)self.match_any_observable=renoise.Document.ObservableBoolean(type(b.match_any)~="boolean"and true or b.match_any)self.midi_enabled=property(self.get_midi_enabled,self.set_midi_enabled)self.midi_enabled_observable=renoise.Document.ObservableBoolean(type(b.midi_enabled)~="boolean"and true or b.midi_enabled)self.last_received_message=nil;self.values=property(self.get_values)self.modified_observable=renoise.Document.ObservableBang()self.sandbox=nil;if b.osc_pattern then self.osc_pattern=xOscPattern{pattern_in=b.osc_pattern.pattern_in,pattern_out=b.osc_pattern.pattern_out}else self.osc_pattern=xOscPattern()end;self.osc_pattern.pattern_in_observable:add_notifier(function()self.modified_observable:bang()end)self.osc_pattern.pattern_out_observable:add_notifier(function()self.modified_observable:bang()end)self.sandbox=cSandbox()self.sandbox.compile_at_once=true;self.sandbox.str_prefix=[[
    __xmsg = select(1, ...)
    __xrules = select(2, ...)
    __xruleset_index = select(3, ...)

    ---------------------------------------------------------------------------
    -- comparing numbers with variable precision
    -- @param val1 (number)
    -- @param val2 (number)
    -- @param operator (xRule.OPERATOR)
    -- @param precision (number), optional precision factor
    local compare_numbers = function(val1,val2,operator,precision)
      local is_equal = precision and cLib.float_compare(val1,val2,precision) 
        or val1 == val2
      local operators_table = {
        ["equal_to"] = function()
          return is_equal
        end,
        ["not_equal_to"] = function()
          return not is_equal
        end,
        ["less_than"] = function()
          return not is_equal and (val1 < val2)
        end,
        ["less_than_or_equal_to"] = function()
          return is_equal or (val1 < val2)
        end,
        ["greater_than"] = function()
          return not is_equal and (val1 > val2)
        end,
        ["greater_than_or_equal_to"] = function()
          return is_equal or (val1 > val2)
        end,
      }
      if not operators_table[operator] then
        error("Could not find operator")
      else
        return operators_table[operator]()
      end
    end

    ---------------------------------------------------------------------------
    -- add/clone message into the output queue
    -- @param val (string), one of xRules.OUTPUT_OPTIONS
    local output_message = function(val)

      local xmsg_out
      local xmsg_type = type(__xmsg)

      if not (xmsg_type=='xMidiMessage') 
        and not (xmsg_type=='xOscMessage')
      then
        error("Expected implementation of xMessage")
      end

      local def = __xmsg.__def
      if (val == xRules.OUTPUT_OPTIONS.EXTERNAL_OSC)
        and (type(__xmsg)=='xMidiMessage') 
      then 
        -- convert from MIDI -> OSC
        def.pattern = __xrule.osc_pattern
        def.device_name = __xmsg.device_name
        xmsg_out = xOscMessage(def)

      elseif (type(__xmsg)=='xOscMessage') 
        and ((val == xRules.OUTPUT_OPTIONS.EXTERNAL_MIDI)
        or (val == xRules.OUTPUT_OPTIONS.INTERNAL_RAW))
      then 
        -- convert from OSC -> MIDI
        def.message_type = __xmsg.message_type
        def.channel = __xmsg.channel
        def.bit_depth = __xmsg.bit_depth
        def.port_name = __xmsg.port_name
        xmsg_out = xMidiMessage(def)

      else -- internal can be both
        if (type(__xmsg)=='xOscMessage') then
          xmsg_out = xOscMessage(def)
        elseif (type(__xmsg)=='xMidiMessage') then
          xmsg_out = xMidiMessage(def)
        end
      end

      table.insert(__output,{
        target = val,
        xmsg = xmsg_out
      })

    end

    ---------------------------------------------------------------------------
    -- pass message on to a different rule/set
    -- @param val (string), "ruleset_name:rule_name"
    local route_message = function(val)
      local routing_values = cString.split(val,":")
      local rule,ruleset,rule_idx,ruleset_idx
      if (routing_values[1] == xRuleset.CURRENT_RULESET) then
        ruleset = __xrules.rulesets[__xruleset_index]
        ruleset_idx = __xruleset_index
      else
        ruleset,ruleset_idx = __xrules:get_ruleset_by_name(routing_values[1])
      end
      if ruleset then
        rule,rule_idx = ruleset:get_rule_by_name(routing_values[2])
        --ruleset,ruleset_idx = __xrules:get_ruleset_by_name(routing_values[1])
      else
      end
      if ruleset and rule then
        __xrules:match_message(__xmsg,ruleset_idx,rule_idx,true)
      end
    end

    ---------------------------------------------------------------------------
    -- (alias for xAutomation:record)
    local record_automation = function(track_idx,param,value,value_mode)
      __xrules.automation:record(track_idx,param,value,value_mode)
    end

    ---------------------------------------------------------------------------
    -- (alias for xAutomation:has_automation)
    local has_automation = function(track_idx,param)
      return __xrules.automation:has_automation(track_idx,param)
    end

    ---------------------------------------------------------------------------
    -- generated code...

  ]]self.sandbox.str_suffix=[[
    return __output,__evaluated
  ]]local c={["rns"]={access=function(d)return rns end},["renoise"]={access=function(d)return renoise end},["__xrule"]={access=function(d)return self end},["rules"]={access=function(d)local e=d.__xrules.rulesets[d.__xruleset_index]return e.rules end},["cLib"]={access=function(d)return cLib end},["cString"]={access=function(d)return cString end},["xLib"]={access=function(d)return xLib end},["xRules"]={access=function(d)return xRules end},["xRuleset"]={access=function(d)return xRuleset end},["xTrack"]={access=function(d)return xTrack end},["xTransport"]={access=function(d)return xTransport end},["xScale"]={access=function(d)return xScale end},["xMidiMessage"]={access=function(d)return xMidiMessage end},["xOscMessage"]={access=function(d)return xOscMessage end},["xAutomation"]={access=function(d)return xAutomation end},["xParameter"]={access=function(d)return xParameter end},["xPlayPos"]={access=function(d)return xPlayPos end},["xAudioDevice"]={access=function(d)return xAudioDevice end},["xPhraseManager"]={access=function(d)return xPhraseManager end},["track_index"]={access=function(d)return d.__xmsg.track_index end,assign=function(d,f)d.__xmsg.track_index=f end},["instrument_index"]={access=function(d)return d.__xmsg.instrument_index end,assign=function(d,f)d.__xmsg.instrument_index=f end},["values"]={access=function(d)return d.__xmsg.values end,assign=function(d,f)d.__xmsg.values=f end},["message_type"]={access=function(d)return d.__xmsg.message_type end,assign=function(d,f)d.__xmsg.message_type=f end},["channel"]={access=function(d)return d.__xmsg.channel end,assign=function(d,f)d.__xmsg.channel=f end},["bit_depth"]={access=function(d)return d.__xmsg.bit_depth end,assign=function(d,f)d.__xmsg.bit_depth=f end},["port_name"]={access=function(d)return d.__xmsg.port_name end,assign=function(d,f)d.__xmsg.port_name=f end},["device_name"]={access=function(d)return d.__xmsg.device_name end,assign=function(d,f)d.__xmsg.device_name=f end}}for g=1,#xRule.VALUES do c[("value_%x"):format(g)]={access=function(d)return d.__xmsg.values[g]end,assign=function(d,f)d.__xmsg.values[g]=f end}end;self.sandbox.properties=c;self.sandbox.modified_observable:add_notifier(function()self.modified_observable:bang()end)local h,i=self:compile()if i then LOG(i)end end;function xRule:get_name()return self.name_observable.value end;function xRule:set_name(j)assert(type(j)=="string","Expected name to be a string")j=j:gsub(":","")local k=j~=self.name_observable.value and true or false;self.name_observable.value=j;if k then self.modified_observable:bang()end end;function xRule:get_midi_enabled()return self.midi_enabled_observable.value end;function xRule:set_midi_enabled(j)assert(type(j)=="boolean","Expected midi_enabled to be a boolean")local k=j~=self.midi_enabled and true or false;self.midi_enabled_observable.value=j;if k then self.modified_observable:bang()end end;function xRule:get_values()if self.last_received_message then return self.last_received_message.values end end;function xRule:get_match_any()return self.match_any_observable.value end;function xRule:set_match_any(j)assert(type(j)=="boolean","Expected match_any to be a boolean")local k=j~=self.match_any and true or false;self.match_any_observable.value=j;if k then local l,i=self:compile()if i then LOG(i)end;self.modified_observable:bang()end end;function xRule:serialize()local m={["name"]=self.name,["match_any"]=self.match_any,["midi_enabled"]=self.midi_enabled,["conditions"]=self.conditions,["actions"]=self.actions,["osc_pattern"]={pattern_in=self.osc_pattern.pattern_in,pattern_out=self.osc_pattern.pattern_out}}local n,o=nil,true;return cLib.serialize_table(m,n,o)end;function xRule:match(p,q,r)if not self.sandbox.callback then LOG("*** no sandbox callback, aborting...")return{}end;self.last_received_message=p;self.sandbox.env.__xmsg={}self.sandbox.env.__output={}self.sandbox.env.__evaluated=false;local s,t;local h,i=pcall(function()s,t=self.sandbox.callback(p,q,r)end)if not h and i then LOG("*** ERROR: please review the callback function - "..i)LOG("*** ",self.sandbox.callback_str)return{}else return s,t end end;function xRule:fix_conditions()local u=false;local v=true;local w=false;local x=1;while not w do local f=self.conditions[x]if#f==1 then if not table.find(xRule.LOGIC,f[1])then error("Unknown logic statement")end;if v then LOG("*** xRule: first entry can't be a logic statement (remove)")table.remove(self.conditions,x)x=x-1 else x=x+1;u=true end;if u then local y=false;while self.conditions[x]and#self.conditions[x]==1 do LOG("*** xRule: consecutive logic statements are not allowed (remove)")table.remove(self.conditions,x)y=true end;if y then x=x-1 end;f=self.conditions[x]end else u=false end;if#f==0 then v=false end;if not self.conditions[x+1]then w=true else x=x+1 end end end;function xRule:compile()if#self.conditions==0 and not self.match_any then self.sandbox.callback=nil;return false,"Can't compile - no conditions were defined"end;local z=function(g,f)local m=cString.split(f," ")local A=""local B=false;for g,f in ipairs(m)do if g>1 and not B then A=A.."and "end;if f~="*"then A=A.."(values["..g.."] == 0x"..f..") "B=false else B=true end end;A=A.." \n"return A end;local C=function(g,f)local A=""local x=0;for D,E in pairs(f)do if x>0 then A=A.."and "end;local j=E;local F=nil;if D==xRule.OPERATOR.BETWEEN then if type(j)~="table"then j={j,j}end else if type(j)=="table"then j=j[1]end;if g~=xMidiMessage.TYPE.SYSEX then if type(j)=="string"then j="'"..j.."'"elseif type(j)=="number"then if self.osc_pattern.complete then F=self.osc_pattern.precision end end end end;F=tostring(F)if g==xMidiMessage.TYPE.SYSEX then A=A..z(g,j)elseif type(j)=="string"then if D==xRule.OPERATOR.EQUAL_TO then A=A.."("..g.." == "..j..") \n"else A=A.."("..g.." ~= "..j..") \n"end elseif D==xRule.OPERATOR.BETWEEN then A=A.."(".."compare_numbers("..g..","..j[1]..",'"..xRule.OPERATOR.GREATER_THAN_OR_EQUAL_TO.."',"..F..") and ".."compare_numbers("..g..","..j[2]..",'"..xRule.OPERATOR.LESS_THAN_OR_EQUAL_TO.."',"..F..")  "..") \n"else A=A.."(compare_numbers("..g..","..j..",'"..D.."',"..F..")) \n"end;x=x+1 end;return A end;local A="if "if#self.conditions==0 and self.match_any then A=A.."(true) "else local x=0;local u=false;for g,f in ipairs(self.conditions)do if#f==1 then if f[1]==xRule.LOGIC.AND then A=A.."and "elseif f[1]==xRule.LOGIC.OR then A=A.."or "else error("Unknown logic statement")end;u=true else if not u and x>0 then A=A.."and "end;for D,E in pairs(f)do A=A..C(D,E)end;u=false end;x=x+1 end end;A=A.."then \n"A=A.."__evaluated = true \n"for g,f in ipairs(self.actions)do for D,E in pairs(f)do if D==xRule.ACTIONS.OUTPUT_MESSAGE then A=A..string.format("output_message('%s') \n",E)elseif D==xRule.ACTIONS.ROUTE_MESSAGE then A=A..string.format("route_message('%s') \n",E)elseif D==xRule.ACTIONS.SET_INSTRUMENT then A=A..string.format("instrument_index = %d \n",E)elseif D==xRule.ACTIONS.SET_TRACK then A=A..string.format("track_index = %d \n",E)elseif D==xRule.ACTIONS.SET_PORT_NAME then A=A..string.format("port_name = '%s' \n",E)elseif D==xRule.ACTIONS.SET_DEVICE_NAME then A=A..string.format("device_name = '%s' \n",E)elseif D==xRule.ACTIONS.SET_CHANNEL then A=A..string.format("channel = %d \n",E)elseif D==xRule.ACTIONS.SET_BIT_DEPTH then A=A..string.format("bit_depth = %d \n",E)elseif D==xRule.ACTIONS.SET_MESSAGE_TYPE then A=A..string.format("message_type = '%s' \n",E)elseif string.find(D,"set_value_",nil,true)then local G=xRule.get_value_index(D)if type(E)=="string"then A=A..string.format("values[%d] = '%s' \n",G,E)else A=A..string.format("values[%d] = %d \n",G,E)end elseif D==xRule.ACTIONS.INCREASE_INSTRUMENT then A=A..string.format("instrument_index = instrument_index + %d \n",E)elseif D==xRule.ACTIONS.INCREASE_TRACK then A=A..string.format("track_index = track_index + %d \n",E)elseif D==xRule.ACTIONS.INCREASE_CHANNEL then A=A..string.format("channel = channel + %d \n",E)elseif string.find(D,"increase_value_",nil,true)then local G=xRule.get_value_index(D)A=A..string.format("values[%d] = values[%d] + %d \n",G,G,E)elseif D==xRule.ACTIONS.DECREASE_INSTRUMENT then A=A..string.format("instrument_index = instrument_index - %d \n",E)elseif D==xRule.ACTIONS.DECREASE_TRACK then A=A..string.format("track_index = track_index - %d \n",E)elseif D==xRule.ACTIONS.DECREASE_CHANNEL then A=A..string.format("channel = channel - %d \n",E)elseif string.find(D,"decrease_value_",nil,true)then local G=xRule.get_value_index(D)A=A..string.format("values[%d] = values[%d] - %d \n",G,G,E)elseif D==xRule.ACTIONS.CALL_FUNCTION then A=A..string.format("%s \n",E)else error("Unknown action")end end end;A=A.."end \n"local l,i=self.sandbox:test_syntax(A)if l then self.sandbox.callback_str=A else return false,"Invalid syntax when checking rule:"..i end end;function xRule.get_value_index(H)local I=string.match(H,"_(.)$")if I then return tonumber(("0x%s"):format(I))end end