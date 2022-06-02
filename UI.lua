UI = {}

function UI.Render_Notes(draw_list)
	local note_x
	local note_y
	local str
	
	for i, note in ipairs(App.note_list) do
		if note.string_idx < App.num_strings then -- When switching from higher string count instrument to a lower one, notes are kept but hidden
			note_x = App.editor_win_x + 50 + (note.offset * App.note_w) - App.scroll_x
			note_y = App.editor_win_y + 30 + (note.string_idx * App.note_h) - 5
			
			reaper.ImGui_DrawList_AddRectFilled(draw_list, note_x, note_y, note_x + (App.note_w * note.duration) -1, note_y + App.note_h - 1, Util.VelocityColor(note.velocity), 6)
			if App.note_display_cur_idx == e_NoteDisplay.Pitch then
				str = Util.NotePitchToName(note.pitch)
			elseif App.note_display_cur_idx == e_NoteDisplay.Fret then
				str = Util.NotePitchToFret(note.pitch, note.string_idx)
			elseif App.note_display_cur_idx == e_NoteDisplay.PitchAndFret then -- display pitch + fret. Only if duration > 1. If duration == 1, just display the pitch
				if App.swap_pitchfret_order then
					str = Util.NotePitchToFret(note.pitch, note.string_idx)
					if note.duration > 1 then str = str .. "," .. Util.NotePitchToName(note.pitch); end
				else
					str = Util.NotePitchToName(note.pitch)
					if note.duration > 1 then str = str .. "," .. Util.NotePitchToFret(note.pitch, note.string_idx); end
				end
			elseif App.note_display_cur_idx == e_NoteDisplay.Velocity then
				str = note.velocity
			elseif App.note_display_cur_idx == e_NoteDisplay.OffVelocity then
				str = note.off_velocity
			elseif App.note_display_cur_idx == e_NoteDisplay.MIDIPitch then
				str = note.pitch
			end
			reaper.ImGui_DrawList_AddText(draw_list, note_x + 5, note_y - 2, Colors.text, str)
			
			if Util.IsNoteSelected(i) then
				reaper.ImGui_DrawList_AddRect(draw_list, note_x, note_y, note_x + (App.note_w * note.duration) - 1, note_y + App.note_h - 1, Colors.text, 40, reaper.ImGui_DrawFlags_None(), 1)
			end
		end
	end
end

function UI.Render_CB_Strings()
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_strings_w)
	
	if reaper.ImGui_BeginCombo(App.ctx, "Strings##cb_strings", App.num_strings) then
		for i = 4, 9 do
			if reaper.ImGui_Selectable(App.ctx, i, App.num_strings == i) then App.num_strings = i; end
		end
		reaper.ImGui_EndCombo(App.ctx)
	end
end

function UI.Render_CB_Signature()
	Util.HorSpacer(3)
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_signature_w)
	if reaper.ImGui_BeginCombo(App.ctx, "Signature##cb_signature", App.signature[App.signature_cur_idx].caption, reaper.ImGui_ComboFlags_HeightLarge()) then
		for i = 1, 11 do
			if reaper.ImGui_Selectable(App.ctx, App.signature[i].caption, App.signature_cur_idx == i) then App.signature_cur_idx = i; end
		end
		reaper.ImGui_EndCombo(App.ctx)
	end
end

function UI.Render_CB_Quantize()
	Util.HorSpacer(3)
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_quantize_w)
	if reaper.ImGui_BeginCombo(App.ctx, "Quantize##cb_quantize", App.quantize[App.quantize_cur_idx]) then
		for i = 1, 7 do
			if reaper.ImGui_Selectable(App.ctx, App.quantize[i], App.quantize_cur_idx == i) then App.quantize_cur_idx = i; end
		end
		reaper.ImGui_EndCombo(App.ctx)
	end
end

function UI.Render_SI_Measures()
	Util.HorSpacer(3)
	reaper.ImGui_SetNextItemWidth(App.ctx, App.si_measures_w)
	local ret, val = reaper.ImGui_SliderInt(App.ctx, "Measures##si_measures", App.num_measures, 1, 64)
	App.num_measures = Util.Clamp(val, 1, 64)
end

function UI.Render_CB_NoteDisplay()
	Util.HorSpacer(3)
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_note_sisplay_w)
	if reaper.ImGui_BeginCombo(App.ctx, "Note Display##cb_note_display", App.note_display[App.note_display_cur_idx]) then
		for i = 1, 6 do
			if reaper.ImGui_Selectable(App.ctx, App.note_display[i], App.note_display_cur_idx == i) then App.note_display_cur_idx = i; end
		end
		reaper.ImGui_EndCombo(App.ctx)
	end
