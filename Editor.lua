Editor = {}

function Editor.OnMouseButtonClick(mbutton, cx, cy)
	if App.attempts_paste then
		if mbutton == e_MouseButton.Left and Util.IsCellEmpty(cx, cy, true) then
			Clipboard.Paste(cx, cy)
		end
		return
	end
	
	App.can_init_drag = true
	App.last_click_was_inside_editor = true
	
	if mbutton == e_MouseButton.Left or mbutton == e_MouseButton.Right then
		if Util.IsCellEmpty(cx, cy, true) then
			Util.ClearTable(App.note_list_selected)
			Util.ClearTable(App.note_list_selected.indices)
			App.last_note_clicked = nil
			
			if App.active_tool == e_Tool.Draw then
				Editor.InsertNote(cx, cy)
			end
		else
			if (App.active_tool == e_Tool.Select) or (App.active_tool == e_Tool.Move) or (App.active_tool == e_Tool.Draw) then
				Editor.SelectNotes(cx, cy)
				Editor.PlayNote()
			elseif App.active_tool == e_Tool.Erase then
				Editor.EraseNotes(cx, cy)
			end
		end
	end
end

function Editor.OnMouseButtonRelease(mbutton)
	App.begin_marquee = false
	
	if App.last_click_was_inside_editor then
		App.can_init_drag = false
		App.last_click_was_inside_editor = false
		
		if mbutton == e_MouseButton.Left or mbutton == e_MouseButton.Right then
			Editor.StopNote()
			App.last_note_clicked = nil
			
			if #App.note_list_selected > 0 and not (App.is_new_note) then
				if UR.last_op == e_OpType.ModifyPitchAndDuration then
					UR.PushUndo(e_OpType.ModifyPitchAndDuration, App.note_list_selected)
				elseif UR.last_op == e_OpType.ModifyVelocityAndOffVelocity then
					UR.PushUndo(e_OpType.ModifyVelocityAndOffVelocity, App.note_list_selected)
				elseif UR.last_op == e_OpType.Move then
					UR.PushUndo(e_OpType.Move, App.note_list_selected)
				end
			end
			
			App.is_new_note = false
			Util.UpdateSelectedNotes()
			UR.last_op = e_OpType.NoOp
		end
	end
end

function Editor.OnMouseButtonDrag(mbutton)
	local cx = Util.GetCellX()
	local cy = Util.GetCellY()

	if App.last_click_was_inside_editor then
		if App.mouse_x > App.editor_win_x + App.window_w - App.scroll_margin then
			App.scroll_x = App.scroll_x + ((App.mouse_x - (App.editor_win_x + App.window_w - App.scroll_margin)) * App.scroll_speed)
			reaper.ImGui_SetScrollX(App.ctx, App.scroll_x)
		end
		
		if App.mouse_x < App.editor_win_x + App.left_margin + App.scroll_margin then
			App.scroll_x = App.scroll_x - ((App.editor_win_x + App.left_margin + App.scroll_margin - App.mouse_x) * App.scroll_speed)
			reaper.ImGui_SetScrollX(App.ctx, App.scroll_x)
		end
		
		if mbutton == e_MouseButton.Left and App.active_tool == e_Tool.Select then
			if not (App.begin_marquee) and App.last_note_clicked == nil then
				App.marquee_box.x1 = App.mouse_x
				App.marquee_box.y1 = App.mouse_y
				App.begin_marquee = true
			end
			
			if App.begin_marquee then
				Editor.MarqueeSelectNotes(cx, cy)
			end
		end
	end
	
	if App.last_note_clicked == nil then return; end
	App.can_init_drag = false
	
	-- dx/dy = difference from initial pos
	local dx = cx - App.last_note_clicked.duration - App.last_note_clicked.offset + 1
	local dy = App.last_note_clicked.string_idx - cy
	
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

