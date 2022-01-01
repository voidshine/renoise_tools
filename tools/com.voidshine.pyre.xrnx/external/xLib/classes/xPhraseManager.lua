cLib.require(_xlibroot.."xPhrase")class'xPhraseManager'xPhraseManager.MAX_NUMBER_OF_PHRASES=126;function xPhraseManager.get_available_slot(a,b,c)TRACE("xPhraseManager.get_available_slot(instr_idx,keymap_range,keymap_offset)",a,b,c)assert(type(a)=="number","Expected instr_idx to be a number")local d=rns.instruments[a]if not d then return false,"Could not locate instrument"end;if not c then c=0 end;if not b then b=12 end;local e=nil;local f=119;local g=nil;local h=nil;local i=nil;for j,k in ipairs(d.phrase_mappings)do if k.note_range[2]>=c then if not i then i=k.note_range[1]-1 end;if not g and k.note_range[1]>i+1 then g=i+1;h=k.note_range[1]-1;e=j;break else end;i=k.note_range[2]else local l=d.phrase_mappings[j+1]if l and l.note_range[1]>c then i=c-1 end end end;if not g then g=math.max(c,i and i+1 or 0)if table.is_empty(d.phrase_mappings)then e=1 else e=#d.phrase_mappings+1 end end;if not h then h=g+b-1 end;h=math.min(119,h)if h-g<b then b=h-g end;if h>f then b=f-i-1 end;if g>119 then return false,"There is no more room for phrase mapping"end;local m={g,g+b}return m,e end;function xPhraseManager.get_empty_slot(a,c)TRACE("xPhraseManager.get_empty_slot(instr_idx,keymap_offset)",a,c)assert(type(a)=="number","Expected instr_idx to be a number")local d=rns.instruments[a]if not d then return false,"Could not locate instrument"end;if not c then c=0 end;local h=nil;for j,k in ipairs(d.phrase_mappings)do if k.note_range[1]>=c and h and k.note_range[1]==h+1 then if k.phrase.is_empty then return k.note_range,j end end;if not h then h=k.note_range[2]end end;for j,k in ipairs(d.phrases)do if k.is_empty then if k.mapping then return k.mapping.note_range,j else return nil,j end end end end;function xPhraseManager.auto_insert_phrase(a,n,o,p)TRACE("xPhraseManager.auto_insert_phrase(instr_idx,insert_at_idx,takeover,keymap_args)",a,n,o,p)assert(type(a)=="number")if n then assert(type(n)=="number")end;if o then assert(type(o)=="boolean")end;local q=false;local b,c;if p then q=true;b=p.keymap_range;c=p.keymap_offset;assert(type(b)=="number")assert(type(c)=="number")end;local d=rns.instruments[a]if not d then local r="Failed to allocate a phrase (could not locate instrument)"return false,r end;local s,t=nil,nil;local u=true;if o then s,t=xPhraseManager.get_empty_slot(a,c)if t then u=false;q=false end end;if not t then if q then s,t=xPhraseManager.get_available_slot(a,b,c)if not s then local v="Failed to allocate keymapping for the phrase (not enough room)"return false,v end end end;local w=t;t=n and n or#d.phrases>0 and#d.phrases+1 or 1;local x=nil;if u then if#d.phrases==xPhraseManager.MAX_NUMBER_OF_PHRASES then local v="Failed to allocate phrase (each instrument can only contain up to 126 phrases)"return false,v end;x=d:insert_phrase_at(t)else x=d.phrases[t]end;if q and renoise.API_VERSION>4 then d:insert_phrase_mapping_at(w,x)end;if q or renoise.API_VERSION<=4 then x.mapping.note_range={s[1],s[2]}x.mapping.base_note=s[1]end;return x,t end;function xPhraseManager.select_previous_phrase()TRACE("xPhraseManager.select_previous_phrase()")local e=rns.selected_phrase_index;if not e or e==0 then return false,"No phrase have been selected"end;e=math.max(1,e-1)rns.selected_phrase_index=e;return e end;function xPhraseManager.can_select_previous_phrase()TRACE("xPhraseManager.can_select_previous_phrase()")local e=rns.selected_phrase_index;if not e or e==0 then return false,"No phrase have been selected"end;local d=rns.selected_instrument;return rns.selected_phrase_index>1 and true or false end;function xPhraseManager.set_selected_phrase_by_mapping_index(y)TRACE("xPhraseManager.set_selected_phrase_by_mapping_index(idx)",y)local d=rns.selected_instrument;local z=d.phrase_mappings[y]if not z then LOG("*** Could not find the specified phrase mapping")return end;for j,k in ipairs(d.phrases)do if rawequal(k,z.phrase)then rns.selected_phrase_index=j end end end;function xPhraseManager.select_next_phrase()TRACE("xPhraseManager.select_next_phrase()")local e=rns.selected_phrase_index;if not e or e==0 then return false,"No phrase have been selected"end;local d=rns.selected_instrument;e=math.min(#d.phrases,e+1)rns.selected_phrase_index=e;return e end;function xPhraseManager.can_select_next_phrase()TRACE("xPhraseManager.can_select_next_phrase()")local e=rns.selected_phrase_index;if not e or e==0 then return false,"No phrase have been selected"end;local d=rns.selected_instrument;return rns.selected_phrase_index<#d.phrases and true or false end;function xPhraseManager.select_next_phrase_mapping()TRACE("xPhraseManager.select_next_phrase_mapping()")local x=rns.selected_phrase;if not x.mapping then return false,"No mapping has been assigned to selected phrase"end;local d=rns.selected_instrument;local A=nil;local B={}for j,k in ipairs(d.phrases)do if k.mapping and k.mapping.note_range[1]>x.mapping.note_range[1]then B[k.mapping.note_range[1]]={phrase=k,index=j}if not A then A=k.mapping.note_range[1]end;A=math.min(A,k.mapping.note_range[1])end end;if not table.is_empty(B)then rns.selected_phrase_index=B[A].index end end;function xPhraseManager.select_previous_phrase_mapping()TRACE("xPhraseManager.select_previous_phrase_mapping()")local d=rns.selected_instrument;local x=rns.selected_phrase;if not x.mapping then return false,"No mapping has been assigned to selected phrase"end;local C=nil;local B={}for j,k in ipairs(d.phrases)do if k.mapping and k.mapping.note_range[1]<x.mapping.note_range[1]then B[k.mapping.note_range[1]]={phrase=k,index=j}if not C then C=k.mapping.note_range[1]end;C=math.max(C,k.mapping.note_range[1])end end;if not table.is_empty(B)then rns.selected_phrase_index=B[C].index end end;function xPhraseManager.set_selected_phrase(y)TRACE("xPhraseManager.set_selected_phrase(idx)",y)local d=rns.selected_instrument;if d.phrases[y]then rns.selected_phrase_index=y end end;function xPhraseManager.select_first_phrase()TRACE("xPhraseManager.select_first_phrase()")local d=rns.selected_instrument;if#d.phrases==0 then return false,"Instrument does not contain any phrases"end;rns.selected_phrase_index=1;return true end;function xPhraseManager.select_last_phrase()TRACE("xPhraseManager.select_last_phrase()")local d=rns.selected_instrument;if#d.phrases==0 then return false,"Instrument does not contain any phrases"end;rns.selected_phrase_index=#d.phrases;return true end;function xPhraseManager.get_phrase_index_by_mapping_index(a,D)TRACE("xPhraseManager.get_phrase_index_by_mapping_index(instr_idx,mapping_idx)",a,D)local d=rns.instruments[a]if not d then return false,"Could not find the specified instrument"end;local z=d.phrase_mappings[D]if not z then return false,"Could not find the specified phrase mapping"end;for j,k in ipairs(d.phrases)do if rawequal(k,z.phrase)then return j end end end;function xPhraseManager.get_mapping_index_by_phrase_index(a,e)TRACE("xPhraseManager.get_mapping_index_by_phrase_index(instr_idx,phrase_idx)",a,e)local d=rns.instruments[a]if not d then return false,"Could not find the specified instrument"end;local x=d.phrases[e]if not x then return false,"Could not find the specified phrase"end;for j,k in ipairs(d.phrase_mappings)do if rawequal(k,x.mapping)then return k,j end end end;function xPhraseManager.set_universal_property(a,e,E,F)local G={"key_tracking","base_note","note_range","looping","loop_start","loop_end"}if not table.find(G,E)then return false,"Property name is not allowed for phrase mappings"end;local d=rns.instruments[a]if not d then return false,"Could not find the specified instrument"end;local x=d.phrases[e]if x then x[E]=F end;local z,D=xPhraseManager.get_mapping_index_by_phrase_index(a,e)if z then z[E]=F end;return true end;function xPhraseManager.delete_selected_phrase()TRACE("xPhraseManager.delete_selected_phrase()")local d=rns.selected_instrument;local e=rns.selected_phrase_index;if e and d.phrases[e]then d:delete_phrase_at(e)end end;function xPhraseManager.delete_selected_phrase_mapping()TRACE("xPhraseManager.delete_selected_phrase_mapping()")local d=rns.selected_instrument;local D=xPhraseManager.get_selected_mapping_index()if d and D then d:delete_phrase_mapping_at(D)end end;function xPhraseManager.get_selected_mapping()TRACE("xPhraseManager.get_selected_mapping()")local x=rns.selected_phrase;if x then return x.mapping end end;function xPhraseManager.get_selected_mapping_index()TRACE("xPhraseManager.get_selected_mapping_index()")local e=rns.selected_phrase_index;if not e then return end;local a=rns.selected_instrument_index;local z,D=xPhraseManager.get_mapping_index_by_phrase_index(a,e)if D then return D end end;function xPhraseManager.set_playback_mode(H,I)TRACE("xPhraseManager.set_playback_mode(mode,toggle)",H,I)local x=rns.selected_phrase;if not x then return false,"No phrase is selected"end;if I then if rns.selected_instrument.phrase_playback_mode==H then rns.selected_instrument.phrase_playback_mode=renoise.Instrument.PHRASES_OFF else rns.selected_instrument.phrase_playback_mode=H end else rns.selected_instrument.phrase_playback_mode=H end;return true end;function xPhraseManager.cycle_playback_mode()TRACE("xPhraseManager.cycle_playback_mode()")local x=rns.selected_phrase;if not x then return false,"No phrase is selected"end;if rns.selected_instrument.phrase_playback_mode==renoise.Instrument.PHRASES_OFF then rns.selected_instrument.phrase_playback_mode=renoise.Instrument.PHRASES_PLAY_SELECTIVE elseif rns.selected_instrument.phrase_playback_mode==renoise.Instrument.PHRASES_PLAY_SELECTIVE then rns.selected_instrument.phrase_playback_mode=renoise.Instrument.PHRASES_PLAY_KEYMAP elseif rns.selected_instrument.phrase_playback_mode==renoise.Instrument.PHRASES_PLAY_KEYMAP then rns.selected_instrument.phrase_playback_mode=renoise.Instrument.PHRASES_OFF end;return true end;function xPhraseManager.find_duplicates(d)TRACE("xPhraseManager.find_duplicates(instr)",d)local J={}local K={}for j,k in ipairs(d.phrases)do local L=xPhrase.stringify(k)if J[L]then table.insert(K,{source_phrase_index=J[L].phrase_index,target_phrase_index=j})else J[L]={phrase_index=j}end end;return K end;function xPhraseManager.export_presets(M,a,N,O,P)TRACE("xPhraseManager.export_presets(folder,instr_idx,indices,overwrite,prefix)",M,a,N,O,P)assert(type(M)=="string")assert(type(a)=="number")for j,k in ripairs(N)do local Q,v=xPhrase.export_preset(M,a,k,O,P)if v then return false,v,N end;N[j]=nil end;return true end;function xPhraseManager.import_presets(R,a,n,o,p,S)TRACE("xPhraseManager.import_presets(files,instr_idx,insert_at_idx,takeover,keymap_args,remove_prefix)",R,a,n,o,p,S)assert(type(R)=="table")assert(type(a)=="number")for j,k in ipairs(R)do local x,T=xPhraseManager.auto_insert_phrase(a,n,o,p)if not x then return false,T end;rns.selected_phrase_index=T;if not renoise.app():load_instrument_phrase(k)then return false,"Failed to load phrase preset: "..tostring(k)end;if S then rns.selected_phrase.name=xPhrase.get_raw_preset_name(rns.selected_phrase.name)end end end