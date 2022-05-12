Editor = {}

function Editor.OnClick(cx, cy)
	if App.active_tool == e_Tool.Erase and not Util.IsCellEmpty(cx, cy, true) then
		local clicked_idx = 0

		for i, note in ipairs(App.note_list) do
			if (cx >= note.offset) and (cx < note.offset + note.duration) and (cy == note.string_idx) then
				clicked_idx = i
				break
			end
		end

		if clicked_idx > 0 and App.note_list[clicked_idx].selected then -- The one clicked is selected, so erase all selected notes
			local len = #App.note_list
			for i = len, 1, -1 do
				if App.note_list[i].selected then table.remove(App.note_list, i); end
			end
		else -- An unselected one was clicked. Delete this instead
			table.remove(App.note_list, clicked_idx)
		end

		App.last_clicked[1] = nil
	end

	if Util.IsCellEmpty(cx, cy, true) then
		if App.active_tool == e_Tool.Draw then
			Util.DeselectAll()
			-- create new
			local open_pitch = App.instrument[App.num_strings - 3].open[App.num_strings - cy]
			local idx = #App.note_list + 1
			
			local new_note = {idx = idx, offset = cx, string_idx = cy, pitch = open_pitch, velocity = 127, duration = 1, selected = true}
			App.note_list[idx] = new_note
			
			App.last_clicked = new_note
			UR.PushUndo(e_OpType.Enter, {new_note})
		end
		if App.active_tool == e_Tool.Select or App.active_tool == e_Tool.Move then
			Util.DeselectAll()
			App.last_clicked[1] = nil
		end
	else
		-- clicked existing note(s)
		for i, note in ipairs(App.note_list) do
			if (cx >= note.offset) and (cx < note.offset + note.duration) and (cy == note.string_idx) then
				if reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Key_ModCtrl()) then
					note.selected = true
				else
					if not note.selected then
						Util.DeselectAll() -- deselect all, then select this one
						note.selected = true
					end
				end
				App.last_clicked[1] = {idx = i, offset = note.offset, string_idx = note.string_idx, pitch = note.pitch, velocity = note.velocity, duration = note.duration, selected = note.selected}
			end
		end
	end
end

function Editor.OnRelease()
	App.can_init_drag = false

	if App.active_tool == e_Tool.Draw then
		App.editor_state = e_EditorState.DrawReady
	end
end

function Editor.OnDrag()
	if App.last_clicked[1] == nil then return; end
	
	if App.active_tool == e_Tool.Draw or App.active_tool == e_Tool.Select then
		local cell_x = Util.GetCellX()
		local cell_y = Util.GetCellY()
		local diff_x = cell_x - App.last_clicked[1].offset + 1
		
		local base_pitch_min = App.instrument[App.num_strings - 3].open[App.num_strings - App.last_clicked[1].string_idx]
		local base_pitch_max = base_pitch_min + 24
		local diff_y = Util.Clamp(App.last_clicked[1].string_idx - cell_y, -(App.last_clicked[1].pitch - base_pitch_min), base_pitch_max - App.last_clicked[1].pitch)
		App.note_list[App.last_clicked[1].idx].pitch = App.last_clicked[1].pitch + diff_y
		
		for i, note in ipairs(App.note_list) do
			if note.selected then
				-- duration
				local nearest = Util.GetCellNearestOccupied(note.offset, note.string_idx, e_Direction.Right)
				if cell_x >= App.last_clicked[1].offset then
					note.duration = Util.Clamp(diff_x, 1, nearest - note.offset)
					-- note.duration = Util.Clamp(cell_x - note.offset + 1, 1, nearest - note.offset)
				end
				-- pitch
				local pitch_min = App.instrument[App.num_strings - 3].open[App.num_strings - note.string_idx]
				local pitch_max = pitch_min + 24
				note.pitch = note.pitch + note.string_idx - diff_y
				
				-- local diff_y = Util.Clamp(note.string_idx - cell_y, -(App.last_clicked[1].pitch - pitch_min), pitch_max - App.last_clicked[1].pitch)
				-- note.pitch = App.last_clicked[1].pitch + diff_y
				-- local diff_y = Util.Clamp(note.string_idx - cell_y, -(App.last_clicked[1].pitch - pitch_min), pitch_max - App.last_clicked[1].pitch)
				
			end
		end
	end
	
	if App.active_tool == e_Tool.Move then
		local cell_x = Util.GetCellX()
		local cell_y = Util.GetCellY()
		
		local diff_x = cell_x - App.last_clicked[1].offset
		local diff_y = cell_y - App.last_clicked[1].string_idx
		
		for i, note in ipairs(App.note_list) do
			if note.selected and cell_y >= 0 and cell_y < App.num_strings then
				-- move TODO When moving to different string, try to match the note's pitch. eg: E3 moving to a lower string could be found on a higher fret.
				-- If this is not possible, try to match an octave lower
				note.offset = note.offset + diff_x
				note.string_idx = Util.Clamp(note.string_idx + diff_y, 0, App.num_strings - 1)
			end
		end
	end
end

function Editor.OnDrag2()
	if App.last_clicked[1] == nil then return; end
	
	local cell_x = Util.GetCellX()
	local cell_y = Util.GetCellY()
	local diff_y = Util.Clamp(App.last_clicked[1].string_idx - cell_y, 0, 127)
	App.note_list[App.last_clicked[1].idx].velocity = diff_y
end