class'xPhraseSelection'function xPhraseSelection.get_phrase()local a=rns.selected_phrase;if not a then return false,"Could not retrieve selection, no phrase selected"end;return{start_line=1,start_column=1,end_line=a.number_of_lines,end_column=a.visible_note_columns+a.visible_effect_columns}end