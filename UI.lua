UI = {}

function UI.DrawNotes(draw_list)
	local note_x
	local note_y
	local selected
	
	for i, note in ipairs(App.note_list) do
		if note.string_idx < App.num_strings then -- When switching from higher string count instrument to a lower one, notes are kept but hidden
			note_x = App.arrange_win_x + 50 + (note.offset * App.note_w) - App.scroll_x
			note_y = App.arrange_win_y + 30 + (note.string_idx * App.note_h) - 5
			selected = note.selected
			reaper.ImGui_DrawList_AddRectFilled(draw_list, note_x, note_y, note_x + (App.note_w * note.duration) -1, note_y + App.note_h-1, Util.VelocityColor(note.velocity), 6)
			reaper.ImGui_DrawList_AddText(draw_list, note_x + 5, note_y - 2, Colors.text, Util.NotePitchToName(note.pitch))
			if selected then
				reaper.ImGui_DrawList_AddRect(draw_list, note_x, note_y, note_x + (App.note_w * note.duration) -1, note_y + App.note_h-1, Colors.text, 40, reaper.ImGui_DrawFlags_None(), 1)
			end
		end
	end
end

function UI.DrawCB_Strings()
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_strings_w)
	
	if reaper.ImGui_BeginCombo(App.ctx, "Strings##cb_strings", App.num_strings) then
		for i = 4, 9 do
			if reaper.ImGui_Selectable(App.ctx, i, App.num_strings == i) then App.num_strings = i; end
		end
		reaper.ImGui_EndCombo(App.ctx)
	end
end

function UI.DrawCB_Signature()
	Util.HorSpacer(3)
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_signature_w)
	if reaper.ImGui_BeginCombo(App.ctx, "Signature##cb_signature", App.signature[App.signature_cur_idx].caption, reaper.ImGui_ComboFlags_HeightLarge()) then
		for i = 1, 11 do
			if reaper.ImGui_Selectable(App.ctx, App.signature[i].caption, App.signature_cur_idx == i) then App.signature_cur_idx = i; end
		end
		reaper.ImGui_EndCombo(App.ctx)
	end
end

function UI.DrawCB_Quantize()
	Util.HorSpacer(3)
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_quantize_w)
	if reaper.ImGui_BeginCombo(App.ctx, "Quantize##cb_quantize", App.quantize[App.quantize_cur_idx]) then
		for i = 1, 7 do
			if reaper.ImGui_Selectable(App.ctx, App.quantize[i], App.quantize_cur_idx == i) then App.quantize_cur_idx = i; end
		end
		reaper.ImGui_EndCombo(App.ctx)
	end
end

function UI.DrawSI_Measures()
	Util.HorSpacer(3)
	reaper.ImGui_SetNextItemWidth(App.ctx, App.si_measures_w)
	local ret, val = reaper.ImGui_SliderInt(App.ctx, "Measures##si_measures", App.num_measures, 1, 64)
	App.num_measures = val
end

function UI.DrawTXT_Help()
	Util.HorSpacer(3)
	reaper.ImGui_TextDisabled(App.ctx, "(?)")
	
	if reaper.ImGui_IsItemHovered(App.ctx) then
		reaper.ImGui_BeginTooltip(App.ctx)
		reaper.ImGui_Text(App.ctx,
		"Help text,\n" ..
		"This is a comment yep")
		reaper.ImGui_EndTooltip(App.ctx)
	end
end

function UI.DrawToolbar()
	if reaper.ImGui_BeginChild(App.ctx, "Toolbar##win_toolbar", App.window_w, 20, false, reaper.ImGui_WindowFlags_NoScrollbar()) then
		reaper.ImGui_PushStyleColor(App.ctx, reaper.ImGui_Col_Button(), Colors.bg)
		for i = 1, 8 do
			reaper.ImGui_PushFont(App.ctx, App.icon_font)
			
			if i == App.active_tool then
				reaper.ImGui_PushStyleColor(App.ctx, reaper.ImGui_Col_Text(), Colors.active_tool)
			else
				reaper.ImGui_PushStyleColor(App.ctx, reaper.ImGui_Col_Text(), Colors.text)
			end
			if reaper.ImGui_Button(App.ctx, ToolBar[i].icon .. "##toolbar_button" .. i) then
				if i >= e_Tool.Select and i <= e_Tool.Erase then -- only the note tools can be active
					App.active_tool = i
				elseif i == e_Tool.Create then
					Util.CreateMIDI()
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

