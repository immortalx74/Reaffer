Editor = {}

function Editor.OnClick(cx, cy)
	if App.active_tool == e_Tool.Draw then
		App.editor_state = e_EditorState.EnterNote
		
		if Util.IsCellEmpty(cx, cy, true) then
			-- deselect all
			for i, note in ipairs(App.note_list) do
				note.selected = false
			end
			-- create new
			local open_pitch = Util.NoteNameToPitch(App.instrument[App.num_strings - 3][App.num_strings - cy])
			local new_note = {offset = cx, string_idx = cy, pitch = open_pitch, velocity = 127, duration = 1, selected = true}
			local idx = #App.note_list + 1
			App.note_list[idx] = new_note
			App.last_note_pitch = App.note_list[idx].pitch
		else
			-- deselect all except the clicked one
			for i, note in ipairs(App.note_list) do
				if (cx >= note.offset) and (cx < note.offset + note.duration) and (cy == note.string_idx) then
					note.selected = true
					App.last_note_pitch = note.pitch
				else
					note.selected = false
				end
			end
		end
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
		-- Get selected note idx
		local sel_idx = 1
		for i, note in ipairs(App.note_list) do
			if note.selected then
				sel_idx = i
				break
			end
		end
		
		local cell_x = Util.GetCellX()
		local cell_y = Util.GetCellY()
		
		-- duration
		local nearest = Util.GetCellNearestOccupied(App.note_list[sel_idx].offset, App.note_list[sel_idx].string_idx, e_Direction.Right)
		if cell_x >= App.note_list[sel_idx].offset then
			App.note_list[sel_idx].duration = Util.Clamp(cell_x - App.note_list[sel_idx].offset + 1, 1, nearest - App.note_list[sel_idx].offset)
		end
		
		-- pitch
		local pitch_min = Util.NoteNameToPitch(App.instrument[App.num_strings - 3][App.num_strings - App.note_list[sel_idx].string_idx])
		local pitch_max = pitch_min + 24
		
		local diff = Util.Clamp(App.note_list[sel_idx].string_idx - cell_y, -(App.last_note_pitch - pitch_min), pitch_max - App.last_note_pitch)
		App.note_list[sel_idx].pitch = App.last_note_pitch + diff
	end
end