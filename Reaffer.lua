-- Reaffer ---------------------------------------------------

local App =
{
	-- general
	window_title = "Reaffer",
	ctx,
	is_visible,
	is_open,
	icon_font,

	-- metrics
	window_w = 800,
	window_h = 600,
	window_indent,
	lane_v_spacing = 12,
	cb_strings_w = 36,
	cb_signature_w = 76,
	cb_quantize_w = 58,
	si_measures_w = 140,
	arrange_h = 160,
	grid_w = 34,

	-- defaults
	active_tool_idx = 0,
	num_grid_divisions,
	num_strings = 6,
	num_measures = 4,
	quantize_cur_idx = 2,
	signature_cur_idx = 2,
	
	-- data
	quantize = {[0] = "1/1", "1/2", "1/4", "1/8", "1/16", "1/32", "1/64"},
	signature = {
		-- caption, beats per measure, subdivisions per beat
		[0] = 
		{[0] = "2/4", 2, 4},
		{[0] = "3/4", 3, 4},
		{[0] = "4/4", 4, 4},
		{[0] = "5/4", 5, 4},
		{[0] = "6/4", 6, 4},
		{[0] = "7/4", 7, 4},
		{[0] = "8/4", 8, 4},
		{[0] = "6/8", 3, 4},
		{[0] = "3/4 Tri", 3, 3},
		{[0] = "4/4 Tri", 4, 3},
		{[0] = "8/4 Tri", 8, 3}
	},
	instrument =
	{
		-- num_strings, open string note number, strings (high to low)
		[0] = 
		{[0] = 4, 25, "G2 ", "D2 ", "A1 ", "E1 "},
		{[0] = 5, 26, "G2 ", "D2 ", "A1 ", "E1 ", "B0 "},
		{[0] = 6, 25, "E4 ", "B3 ", "G3 ", "D3 ", "A2 ", "E2 "},
		{[0] = 7, 25, "E4 ", "B3 ", "G3 ", "D3 ", "A2 ", "E2 ", "B1 "},
		{[0] = 8, 25, "E4 ", "B3 ", "G3 ", "D3 ", "A2 ", "E2 ", "B1 ", "F#1"},
		{[0] = 9, 25, "E4 ", "B3 ", "G3 ", "D3 ", "A2 ", "E2 ", "B1 ", "F#1", "C#1"}
	}
}

local Colors = 
{
	lane = 0x202020FF,
	string_name = 0xFF44FFFF,
	measure = 0xFFFFFFFF,
	gridline = 0x404040FF,
	red = 0xFF0000FF,
	bg = 0x0F0F0FFF,
	active_tool = 0x23456D,
	text
}

local Util = {}

function Util.HorSpacer(num_spacers)
	for i = 0, num_spacers - 1 do
		reaper.ImGui_SameLine(App.ctx)
		reaper.ImGui_Spacing(App.ctx)
	end
	reaper.ImGui_SameLine(App.ctx)
end

function Util.NumGridDivisions()
	App.num_grid_divisions = App.num_measures * App.signature[App.signature_cur_idx][1] * App.signature[App.signature_cur_idx][2]
	return App.num_grid_divisions
end

local UI = {}

function UI.DrawCB_Strings()
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_strings_w)
	if reaper.ImGui_BeginCombo(App.ctx, "Strings##cb_strings", App.num_strings) then
		local strings = {[0] = 4, 5, 6, 7, 8, 9}
		if reaper.ImGui_Selectable(App.ctx, strings[0], App.num_strings == 4) then App.num_strings = 4; end
		if reaper.ImGui_Selectable(App.ctx, strings[1], App.num_strings == 5) then App.num_strings = 5; end
		if reaper.ImGui_Selectable(App.ctx, strings[2], App.num_strings == 6) then App.num_strings = 6; end
		if reaper.ImGui_Selectable(App.ctx, strings[3], App.num_strings == 7) then App.num_strings = 7; end
		if reaper.ImGui_Selectable(App.ctx, strings[4], App.num_strings == 8) then App.num_strings = 8; end
		if reaper.ImGui_Selectable(App.ctx, strings[5], App.num_strings == 9) then App.num_strings = 9; end
		reaper.ImGui_EndCombo(App.ctx)
	end
end

