Editor = {}

function Editor.SelectNotes(cx, cy)
	for i, note in ipairs(App.note_list) do
		if (cx >= note.offset) and (cx < note.offset + note.duration) and (cy == note.string_idx) then
			if reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Key_ModCtrl()) then
				App.note_list_selected[#App.note_list_selected + 1] = Util.CopyNote(note)
			else
				if not Util.IsNoteSelected(note) then
					Util.ClearTable(App.note_list_selected)
					App.note_list_selected[#App.note_list_selected + 1] = Util.CopyNote(note)
				end
			end
			App.last_note_clicked[1] = Util.CopyNote(note)
		end
	end
end

function Editor.OnMouseButtonClick(mbutton, cx, cy)
	App.can_init_drag = true
	
	if mbutton == e_MouseButton.Left or mbutton == e_MouseButton.Right then
		if Util.IsCellEmpty(cx, cy, true) then
			Util.ClearTable(App.note_list_selected)
			App.last_note_clicked[1] = nil
			
			if App.active_tool == e_Tool.Draw then
				Editor.InsertNote(cx, cy)
			end
		else
			if (App.active_tool == e_Tool.Select) or (App.active_tool == e_Tool.Move) or (App.active_tool == e_Tool.Draw) then
				Editor.SelectNotes(cx, cy)
			elseif App.active_tool == e_Tool.Erase then
				Editor.EraseNotes(cx, cy)
			end
		end
	end
end

function Editor.OnMouseButtonRelease(mbutton)
	App.can_init_drag = false
	
	if mbutton == e_MouseButton.Left or mbutton == e_MouseButton.Right then
		App.last_note_clicked[1] = nil
		Util.UpdateSelectedNotes()
	end
end

function Editor.OnMouseButtonDrag(mbutton)
	if App.last_note_clicked[1] == nil then return; end
	App.can_init_drag = false
	
	-- cx/cy = current pos, dx/dy = difference from initial pos
	local cx = Util.GetCellX()
	local cy = Util.GetCellY()
	local dx = cx - App.last_note_clicked[1].duration - App.last_note_clicked[1].offset + 1
	local dy = App.last_note_clicked[1].string_idx - cy

	if mbutton == e_MouseButton.Left then
		
		if App.active_tool == e_Tool.Draw or App.active_tool == e_Tool.Select then
			Editor.ModifyPitchAndDuration(cx, cy, dx, dy)
		elseif App.active_tool == e_Tool.Move then
			Editor.MoveNotes(cx, cy, dx, dy)
		end
	elseif mbutton == e_MouseButton.Right then
		Editor.ModifyVelocityAndOffVelocity(cx, cy, dx, dy)
	end
end

function Editor.InsertNote(cx, cy)
	local open_pitch = App.instrument[App.num_strings - 3].open[App.num_strings - cy]
	local new_note = {idx = #App.note_list + 1, offset = cx, string_idx = cy, pitch = open_pitch, velocity = 127, duration = 1}
	App.note_list[#App.note_list + 1] = new_note
	App.note_list_selected[#App.note_list_selected + 1] = Util.CopyNote(new_note)
	App.last_note_clicked[1] = Util.CopyNote(new_note)
	-- do push undo here
end

function Editor.EraseNotes(cx, cy)
	if Util.IsNoteAtCellSelected(cx, cy) then	
		table.sort(App.note_list_selected, function (k1, k2) return k1.idx < k2.idx; end)
		local len = #App.note_list_selected
		for i = len, 1, -1 do
			table.remove(App.note_list, App.note_list_selected[i].idx)
		end
	else
		table.remove(App.note_list, Util.GetNoteIndexAtCell(cx, cy))
	end
end

function Editor.MoveNotes(cx, cy, dx, dy)
	for i, v in ipairs(App.note_list_selected) do
		if cy >= 0 and cy < App.num_strings then
			-- move TODO When moving to different string, try to match the note's pitch. eg: E3 moving to a lower string could be found on a higher fret.
			-- If this is not possible, try to match an octave lower.
			-- Also, restrict movement when even a single note overlaps another
			App.note_list[v.idx].offset = v.offset + dx
			App.note_list[v.idx].string_idx = Util.Clamp(v.string_idx - dy, 0, App.num_strings - 1)
		end
	end
end

function Editor.ModifyPitchAndDuration(cx, cy, dx, dy)
	for i, v in ipairs(App.note_list_selected) do
		-- duration
		local nearest = Util.GetCellNearestOccupied(App.note_list[v.idx].offset, App.note_list[v.idx].string_idx, e_Direction.Right)
		if cx >= App.last_note_clicked[1].offset then
			App.note_list[v.idx].duration = Util.Clamp(v.duration + dx, 1, nearest - App.note_list[v.idx].offset)
		end
		-- pitch
		local pitch_min = App.instrument[App.num_strings - 3].open[App.num_strings - App.note_list[v.idx].string_idx]
		local pitch_max = pitch_min + 24
		App.note_list[v.idx].pitch = Util.Clamp(v.pitch + dy, pitch_min, pitch_max)
	end
end

function Editor.ModifyVelocityAndOffVelocity(cx, cy, dx, dy)
	for i, v in ipairs(App.note_list_selected) do
		App.note_list[v.idx].velocity = v.velocity + dy
	end
end