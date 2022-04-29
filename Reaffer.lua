-----------------------------------------------------------------------
-- if reaper.ImGui_Button(App.ctx, 'MyButton') then
-- 	local cur_pos = reaper.GetCursorPositionEx(0)
-- 	target_track = reaper.GetTrack(0, 18)
-- 	time_end = reaper.TimeMap2_beatsToTime(0, 4)
-- 	mi = reaper.CreateNewMIDIItemInProj(target_track, cur_pos, cur_pos + time_end)
-- 	tk = reaper.GetActiveTake(mi)
-- 	reaper.MIDI_InsertNote(tk, false, false, 0, 3000, 0, 41, 100)
-- end
-----------------------------------------------------------------------

local App =
{
	-- general
	window_title = "Test App",
	ctx,
	is_visible,
	is_open,
	-- metrics
	window_w = 800,
	window_h = 600,
	window_indent,
	lane_v_spacing = 12,
	cb_strings_w = 36,
	cb_signature_w = 76,
	cb_quantize_w = 58,
	si_measures_w = 140,
	arrange_h = 200,
	grid_w = 34,
	-- defaults
	num_grid_divisions,
	num_strings = 6,
	num_measures = 4,
	signature = {[0] = "2/4", "3/4", "4/4", "5/4", "6/4", "7/4", "8/4", "6/8", "3/4 Tri", "4/4 Tri", "8/4 Tri"},
	signature_cur_idx = 2,
	quantize = {[0] = "1/1", "1/2", "1/4", "1/8", "1/16", "1/32", "1/64"},
	quantize_cur_idx = 2,
	instrument =
	{
		-- num_strings, open string note number, strings in reverse order (high to low)
		[0] = 
		{[0] = 4, 25, "G2", "D2", "A1", "E1"},
		{[0] = 5, 26, "G2", "D2", "A1", "E1", "B0"},
		{[0] = 6, 25, "E4", "B3", "G3", "D3", "A2", "E2"},
		{[0] = 7, 25, "E4", "B3", "G3", "D3", "A2", "E2", "B1"},
		{[0] = 8, 25, "E4", "B3", "G3", "D3", "A2", "E2", "B1", "F#1"},
		{[0] = 9, 25, "E4", "B3", "G3", "D3", "A2", "E2", "B1", "F#1", "C#1"}
	}
}

local Colors = 
{
	lane = 0x202020FF,
	string_name = 0xFF44FFFF,
	measure = 0xFFFFFFFF,
	gridline = 0x404040FF,
	red = 0xFF0000FF,
	bg = 0x0F0F0FFF
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
	if App.signature_cur_idx <= 6 then
		App.num_grid_divisions = App.num_measures * (App.signature_cur_idx + 2) * 4
	end
	
	-- other signatures here...
	-- ...
	
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
	if reaper.ImGui_BeginCombo(App.ctx, "Signature##cb_signature", App.signature[App.signature_cur_idx], reaper.ImGui_ComboFlags_HeightLarge()) then
		if reaper.ImGui_Selectable(App.ctx, App.signature[0], App.signature_cur_idx == 0) then App.signature_cur_idx = 0; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[1], App.signature_cur_idx == 1) then App.signature_cur_idx = 1; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[2], App.signature_cur_idx == 2) then App.signature_cur_idx = 2; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[3], App.signature_cur_idx == 3) then App.signature_cur_idx = 3; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[4], App.signature_cur_idx == 4) then App.signature_cur_idx = 4; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[5], App.signature_cur_idx == 5) then App.signature_cur_idx = 5; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[6], App.signature_cur_idx == 6) then App.signature_cur_idx = 6; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[7], App.signature_cur_idx == 7) then App.signature_cur_idx = 7; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[8], App.signature_cur_idx == 7) then App.signature_cur_idx = 8; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[9], App.signature_cur_idx == 7) then App.signature_cur_idx = 9; end
		if reaper.ImGui_Selectable(App.ctx, App.signature[10], App.signature_cur_idx == 7) then App.signature_cur_idx = 10; end
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
		"This is a comment")
		reaper.ImGui_EndTooltip(App.ctx)
	end
end

function UI.DrawArrange()
	local lane_w = Util.NumGridDivisions() * App.grid_w
	reaper.ImGui_SetNextWindowContentSize(App.ctx, lane_w + 50, App.arrange_h - 20)
	reaper.ImGui_BeginChild(App.ctx, "Arrange", App.window_w - App.window_indent, App.arrange_h, true, reaper.ImGui_WindowFlags_HorizontalScrollbar())
	
	d_list = reaper.ImGui_GetWindowDrawList(App.ctx)
	local scroll_x = reaper.ImGui_GetScrollX(App.ctx)
	local winx, winy = reaper.ImGui_GetWindowPos(App.ctx)
	local left_margin = 50
	local top_margin = 30
	local line_start_x = winx + left_margin - scroll_x
	local line_end_x = winx + left_margin + lane_w - scroll_x
	
	-- Lanes
	for i = 0, App.num_strings - 1 do
		reaper.ImGui_DrawList_AddLine(d_list, line_start_x, winy + top_margin + (i * App.lane_v_spacing), line_end_x, winy + top_margin + (i * App.lane_v_spacing), Colors.lane)
	end
	
	-- Measure divisions
	local measure_w = (App.signature_cur_idx + 2) * App.grid_w * 4
	
	for i = 0, App.num_measures - 1 do
		reaper.ImGui_DrawList_AddLine(d_list, winx + left_margin + measure_w + (measure_w * i) - scroll_x, winy + top_margin, winx + left_margin + measure_w + (measure_w * i) - scroll_x, winy + top_margin + ((App.num_strings - 1) * 12), Colors.red)
	end
	
	-- Grid divisions
	for i = 0, App.num_grid_divisions - 1 do
		reaper.ImGui_DrawList_AddLine(d_list, winx + left_margin + (App.grid_w * i) - scroll_x, winy + top_margin - 17, winx + left_margin + (App.grid_w * i) - scroll_x, winy + top_margin - 12, Colors.lane)
	end
	
	-- reaper.ImGui_DrawList_AddRectFilled(d_list, winx+4, winy+1, winx+24, winy+20, Colors.bg)
	
	-- String legends
	for i = 0, App.num_strings - 1 do
		reaper.ImGui_DrawList_AddText(d_list, winx+8, winy+23+ (i * App.lane_v_spacing), Colors.string_name, App.instrument[App.num_strings - 4][i + 2])
	end
	
	-- reaper.ImGui_DrawList_AddText(d_list, winx+8, winy+23, Colors.string_name, "A#0 *")
	-- reaper.ImGui_DrawList_AddText(d_list, winx+8, winy+23+ (1 * App.lane_v_spacing), Colors.string_name, "B0  *")
	-- reaper.ImGui_DrawList_AddText(d_list, winx+8, winy+23+ (2 * App.lane_v_spacing), Colors.string_name, "C2  *")
	
	reaper.ImGui_EndChild(App.ctx)
end

function App.Init()
	App.ctx = reaper.ImGui_CreateContext('Riffer script')
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
	end
	
	reaper.ImGui_End(App.ctx)	
	-------------------------
	if App.is_open then
		reaper.defer(App.Loop)
	else
		reaper.ImGui_DestroyContext(App.ctx)
	end
end

App.Init()
reaper.defer(App.Loop)