function UI.DrawCB_Signature()
	Util.HorSpacer(3)
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_signature_w)
	if reaper.ImGui_BeginCombo(App.ctx, "Signature##cb_signature", App.signature[App.signature_cur_idx][0], reaper.ImGui_ComboFlags_HeightLarge()) then
		if reaper.ImGui_Selectable(App.ctx, App.signature[0][0], App.signature_cur_idx == 0) then App.signature_cur_idx = 0; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[1][0], App.signature_cur_idx == 1) then App.signature_cur_idx = 1; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[2][0], App.signature_cur_idx == 2) then App.signature_cur_idx = 2; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[3][0], App.signature_cur_idx == 3) then App.signature_cur_idx = 3; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[4][0], App.signature_cur_idx == 4) then App.signature_cur_idx = 4; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[5][0], App.signature_cur_idx == 5) then App.signature_cur_idx = 5; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[6][0], App.signature_cur_idx == 6) then App.signature_cur_idx = 6; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[7][0], App.signature_cur_idx == 7) then App.signature_cur_idx = 7; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[8][0], App.signature_cur_idx == 7) then App.signature_cur_idx = 8; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[9][0], App.signature_cur_idx == 7) then App.signature_cur_idx = 9; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[10][0], App.signature_cur_idx == 7) then App.signature_cur_idx = 10; end
		reaper.ImGui_EndCombo(App.ctx)
	end
end

function UI.DrawCB_Quantize()
	Util.HorSpacer(3)
	reaper.ImGui_SetNextItemWidth(App.ctx, App.cb_quantize_w)
	if reaper.ImGui_BeginCombo(App.ctx, "Quantize##cb_quantize", App.quantize[App.quantize_cur_idx]) then
		if reaper.ImGui_Selectable(App.ctx, App.quantize[0], App.quantize_cur_idx == 0) then App.quantize_cur_idx = 0; end
		if reaper.ImGui_Selectable(App.ctx, App.quantize[1], App.quantize_cur_idx == 1) then App.quantize_cur_idx = 1; end
		if reaper.ImGui_Selectable(App.ctx, App.quantize[2], App.quantize_cur_idx == 2) then App.quantize_cur_idx = 2; end
		if reaper.ImGui_Selectable(App.ctx, App.quantize[3], App.quantize_cur_idx == 3) then App.quantize_cur_idx = 3; end
		if reaper.ImGui_Selectable(App.ctx, App.quantize[4], App.quantize_cur_idx == 4) then App.quantize_cur_idx = 4; end
		if reaper.ImGui_Selectable(App.ctx, App.quantize[5], App.quantize_cur_idx == 5) then App.quantize_cur_idx = 5; end
		if reaper.ImGui_Selectable(App.ctx, App.quantize[6], App.quantize_cur_idx == 6) then App.quantize_cur_idx = 6; end
		reaper.ImGui_EndCombo(App.ctx)
	end
end

