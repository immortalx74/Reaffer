Editor = {}

function Editor.OnClick(cx, cy)
	if App.active_tool == e_Tool.Draw then
		App.editor_state = e_EditorState.EnterNote
		-- Deselect previously selected notes
		for i, v in ipairs(App.note_list) do
			App.note_list[i].selected = false
		end
		
		local open_pitch = Util.NoteNameToPitch(App.instrument[App.num_strings - 3][App.num_strings - cy])
		local new_note = {offset = cx, string_idx = cy, pitch = open_pitch, velocity = 127, duration = 1, selected = true}
		local idx = #App.note_list + 1
		App.note_list[idx] = new_note
		App.last_note_pitch = App.note_list[idx].pitch
	end
end

function Editor.OnRelease()
	if App.active_tool == e_Tool.Draw then
		App.editor_state = e_EditorState.DrawReady
		App.drag_x = 0
		App.drag_y = 0
	end
end

function Editor.OnDrag()
	if App.active_tool == e_Tool.Draw and App.editor_state == e_EditorState.EnterNote then
		-- Get selected note
		local sel_idx = 1
		for i, v in ipairs(App.note_list) do
			if App.note_list[i].selected then
				sel_idx = i
				break
			end
		end
		
		local cell_x = math.floor((App.mouse_x - App.arrange_win_x + App.scroll_x -15) / 34) - 1
		local cell_y = math.floor((App.mouse_y - App.arrange_win_y - App.top_margin + 5) / 12)
		
		if cell_x >= App.note_list[sel_idx].offset then
			App.note_list[sel_idx].duration = cell_x - App.note_list[sel_idx].offset + 1
		end
		
		local pitch_min = Util.NoteNameToPitch(App.instrument[App.num_strings - 3][App.num_strings - App.note_list[sel_idx].string_idx])
		local pitch_max = pitch_min + 24
		
		local diff = Util.Clamp(App.note_list[sel_idx].string_idx - cell_y, -(App.last_note_pitch - pitch_min), pitch_max - App.last_note_pitch)
		App.note_list[sel_idx].pitch = App.last_note_pitch + diff
		msg(App.note_list[sel_idx].string_idx - cell_y .. "\n")
	end
end