function UI.DrawArrange()
	App.arrange_h = 50 + ((App.num_strings) * 12)
	local lane_w = Util.NumGridDivisions() * App.grid_w
	reaper.ImGui_SetNextWindowContentSize(App.ctx, lane_w + 45, App.arrange_h - 20)
	if reaper.ImGui_BeginChild(App.ctx, "Arrange##win_arrange", App.window_w - App.window_indent, App.arrange_h, true, reaper.ImGui_WindowFlags_HorizontalScrollbar() | reaper.ImGui_WindowFlags_NoMove()) then
		
		local draw_list = reaper.ImGui_GetWindowDrawList(App.ctx)
		App.scroll_x = reaper.ImGui_GetScrollX(App.ctx)
		App.arrange_win_x, App.arrange_win_y = reaper.ImGui_GetWindowPos(App.ctx)
		
		-- Scroll horizontally with mousewheel
		local mw = reaper.ImGui_GetMouseWheel(App.ctx)
		App.scroll_x = App.scroll_x - mw * App.wheel_delta
		reaper.ImGui_SetScrollX(App.ctx, App.scroll_x)
		App.scroll_x = reaper.ImGui_GetScrollX(App.ctx) -- get back clamped value from ImGui
		
		local lane_start_x = App.arrange_win_x + App.left_margin - App.scroll_x
		local lane_end_x = lane_start_x + lane_w
		
		-- Lanes
		for i = 0, App.num_strings - 1 do
			reaper.ImGui_DrawList_AddLine(draw_list, lane_start_x, App.arrange_win_y + App.top_margin + (i * App.lane_v_spacing), lane_end_x, App.arrange_win_y + App.top_margin + (i * App.lane_v_spacing), Colors.lane)
		end
		
		-- Measures & beats lines and legends
		local measure_count = 1
		local beat_count = 1
		
		for i = 0, App.num_grid_divisions do
			if i % App.signature[App.signature_cur_idx].subs == 0 then
				
				if (i ~= 0 and i % (App.signature[App.signature_cur_idx].beats * App.signature[App.signature_cur_idx].subs) == 0) then
					reaper.ImGui_DrawList_AddLine(draw_list, App.arrange_win_x + App.left_margin + (App.grid_w * i) - App.scroll_x, App.arrange_win_y + App.top_margin, App.arrange_win_x + App.left_margin + (App.grid_w * i) - App.scroll_x, App.arrange_win_y + App.top_margin + ((App.num_strings - 1) * 12), Colors.lane)
					measure_count = measure_count + 1
					beat_count = 1
				end
				
				if i ~= App.num_grid_divisions then
					local txt = measure_count .. "-" .. beat_count
					reaper.ImGui_DrawList_AddTextEx(draw_list, nil, 11, App.arrange_win_x + App.left_margin + (App.grid_w * i) - App.scroll_x, App.arrange_win_y + App.top_margin - 20, Colors.text, txt)
					beat_count = beat_count + 1
				end
				
			else
				reaper.ImGui_DrawList_AddLine(draw_list, App.arrange_win_x + App.left_margin + (App.grid_w * i) - App.scroll_x, App.arrange_win_y + App.top_margin - 17, App.arrange_win_x + App.left_margin + (App.grid_w * i) - App.scroll_x, App.arrange_win_y + App.top_margin - 12, Colors.lane)
			end
		end
		
		-- Notes
		UI.DrawNotes(draw_list)
		
		-- Enter notes...
		local rect_x1 = App.arrange_win_x + App.left_margin
		local rect_y1 = App.arrange_win_y + App.top_margin - 5
		local rect_x2 = lane_end_x - 1
		local rect_y2 = rect_y1 + 11 + (App.num_strings - 1) * App.lane_v_spacing
		
		if reaper.ImGui_IsWindowHovered(App.ctx) then
			local cell_x = Util.GetCellX()
			local cell_y = Util.GetCellY()
			
			if App.mouse_x > rect_x1 and App.mouse_x < rect_x2  and App.mouse_y > rect_y1 and App.mouse_y < rect_y2  then	
				if Util.IsCellEmpty(cell_x, cell_y, true) then
					local preview_x = App.arrange_win_x + App.left_margin + (cell_x * App.note_w) - App.scroll_x
					local preview_y = App.arrange_win_y + App.top_margin + (cell_y * App.note_h) - 5
					reaper.ImGui_DrawList_AddRectFilled(draw_list, preview_x, preview_y, preview_x + App.note_w - 1, preview_y + App.note_h - 1, Colors.note_preview, 40)
				end
				if reaper.ImGui_IsMouseClicked(App.ctx, 0) then
					Editor.OnClick(cell_x, cell_y)
				end
			end
		end
		
		-- These have prob have to go out of the drawing function
		if reaper.ImGui_IsMouseReleased(App.ctx, 0) then
			Editor.OnRelease()
		end
		
		if reaper.ImGui_IsMouseDragging(App.ctx, 0) then
			Editor.OnDrag()
		end

		-- debug draw arrange mouse area
		-- reaper.ImGui_DrawList_AddRect(draw_list, lane_start_x, App.arrange_win_y + App.top_margin - 5, lane_end_x + 1, App.arrange_win_y+App.top_margin - 5 + 11 + ((App.num_strings - 1) * App.lane_v_spacing), Colors.red)
		
		-- Mask rect
		reaper.ImGui_DrawList_AddRectFilled(draw_list, App.arrange_win_x, App.arrange_win_y + 2, App.arrange_win_x + App.left_margin, App.arrange_win_y + 140, Colors.bg)
		
		-- String legends
		for i = 0, App.num_strings - 1 do
			local str = App.instrument[App.num_strings - 3][App.num_strings - i]
			local len = string.len(str)
			local space
			if len == 2 then space = "  " else space = " " end
			reaper.ImGui_DrawList_AddText(draw_list, App.arrange_win_x + 8, App.arrange_win_y + 23 + (i * App.lane_v_spacing), Colors.text, str .. space .. "*")
		end
		
		reaper.ImGui_EndChild(App.ctx)
	end
end