function Editor.MarqueeSelectNotes(cx, cy)
	Util.ClearTable(App.note_list_selected)
	Util.ClearTable(App.note_list_selected.indices)
	
	local start_x = math.min(App.marquee_box.x1, App.marquee_box.x2)
	local start_y = math.min(App.marquee_box.y1, App.marquee_box.y2)
	local end_x = math.max(App.marquee_box.x1, App.marquee_box.x2)
	local end_y = math.max(App.marquee_box.y1, App.marquee_box.y2)
	
	local cell_x_min = math.floor((start_x - App.editor_win_x + App.scroll_x -15) / App.note_w) - 1
	local cell_y_min = math.floor((start_y - App.editor_win_y - App.top_margin + 5) / App.note_h)
	local cell_x_max = math.floor((end_x - App.editor_win_x + App.scroll_x -15) / App.note_w) - 1
	local cell_y_max = math.floor((end_y - App.editor_win_y - App.top_margin + 5) / App.note_h)
	
	for i, v in ipairs(App.note_list) do
		if not (Util.IsNoteAtCellSelected(v.offset, v.string_idx)) then
			if Util.RangeOverlap(v.offset, v.offset + v.duration - 1, cell_x_min, cell_x_max) and Util.RangeOverlap(v.string_idx, v.string_idx, cell_y_min, cell_y_max) then	
				App.note_list_selected[#App.note_list_selected + 1] = Util.CopyNote(v)
				App.note_list_selected.indices[#App.note_list_selected.indices + 1] = i
			end
		end
	end
end

function Editor.SelectNotes(cx, cy)
	for i, note in ipairs(App.note_list) do
		if (cx >= note.offset) and (cx < note.offset + note.duration) and (cy == note.string_idx) then
			if reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Key_ModCtrl()) then
				if not (Util.IsNoteAtCellSelected(note.offset, note.string_idx)) then
					App.note_list_selected[#App.note_list_selected + 1] = Util.CopyNote(note)
					App.note_list_selected.indices[#App.note_list_selected.indices + 1] = i
				end
			else
				if not (Util.IsNoteAtCellSelected(note.offset, note.string_idx)) then
					Util.ClearTable(App.note_list_selected)
					Util.ClearTable(App.note_list_selected.indices)
					App.note_list_selected[#App.note_list_selected + 1] = Util.CopyNote(note)
					App.note_list_selected.indices[#App.note_list_selected.indices + 1] = i
				end
			end
			App.last_note_clicked = Util.CopyNote(note)
			App.last_note_clicked.idx = i
			App.current_pitch = App.last_note_clicked.pitch
		end
	end
end

function Editor.InsertNote(cx, cy)
	local recent_pitch = App.instrument[App.num_strings - 3].recent[App.num_strings - cy]
	local new_note = {offset = cx, string_idx = cy, pitch = recent_pitch, velocity = App.default_velocity, off_velocity = App.default_off_velocity, duration = 1}
	App.note_list[#App.note_list + 1] = new_note
	App.note_list_selected[#App.note_list_selected + 1] = Util.CopyNote(new_note)
	App.note_list_selected.indices[#App.note_list_selected.indices + 1] = #App.note_list
	App.last_note_clicked = Util.CopyNote(new_note)
	App.last_note_clicked.idx = #App.note_list
	App.current_pitch = App.last_note_clicked.pitch
	Editor.PlayNote()
	-- push undo here
	UR.PushUndo(e_OpType.Insert, {new_note})
	App.is_new_note = true
	UR.last_op = e_OpType.Insert
end

function Editor.EraseNotes(cx, cy)
	if Util.IsNoteAtCellSelected(cx, cy) then
		-- push undo here (multiple)
		UR.PushUndo(e_OpType.Delete, App.note_list_selected)
		
		for i, v in ipairs(App.note_list_selected) do
			local idx = Util.GetNoteIndexAtCell(v.offset, v.string_idx)
			table.remove(App.note_list, idx)
		end
	else
		local idx = Util.GetNoteIndexAtCell(cx, cy)
		-- push undo here (single)
		UR.PushUndo(e_OpType.Delete, {App.note_list[idx]})
		table.remove(App.note_list, idx)
	end
	
	UR.last_op = e_OpType.Delete
	Util.ClearTable(App.note_list_selected)
	Util.ClearTable(App.note_list_selected.indices)
end

function Editor.MoveNotes(cx, cy, dx, dy)
	if dx ~= 0 or dy ~= 0 then
		local all_fit = true
		local base_diff = dx + App.last_note_clicked.duration - 1
		local leftmost = Util.NumGridDivisions(); local topmost = App.num_strings - 1; local rightmost = 0; local bottommost = 0
		
		for i, v in ipairs(App.note_list_selected) do
			local idx = App.note_list_selected.indices[i]
			if App.note_list[idx].offset < leftmost then leftmost = App.note_list[idx].offset; end
			if App.note_list[idx].offset + App.note_list[idx].duration - 1 > rightmost then rightmost = App.note_list[idx].offset + App.note_list[idx].duration - 1; end
			if App.note_list[idx].string_idx < topmost then topmost = App.note_list[idx].string_idx; end
			if App.note_list[idx].string_idx > bottommost then bottommost = App.note_list[idx].string_idx; end
			
			if not Util.IsNewPositionOnStringEmpty(App.note_list_selected.indices[i], v.offset + base_diff, v.string_idx - dy) then
				all_fit = false
				break
			end
		end
		
		local base_x = App.note_list[App.last_note_clicked.idx].offset
		local base_y = App.note_list[App.last_note_clicked.idx].string_idx
		local l_bound = base_x - leftmost
		local r_bound = Util.NumGridDivisions() - rightmost + base_x
		local t_bound = base_y - topmost
		local b_bound = App.num_strings - bottommost + base_y
		
		if all_fit then
			if cx >= l_bound and cx < r_bound and cy >= t_bound and cy < b_bound then
				for i, v in ipairs(App.note_list_selected) do
					local idx = App.note_list_selected.indices[i]
					App.note_list[idx].offset = v.offset + dx + App.last_note_clicked.duration - 1
					
					local dst_string_idx = Util.Clamp(v.string_idx - dy, 0, App.num_strings - 1)
					Util.ShiftOctaveIfOutsideRange(App.note_list[idx], dst_string_idx)
					App.note_list[idx].string_idx = dst_string_idx
				end
			end
			
			UR.last_op = e_OpType.Move
		end
	else
		UR.last_op = e_OpType.NoOp
	end
end

function Editor.ModifyPitchAndDuration(cx, cy, dx, dy)
	if dx ~= 0 or dy ~= 0 then
		for i, v in ipairs(App.note_list_selected) do
			
			-- duration
			local idx = Util.GetNoteIndexAtCell(v.offset, v.string_idx)
			
			local nearest = Util.GetCellNearestOccupied(App.note_list[idx].offset, App.note_list[idx].string_idx, e_Direction.Right)
			if cx >= App.last_note_clicked.offset then
				App.note_list[idx].duration = Util.Clamp(v.duration + dx, 1, nearest - App.note_list[idx].offset)
			end
			-- pitch
			local pitch_min = App.instrument[App.num_strings - 3].open[App.num_strings - App.note_list[idx].string_idx]
			local pitch_max = pitch_min + 24
			App.note_list[idx].pitch = Util.Clamp(v.pitch + dy, pitch_min, pitch_max)
			Util.UpdateRecentPitch(App.num_strings - v.string_idx, App.note_list[idx].pitch)
		end
		
		local idx = Util.GetNoteIndexAtCell(App.last_note_clicked.offset, App.last_note_clicked.string_idx)
		
		if App.current_pitch ~= App.note_list[idx].pitch then
			Editor.StopNote()
			App.current_pitch = App.note_list[idx].pitch
			Editor.PlayNote()
		end
		
		UR.last_op = e_OpType.ModifyPitchAndDuration
	else
		UR.last_op = e_OpType.NoOp
	end
end

function Editor.ModifyVelocityAndOffVelocity(cx, cy, dx, dy)
	if dy ~= 0 then
		for i, v in ipairs(App.note_list_selected) do
			local idx = Util.GetNoteIndexAtCell(v.offset, v.string_idx)
			
			if reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Key_ModShift()) then
				App.note_list[idx].off_velocity = Util.Clamp(v.off_velocity + dy, 0, 127)
			else
				App.note_list[idx].velocity = Util.Clamp(v.velocity + dy, 0, 127)
			end
		end
		
		UR.last_op = e_OpType.ModifyVelocityAndOffVelocity
	else
		UR.last_op = e_OpType.NoOp
	end
end

function Editor.PlayNote()
	if App.last_note_clicked == nil or App.audition_notes == false then return; end
	reaper.StuffMIDIMessage(0, 0x90, App.current_pitch, App.last_note_clicked.velocity)
end

function Editor.StopNote()
	if App.last_note_clicked == nil or App.audition_notes == false then return; end
	reaper.StuffMIDIMessage(0, 0x80, App.current_pitch, App.last_note_clicked.velocity)
end