end

function UI.Render_BTN_Settings()
	Util.HorSpacer(3)
	if reaper.ImGui_Button(App.ctx, "Settings...##btn_settings") then
		reaper.ImGui_OpenPopup(App.ctx, "Settings##win_settings")
	end
	
	local pwin_x, pwin_y = reaper.ImGui_GetWindowPos(App.ctx)
	local pwin_w, pwin_h = reaper.ImGui_GetWindowSize(App.ctx)
	reaper.ImGui_SetNextWindowPos(App.ctx, pwin_x + (pwin_w / 2) - 180, pwin_y + (pwin_h / 2) - 100)
	
	if reaper.ImGui_BeginPopupModal(App.ctx, "Settings##win_settings", true,  reaper.ImGui_WindowFlags_AlwaysAutoResize()) then
		local _, set_audition_notes = reaper.ImGui_Checkbox(App.ctx, "Audition notes on entry/selection", App.audition_notes)
		App.audition_notes = set_audition_notes
		
		local _, set_swap_pitchfret_order =  reaper.ImGui_Checkbox(App.ctx, "Swap order of Pitch&Fret note display", App.swap_pitchfret_order)
		App.swap_pitchfret_order = set_swap_pitchfret_order
		
		local _, set_default_velocity = reaper.ImGui_SliderInt(App.ctx, "Default note velocity", App.default_velocity, 0, 127)
		App.default_velocity = set_default_velocity
		
		local _, set_default_off_velocity = reaper.ImGui_SliderInt(App.ctx, "Default note off-velocity", App.default_off_velocity, 0, 127)
		App.default_off_velocity = set_default_off_velocity
		reaper.ImGui_EndPopup(App.ctx)
	end
end

function UI.Render_TXT_Help()
	Util.HorSpacer(3)
	reaper.ImGui_TextDisabled(App.ctx, "(?)")
	
	if reaper.ImGui_IsItemHovered(App.ctx) then
		reaper.ImGui_BeginTooltip(App.ctx)
		
		reaper.ImGui_Text(App.ctx,
		"Shortcuts:\n" ..
		"Select tool (S)\n" ..
		"Move tool (W)\n" ..
		"Draw tool (D)\n" ..
		"Erase tool (E)\n" ..
		"Undo (Ctrl + Z)\n" ..
		"Redo (Ctrl + Shift + Z)\n" ..
		"Cut (Ctrl + X)\n" ..
		"Copy (Ctrl + C)\n" ..
		"Paste (Ctrl + V)\n\n" ..
		"Usage:\n" ..
		"Left Click with the Draw tool to insert a note.\n" ..
		"Left Click + Drag horizontally to set duration \n" ..
		"Left Click + Drag vertically to set pitch\n" ..
		"Right Click + Drag vertically to set velocity\n" ..
		"Right Click + Shift + Drag to set off-velocity\n" ..
		"Left Click + Ctrl to select multiple notes\n" ..
		"The same actions can be performed with the Select tool, when clicking on existing notes.\n" ..
		"Click + Drag in an empty area with the Select tool to marquee-select notes.\n\n" ..
		"Click on the Create MIDI button to generate a MIDI item on the selected track, at cursor position (WIP)")
		
		reaper.ImGui_EndTooltip(App.ctx)
	end
end

function UI.Render_Toolbar()
	if reaper.ImGui_BeginChild(App.ctx, "Toolbar##win_toolbar", App.window_w, 20, false, reaper.ImGui_WindowFlags_NoScrollbar()) then
		reaper.ImGui_PushStyleColor(App.ctx, reaper.ImGui_Col_Button(), Colors.bg)
		for i = 1, 10 do
			reaper.ImGui_PushFont(App.ctx, App.icon_font)
			
			if i == App.active_tool then
				reaper.ImGui_PushStyleColor(App.ctx, reaper.ImGui_Col_Text(), Colors.active_tool)
			else
				reaper.ImGui_PushStyleColor(App.ctx, reaper.ImGui_Col_Text(), Colors.text)
			end
			if reaper.ImGui_Button(App.ctx, ToolBar[i].icon .. "##toolbar_button" .. i) then
				if i >= e_Tool.Select and i <= e_Tool.Erase then -- only the note editing tools can be active
					App.active_tool = i
				elseif i == e_Tool.Create then
					Util.CreateMIDI()
				elseif i == e_Tool.Undo then
					UR.PopUndo()
				elseif i == e_Tool.Redo then
					UR.PopRedo()
				elseif i == e_Tool.Cut then
					Clipboard.Cut()
				elseif i == e_Tool.Copy then
					Clipboard.Copy()
				elseif i == e_Tool.Paste then
					if #Clipboard.note_list > 0 then App.attempts_paste = true; end
				end
			end
			reaper.ImGui_PopStyleColor(App.ctx)
			reaper.ImGui_PopFont(App.ctx)
			
			if reaper.ImGui_IsItemHovered(App.ctx) then
				reaper.ImGui_BeginTooltip(App.ctx)
				reaper.ImGui_Text(App.ctx, ToolBar[i].tooltip)
				reaper.ImGui_EndTooltip(App.ctx)
			end
			
			reaper.ImGui_SameLine(App.ctx)
			if i == e_Tool.Create or i == e_Tool.Erase then
				Util.HorSpacer(3)
			end
		end
		reaper.ImGui_PopStyleColor(App.ctx)
		reaper.ImGui_EndChild(App.ctx)
	end
