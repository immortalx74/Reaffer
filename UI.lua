UI = {}

function UI.DrawNotes(draw_list)
	local note_x
	local note_y
	local selected
	
	for i, v in ipairs(App.note_list) do
		if App.note_list[i].string_idx < App.num_strings then -- When switching from higher string count instrument to a lower one, notes are kept but hidden
			note_x = App.arrange_win_x + 50 + (App.note_list[i].offset * App.note_w) - App.scroll_x
			note_y = App.arrange_win_y + 30 + (App.note_list[i].string_idx * App.note_h) - 5
			selected = App.note_list[i].selected
			reaper.ImGui_DrawList_AddRectFilled(draw_list, note_x, note_y, note_x + (App.note_w * App.note_list[i].duration) -1, note_y + App.note_h-1, Util.VelocityColor(App.note_list[i].velocity), 40)
			reaper.ImGui_DrawList_AddText(draw_list, note_x + 5, note_y - 2, Colors.text, Util.NotePitchToName(App.note_list[i].pitch))
			if selected then
				reaper.ImGui_DrawList_AddRect(draw_list, note_x, note_y, note_x + (App.note_w * App.note_list[i].duration) -1, note_y + App.note_h-1, Colors.text, 40, reaper.ImGui_DrawFlags_None(), 2)
			end
		end
	end
end

function UI.DrawCB_Strings()
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_strings_w)
	if reaper.ImGui_BeginCombo(App.ctx, "Strings##cb_strings", App.num_strings) then
		local strings = {4, 5, 6, 7, 8, 9}
		if reaper.ImGui_Selectable(App.ctx, strings[1], App.num_strings == 4) then App.num_strings = 4; end
		if reaper.ImGui_Selectable(App.ctx, strings[2], App.num_strings == 5) then App.num_strings = 5; end
		if reaper.ImGui_Selectable(App.ctx, strings[3], App.num_strings == 6) then App.num_strings = 6; end
		if reaper.ImGui_Selectable(App.ctx, strings[4], App.num_strings == 7) then App.num_strings = 7; end
		if reaper.ImGui_Selectable(App.ctx, strings[5], App.num_strings == 8) then App.num_strings = 8; end
		if reaper.ImGui_Selectable(App.ctx, strings[6], App.num_strings == 9) then App.num_strings = 9; end
		reaper.ImGui_EndCombo(App.ctx)
	end
end

function UI.DrawCB_Signature()
	Util.HorSpacer(3)
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_signature_w)
	if reaper.ImGui_BeginCombo(App.ctx, "Signature##cb_signature", App.signature[App.signature_cur_idx].caption, reaper.ImGui_ComboFlags_HeightLarge()) then
		if reaper.ImGui_Selectable(App.ctx, App.signature[1].caption, App.signature_cur_idx == 1) then App.signature_cur_idx = 1; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[2].caption, App.signature_cur_idx == 2) then App.signature_cur_idx = 2; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[3].caption, App.signature_cur_idx == 3) then App.signature_cur_idx = 3; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[4].caption, App.signature_cur_idx == 4) then App.signature_cur_idx = 4; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[5].caption, App.signature_cur_idx == 5) then App.signature_cur_idx = 5; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[6].caption, App.signature_cur_idx == 6) then App.signature_cur_idx = 6; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[7].caption, App.signature_cur_idx == 7) then App.signature_cur_idx = 7; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[8].caption, App.signature_cur_idx == 8) then App.signature_cur_idx = 8; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[9].caption, App.signature_cur_idx == 9) then App.signature_cur_idx = 9; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[10].caption, App.signature_cur_idx == 10) then App.signature_cur_idx = 10; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[11].caption, App.signature_cur_idx == 11) then App.signature_cur_idx = 11; end
		reaper.ImGui_EndCombo(App.ctx)
	end
end

function UI.DrawCB_Quantize()
	Util.HorSpacer(3)
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_quantize_w)
	if reaper.ImGui_BeginCombo(App.ctx, "Quantize##cb_quantize", App.quantize[App.quantize_cur_idx]) then
		if reaper.ImGui_Selectable(App.ctx, App.quantize[1], App.quantize_cur_idx == 1) then App.quantize_cur_idx = 1; end
		if reaper.ImGui_Selectable(App.ctx, App.quantize[2], App.quantize_cur_idx == 2) then App.quantize_cur_idx = 2; end
		if reaper.ImGui_Selectable(App.ctx, App.quantize[3], App.quantize_cur_idx == 3) then App.quantize_cur_idx = 3; end
		if reaper.ImGui_Selectable(App.ctx, App.quantize[4], App.quantize_cur_idx == 4) then App.quantize_cur_idx = 4; end
		if reaper.ImGui_Selectable(App.ctx, App.quantize[5], App.quantize_cur_idx == 5) then App.quantize_cur_idx = 5; end
		if reaper.ImGui_Selectable(App.ctx, App.quantize[6], App.quantize_cur_idx == 6) then App.quantize_cur_idx = 6; end
		if reaper.ImGui_Selectable(App.ctx, App.quantize[7], App.quantize_cur_idx == 7) then App.quantize_cur_idx = 7; end
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
				if i >= 2 and i <= 5 then -- only the note tools can be active
					App.active_tool = i
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
			if i == 1 or i == 5 then
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
			local cell_x = math.floor((App.mouse_x - App.arrange_win_x + App.scroll_x -15) / 34) - 1
			local cell_y = math.floor((App.mouse_y - App.arrange_win_y - App.top_margin + 5) / 12)
			
			if App.mouse_x > rect_x1 and App.mouse_x < rect_x2  and App.mouse_y > rect_y1 and App.mouse_y < rect_y2  then
				
				
				local preview_x = App.arrange_win_x + App.left_margin + (cell_x * App.note_w) - App.scroll_x
				local preview_y = App.arrange_win_y + App.top_margin + (cell_y * App.note_h) - 5
				reaper.ImGui_DrawList_AddRectFilled(draw_list, preview_x, preview_y, preview_x + App.note_w - 1, preview_y + App.note_h - 1, Colors.note_preview, 40)
				
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
		reaper.ImGui_DrawList_AddRectFilled(draw_list, App.arrange_win_x, App.arrange_win_y+2, App.arrange_win_x+App.left_margin, App.arrange_win_y+140, Colors.bg)
		
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