function UI.DrawSI_Measures()
	Util.HorSpacer(3)
	reaper.ImGui_SetNextItemWidth(App.ctx, App.si_measures_w)
	do
		local ret, val = reaper.ImGui_SliderInt(App.ctx, "Measures##si_measures", App.num_measures, 1, 64)
		App.num_measures = val
	end
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
	reaper.ImGui_BeginChild(App.ctx, "Toolbar##win_toolbar")
	
	reaper.ImGui_PushStyleColor(App.ctx, reaper.ImGui_Col_Button(), Colors.bg)
	
	-- Create MIDI item
	reaper.ImGui_PushFont(App.ctx, App.icon_font)
	reaper.ImGui_Button(App.ctx, "a")
	reaper.ImGui_PopFont(App.ctx)
	
	if reaper.ImGui_IsItemHovered(App.ctx) then
		reaper.ImGui_BeginTooltip(App.ctx)
		reaper.ImGui_Text(App.ctx, "Create MIDI item in first selected track, at edit cursor")
		reaper.ImGui_EndTooltip(App.ctx)
	end
	
	Util.HorSpacer(3)
	
	-- Select tool
	reaper.ImGui_PushFont(App.ctx, App.icon_font)
	if reaper.ImGui_Button(App.ctx, "e") then
		App.active_tool = 0
	end
	reaper.ImGui_PopFont(App.ctx)
	
	if reaper.ImGui_IsItemHovered(App.ctx) then
		reaper.ImGui_BeginTooltip(App.ctx)
		reaper.ImGui_Text(App.ctx, "Select")
		reaper.ImGui_EndTooltip(App.ctx)
	end
	
	-- Move tool
	reaper.ImGui_SameLine(App.ctx)
	reaper.ImGui_PushFont(App.ctx, App.icon_font)
	if reaper.ImGui_Button(App.ctx, "f") then
		App.active_tool = 1
	end
	reaper.ImGui_PopFont(App.ctx)
	
	if reaper.ImGui_IsItemHovered(App.ctx) then
		reaper.ImGui_BeginTooltip(App.ctx)
		reaper.ImGui_Text(App.ctx, "Move")
		reaper.ImGui_EndTooltip(App.ctx)
	end
	
	-- Draw tool
	reaper.ImGui_SameLine(App.ctx)
	reaper.ImGui_PushFont(App.ctx, App.icon_font)
	if reaper.ImGui_Button(App.ctx, "g") then
		App.active_tool = 2
	end
	reaper.ImGui_PopFont(App.ctx)
	
	if reaper.ImGui_IsItemHovered(App.ctx) then
		reaper.ImGui_BeginTooltip(App.ctx)
		reaper.ImGui_Text(App.ctx, "Draw")
		reaper.ImGui_EndTooltip(App.ctx)
	end
	
	-- Erase tool
	reaper.ImGui_SameLine(App.ctx)
	reaper.ImGui_PushFont(App.ctx, App.icon_font)
	if reaper.ImGui_Button(App.ctx, "h") then
		App.active_tool = 3
	end
	reaper.ImGui_PopFont(App.ctx)
	
	if reaper.ImGui_IsItemHovered(App.ctx) then
		reaper.ImGui_BeginTooltip(App.ctx)
		reaper.ImGui_Text(App.ctx, "Erase")
		reaper.ImGui_EndTooltip(App.ctx)
	end
	
	Util.HorSpacer(3)
	
	-- Cut Tool
	reaper.ImGui_PushFont(App.ctx, App.icon_font)
	reaper.ImGui_Button(App.ctx, "b")
	reaper.ImGui_PopFont(App.ctx)
	
	if reaper.ImGui_IsItemHovered(App.ctx) then
		reaper.ImGui_BeginTooltip(App.ctx)
		reaper.ImGui_Text(App.ctx, "Cut")
		reaper.ImGui_EndTooltip(App.ctx)
	end
	
	--Copy tool
	reaper.ImGui_SameLine(App.ctx)
	reaper.ImGui_PushFont(App.ctx, App.icon_font)
	reaper.ImGui_Button(App.ctx, "c")
	reaper.ImGui_PopFont(App.ctx)
	
	if reaper.ImGui_IsItemHovered(App.ctx) then
		reaper.ImGui_BeginTooltip(App.ctx)
		reaper.ImGui_Text(App.ctx, "Copy")
		reaper.ImGui_EndTooltip(App.ctx)
	end
	
	-- Paste tool
	reaper.ImGui_SameLine(App.ctx)
	reaper.ImGui_PushFont(App.ctx, App.icon_font)
	reaper.ImGui_Button(App.ctx, "d")
	reaper.ImGui_PopFont(App.ctx)
	
	if reaper.ImGui_IsItemHovered(App.ctx) then
		reaper.ImGui_BeginTooltip(App.ctx)
		reaper.ImGui_Text(App.ctx, "Paste")
		reaper.ImGui_EndTooltip(App.ctx)
	end
	
	reaper.ImGui_PopStyleColor(App.ctx)
	
	reaper.ImGui_EndChild(App.ctx)
end

