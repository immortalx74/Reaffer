App =
{
	-- general
	window_title = "Reaffer",
	ctx,
	is_visible,
	is_open,
	icon_font,
	editor_state,
	mouse_x,
	mouse_y,
	mouse_prev_x,
	mouse_prev_y,
	drag_x = 0,
	drag_y = 0,
	scroll_x = 0,
	arrange_win_x = 0,
	arrange_win_y = 0,
	last_note_pitch = 0,
	
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
	left_margin = 50,
	top_margin = 30,
	note_w = 34,
	note_h = 12,
	
	-- defaults
	wheel_delta = 50,
	active_tool,
	num_grid_divisions,
	num_strings = 6,
	num_measures = 4,
	quantize_cur_idx = 3,
	signature_cur_idx = 3,
	
	-- data
	quantize = {"1/1", "1/2", "1/4", "1/8", "1/16", "1/32", "1/64"},
	
	signature = {
		{caption = "2/4", beats = 2, subs = 4},
		{caption = "3/4", beats = 3, subs = 4},
		{caption = "4/4", beats = 4, subs = 4},
		{caption = "5/4", beats = 5, subs = 4},
		{caption = "6/4", beats = 6, subs = 4},
		{caption = "7/4", beats = 7, subs = 4},
		{caption = "8/4", beats = 8, subs = 4},
		{caption = "6/8", beats = 3, subs = 4},
		{caption = "3/4 Tri", beats = 3, subs = 3},
		{caption = "4/4 Tri", beats = 4, subs = 3},
		{caption = "8/4 Tri", beats = 8, subs = 3}
	},
	
	instrument =
	{
		{num_strings = 4, "E1", "A1", "D2", "G2"},
		{num_strings = 5, "B0", "E1", "A1", "D2", "G2"},
		{num_strings = 6, "E2", "A2", "D3", "G3", "B3", "E4"},
		{num_strings = 7, "B1", "E2", "A2", "D3", "G3", "B3", "E4"},
		{num_strings = 8, "F#1", "B1", "E2", "A2", "D3", "G3", "B3", "E4"},
		{num_strings = 9, "C#1", "F#1", "B1", "E2", "A2", "D3", "G3", "B3", "E4"}
	},
	
	note_sequence = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"},
	
	note_list =
	{
		-- {offset = 6, string_idx = 2, pitch = 25, pitch_last = 25, velocity = 127, duration = 1, selected = false},
	},
	note_list_selected = 
	{
		-- {idx = ?, last_pitch = ?}
	}
}

function App.Init()
	local script_path = debug.getinfo(1).source:match("@?(.*[\\|/])")
	App.ctx = reaper.ImGui_CreateContext('Riffer script')
	App.icon_font = reaper.ImGui_CreateFont(script_path .. "icons.ttf", 14)
	reaper.ImGui_AttachFont(App.ctx, App.icon_font)
	Colors.text = reaper.ImGui_GetStyleColor(App.ctx, reaper.ImGui_Col_Text())
	App.window_indent = reaper.ImGui_StyleVar_IndentSpacing()
	App.window_w = reaper.ImGui_GetWindowWidth(App.ctx)
	App.editor_state = e_EditorState.SelectReady
	App.active_tool = e_Tool.Select
end

function App.Loop()
	App.is_visible, App.is_open = reaper.ImGui_Begin(App.ctx, App.window_title, true)
	
	if App.is_visible then
		App.mouse_x, App.mouse_y = reaper.ImGui_GetMousePos(App.ctx)
		App.window_w = reaper.ImGui_GetWindowWidth(App.ctx)
		UI.DrawCB_Strings()
		UI.DrawCB_Signature()
		UI.DrawCB_Quantize()
		UI.DrawSI_Measures()
		UI.DrawTXT_Help()
		Util.HorSpacer(3)
		if reaper.ImGui_Button(App.ctx, "Debug...") then
			msg(#App.note_list_selected)
		end
		UI.DrawArrange()
		UI.DrawToolbar()
		
		App.mouse_prev_x, App.mouse_prev_y = App.mouse_x, App.mouse_y
		reaper.ImGui_End(App.ctx)	
	end
	
	if App.is_open then
		reaper.defer(App.Loop)
	else
		reaper.ImGui_DestroyContext(App.ctx)
		-- reaper.ImGui_DetachFont(App.ctx, App.icon_font)
	end
end