end

function UI.Render_Editor()
	App.editor_h = 50 + ((App.num_strings) * 12)
	local num_grid_divisions = Util.NumGridDivisions()
	local lane_w = num_grid_divisions * App.grid_w
	reaper.ImGui_SetNextWindowContentSize(App.ctx, lane_w + 45, App.editor_h - 20)
	if reaper.ImGui_BeginChild(App.ctx, "Editor##win_editor", App.window_w - App.window_indent, App.editor_h, true, reaper.ImGui_WindowFlags_HorizontalScrollbar() | reaper.ImGui_WindowFlags_NoMove()) then
		
		local draw_list = reaper.ImGui_GetWindowDrawList(App.ctx)
		App.scroll_x = reaper.ImGui_GetScrollX(App.ctx)
		App.editor_win_x, App.editor_win_y = reaper.ImGui_GetWindowPos(App.ctx)
		
		-- Scroll horizontally with mousewheel without holding SHIFT
		-- Works good on my desktop, but has issues on my laptop's trackpad
		-- Comment this block to scroll with SHIFT
		local mw = reaper.ImGui_GetMouseWheel(App.ctx)
		App.scroll_x = App.scroll_x - mw * App.wheel_delta
		reaper.ImGui_SetScrollX(App.ctx, App.scroll_x)
		App.scroll_x = reaper.ImGui_GetScrollX(App.ctx) -- get back clamped value from ImGui
		
		local lane_start_x = App.editor_win_x + App.left_margin - App.scroll_x
		local lane_end_x = lane_start_x + lane_w
		
		-- Lanes
		for i = 0, App.num_strings - 1 do
			reaper.ImGui_DrawList_AddLine(draw_list, lane_start_x, App.editor_win_y + App.top_margin + (i * App.lane_v_spacing), lane_end_x, App.editor_win_y + App.top_margin + (i * App.lane_v_spacing), Colors.lane)
		end
		
		-- Measures & beats lines and legends
		local measure_count = 1
		local beat_count = 1
		
		for i = 0, num_grid_divisions do
			if i % App.signature[App.signature_cur_idx].subs == 0 then
				
				if (i ~= 0 and i % (App.signature[App.signature_cur_idx].beats * App.signature[App.signature_cur_idx].subs) == 0) then
					reaper.ImGui_DrawList_AddLine(draw_list, App.editor_win_x + App.left_margin + (App.grid_w * i) - App.scroll_x, App.editor_win_y + App.top_margin, App.editor_win_x + App.left_margin + (App.grid_w * i) - App.scroll_x, App.editor_win_y + App.top_margin + ((App.num_strings - 1) * 12), Colors.lane)
					measure_count = measure_count + 1
					beat_count = 1
				end
				
				if i ~= num_grid_divisions then
					local txt = measure_count .. "-" .. beat_count
					reaper.ImGui_DrawList_AddTextEx(draw_list, nil, 11, App.editor_win_x + App.left_margin + (App.grid_w * i) - App.scroll_x, App.editor_win_y + App.top_margin - 20, Colors.text, txt)
					beat_count = beat_count + 1
				end
				
			else
				reaper.ImGui_DrawList_AddLine(draw_list, App.editor_win_x + App.left_margin + (App.grid_w * i) - App.scroll_x, App.editor_win_y + App.top_margin - 17, App.editor_win_x + App.left_margin + (App.grid_w * i) - App.scroll_x, App.editor_win_y + App.top_margin - 12, Colors.lane)
			end
		end
		
		-- Notes
		UI.Render_Notes(draw_list)
		
		-- Capture the boundaries of editor area and display note preview
		local rect_x1 = App.editor_win_x + App.left_margin
		local rect_y1 = App.editor_win_y + App.top_margin - 5
		local rect_x2 = lane_end_x - 1
		local rect_y2 = rect_y1 + 11 + (App.num_strings - 1) * App.lane_v_spacing
		
		-- debug draw editor mouse area
		-- reaper.ImGui_DrawList_AddRect(draw_list, rect_x1, rect_y1, rect_x2, rect_y2, Colors.red)
		
		if reaper.ImGui_IsWindowHovered(App.ctx) then
			local cell_x = Util.GetCellX()
			local cell_y = Util.GetCellY()
			
			if App.mouse_x > rect_x1 and App.mouse_x < rect_x2  and App.mouse_y > rect_y1 and App.mouse_y < rect_y2  then
				if Util.IsCellEmpty(cell_x, cell_y, true) then
					if App.attempts_paste then
						-- reaper.ImGui_DrawList_AddLine(draw_list, preview_x, App.editor_win_y + App.top_margin, preview_x, App.editor_win_y + App.top_margin + ((App.num_strings - 1) * App.lane_v_spacing), Colors.red)
						local leftmost = Clipboard.note_list[1].offset
						
						for i, v in ipairs(Clipboard.note_list) do
							local cur_x = App.editor_win_x + App.left_margin + ((v.offset + cell_x - leftmost) * App.note_w) - App.scroll_x
							local cur_y = App.editor_win_y + App.top_margin + (v.string_idx * App.note_h) - 5
							reaper.ImGui_DrawList_AddRectFilled(draw_list, cur_x, cur_y, cur_x + (v.duration * App.note_w) - 1, cur_y + App.note_h - 1, Colors.note_preview_paste, 40)
						end
						reaper.ImGui_BeginTooltip(App.ctx)
						reaper.ImGui_Text(App.ctx, "Select position to paste. [ESC] to cancel")
						reaper.ImGui_EndTooltip(App.ctx)
					else
						if not (App.begin_marquee) then
							local preview_x = App.editor_win_x + App.left_margin + (cell_x * App.note_w) - App.scroll_x
							local preview_y = App.editor_win_y + App.top_margin + (cell_y * App.note_h) - 5
							reaper.ImGui_DrawList_AddRectFilled(draw_list, preview_x, preview_y, preview_x + App.note_w - 1, preview_y + App.note_h - 1, Colors.note_preview, 40)
						end
					end
				end
				if reaper.ImGui_IsMouseClicked(App.ctx, 0) then
					Editor.OnMouseButtonClick(e_MouseButton.Left, cell_x, cell_y)
				end
				if reaper.ImGui_IsMouseClicked(App.ctx, 1) then
					Editor.OnMouseButtonClick(e_MouseButton.Right, cell_x, cell_y)
				end
			end
		end
		
		-- These have prob have to go out of the drawing function
		if reaper.ImGui_IsMouseReleased(App.ctx, 0) then
			Editor.OnMouseButtonRelease(e_MouseButton.Left)
		end
		
		if reaper.ImGui_IsMouseReleased(App.ctx, 1) then
			Editor.OnMouseButtonRelease(e_MouseButton.Right)
		end
		
		if reaper.ImGui_IsMouseDragging(App.ctx, 0) then
			Editor.OnMouseButtonDrag(e_MouseButton.Left)
		end
		
		if reaper.ImGui_IsMouseDragging(App.ctx, 1) then
			Editor.OnMouseButtonDrag(e_MouseButton.Right)
		end
		
		-- Mask rect
		reaper.ImGui_DrawList_AddRectFilled(draw_list, App.editor_win_x, App.editor_win_y + 2, App.editor_win_x + App.left_margin, App.editor_win_y + 140, Colors.bg)
		
		-- String legends
		for i = 0, App.num_strings - 1 do
			local str = App.instrument[App.num_strings - 3][App.num_strings - i]
			local len = string.len(str)
			local space
			if len == 2 then space = "  " else space = " " end
			reaper.ImGui_DrawList_AddText(draw_list, App.editor_win_x + 8, App.editor_win_y + 23 + (i * App.lane_v_spacing), Colors.text, str .. space .. "*")
		end
		
		-- Marquee box
		if App.begin_marquee then
			App.marquee_box.x2 = App.mouse_x
			App.marquee_box.y2 = App.mouse_y
			
			reaper.ImGui_DrawList_AddRectFilled(draw_list, App.marquee_box.x1, App.marquee_box.y1, App.marquee_box.x2, App.marquee_box.y2, Colors.marquee_box)
			-- msg(App.marquee_box.x1 .. " , " .. App.marquee_box.y1 .. ", " .. App.marquee_box.x2 .. " , " .. App.marquee_box.y2)
		end
		
		reaper.ImGui_EndChild(App.ctx)
	end
end