function UI.DrawArrange()
	App.arrange_h = 50 + ((App.num_strings) * 12)
	local lane_w = Util.NumGridDivisions() * App.grid_w
	reaper.ImGui_SetNextWindowContentSize(App.ctx, lane_w + 45, App.arrange_h - 20)
	reaper.ImGui_BeginChild(App.ctx, "Arrange##win_arrange", App.window_w - App.window_indent, App.arrange_h, true, reaper.ImGui_WindowFlags_HorizontalScrollbar() | reaper.ImGui_WindowFlags_NoMove())
	local draw_list = reaper.ImGui_GetWindowDrawList(App.ctx)
	local scroll_x = reaper.ImGui_GetScrollX(App.ctx)
	local winx, winy = reaper.ImGui_GetWindowPos(App.ctx)
	local left_margin = 50
	local top_margin = 30
	local lane_start_x = winx + left_margin - scroll_x
	local lane_end_x = lane_start_x + lane_w
	
	-- Lanes
	for i = 0, App.num_strings - 1 do
		reaper.ImGui_DrawList_AddLine(draw_list, lane_start_x, winy + top_margin + (i * App.lane_v_spacing), lane_end_x, winy + top_margin + (i * App.lane_v_spacing), Colors.lane)
	end
	
	-- Measures and beats lines and legends
	for i = 0, App.num_grid_divisions do
		if i % App.signature[App.signature_cur_idx][1] == 0 then
			
			if i ~= App.num_grid_divisions then
				local txt = "3-1"
				reaper.ImGui_DrawList_AddTextEx(draw_list, nil, 11, winx + left_margin + (App.grid_w * i) - scroll_x, winy + top_margin - 20, Colors.red, txt)
			end
			
			if (i ~= 0 and i % (App.signature[App.signature_cur_idx][1] * App.signature[App.signature_cur_idx][2]) == 0) or i == App.num_grid_divisions then
				reaper.ImGui_DrawList_AddLine(draw_list, winx + left_margin + (App.grid_w * i) - scroll_x, winy + top_margin, winx + left_margin + (App.grid_w * i) - scroll_x, winy + top_margin + ((App.num_strings - 1) * 12), Colors.red)
			end
		else
			reaper.ImGui_DrawList_AddLine(draw_list, winx + left_margin + (App.grid_w * i) - scroll_x, winy + top_margin - 17, winx + left_margin + (App.grid_w * i) - scroll_x, winy + top_margin - 12, Colors.lane)
		end
	end
	
	-- String legends
	for i = 0, App.num_strings - 1 do
		reaper.ImGui_DrawList_AddText(draw_list, winx+8, winy+23+ (i * App.lane_v_spacing), Colors.string_name, App.instrument[App.num_strings - 4][i + 2] .. " *")
	end
	
	-- Enter notes...
	local note_entry_rect_x1 = winx + left_margin
	local note_entry_rect_y1 = winy + top_margin - 5
	local note_entry_rect_x2 = lane_end_x + 1
	local note_entry_rect_y2 = note_entry_rect_y1 + 11 + (App.num_strings - 1) * App.lane_v_spacing
	
	-- reaper.ImGui_DrawList_AddRect(draw_list, lane_start_x, winy + top_margin - 5, lane_end_x + 1, winy+top_margin - 5 + 11 + ((App.num_strings - 1) * App.lane_v_spacing), Colors.red)
	
	-- get cell test 34 X 12
	if reaper.ImGui_IsWindowHovered(App.ctx) then
		local mx, my = reaper.ImGui_GetMousePos(App.ctx)
		local cell_x = math.floor((mx - winx + scroll_x-15) / 34) - 1
		local cell_y = math.floor((my - winy - top_margin + 5) / 12)
		if mx > note_entry_rect_x1 and mx < winx + left_margin + lane_w-scroll_x-1  and my > note_entry_rect_y1 and my < note_entry_rect_y2  then
			-- reaper.ShowConsoleMsg(cell_y .. "\n")
			local test_x = winx + left_margin + (cell_x * 34) - scroll_x
			local test_y = winy + top_margin + (cell_y * 12)
			reaper.ImGui_DrawList_AddRectFilled(draw_list, test_x, test_y-5, test_x+34, test_y-5+12, Colors.measure)
		end
	end
	-- if reaper.ImGui_IsWindowHovered(App.ctx) then
	-- 	local mx, my = reaper.ImGui_GetMousePos(App.ctx)
	-- 	local relmx = mx-winx
	-- 	local relmy = my-winy
	-- reaper.ShowConsoleMsg(relmx .. "\n")
	-- reaper.ImGui_DrawList_AddRectFilled(draw_list, winx+relmx, winy+relmy, winx+relmx+50, winy+relmy+12, Colors.red)
	-- end
	
	reaper.ImGui_EndChild(App.ctx)
end

function App.Init()
	local script_folder = debug.getinfo(1).source:match("@?(.*[\\|/])")
	App.ctx = reaper.ImGui_CreateContext('Riffer script')
	App.icon_font = reaper.ImGui_CreateFont(script_folder .. "icons.ttf", 13)
	reaper.ImGui_AttachFont(App.ctx, App.icon_font)
	Colors.text = reaper.ImGui_GetStyleColor(App.ctx, reaper.ImGui_Col_Text())
	App.window_indent = reaper.ImGui_StyleVar_IndentSpacing()
	App.window_w = reaper.ImGui_GetWindowWidth(App.ctx)
end

function App.Loop()
	App.is_visible, App.is_open = reaper.ImGui_Begin(App.ctx, App.window_title, true)
	
	if App.is_visible then		
		App.window_w = reaper.ImGui_GetWindowWidth(App.ctx)
		UI.DrawCB_Strings()
		UI.DrawCB_Signature()
		UI.DrawCB_Quantize()
		UI.DrawSI_Measures()
		UI.DrawTXT_Help()
		Util.HorSpacer(3)
		if reaper.ImGui_Button(App.ctx, "Debug...") then reaper.ShowConsoleMsg(App.instrument[2][2]); end
		UI.DrawArrange()
		UI.DrawToolbar()
	end
	
	reaper.ImGui_End(App.ctx)	

	if App.is_open then
		reaper.defer(App.Loop)
	else
		reaper.ImGui_DestroyContext(App.ctx)
		-- reaper.ImGui_DetachFont(App.ctx, App.icon_font)
	end
end

App.Init()
reaper.defer(App.Loop)