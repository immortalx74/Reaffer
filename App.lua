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
	scroll_x = 0,
	editor_win_x = 0,
	editor_win_y = 0,
	can_init_drag = false,
	current_pitch = 0,
	is_new_note = false,
	last_click_was_inside_editor = false,
	
	-- metrics
	window_w = 800,
	window_h = 600,
	window_indent,
	lane_v_spacing = 12,
	cb_strings_w = 36,
	cb_signature_w = 76,
	cb_quantize_w = 58,
	si_measures_w = 140,
	cb_note_sisplay_w = 112,
	editor_h = 160,
	grid_w = 34,
	left_margin = 50,
	top_margin = 30,
	note_w = 34,
	note_h = 12,
	
	-- settings
	audition_notes = true,
	swap_pitchfret_order = false,
	default_velocity = 80,
	default_off_velocity = 65,
	
	-- defaults
	wheel_delta = 50,
	active_tool = e_Tool.Select,
	num_strings = 6,
	num_measures = 4,
	quantize_cur_idx = 5,
	signature_cur_idx = 3,
	note_display_cur_idx = e_NoteDisplay.Pitch,
	
	-- data
	quantize = {"1/1", "1/2", "1/4", "1/8", "1/16", "1/32", "1/64"},
	
	note_display = {"Pitch", "Fret", "Pitch&Fret", "Velocity", "Off Velocity", "MIDI Pitch"},
	
	signature = {
		{caption = "2/4",     beats = 2, subs = 4},
		{caption = "3/4",     beats = 3, subs = 4},
		{caption = "4/4",     beats = 4, subs = 4},
		{caption = "5/4",     beats = 5, subs = 4},
		{caption = "6/4",     beats = 6, subs = 4},
		{caption = "7/4",     beats = 7, subs = 4},
		{caption = "8/4",     beats = 8, subs = 4},
		{caption = "6/8",     beats = 3, subs = 4},
		{caption = "3/4 Tri", beats = 3, subs = 3},
		{caption = "4/4 Tri", beats = 4, subs = 3},
		{caption = "8/4 Tri", beats = 8, subs = 3}
	},
	
	instrument =
	{
		{num_strings = 4, open = {28, 33, 38, 43},                     recent = {28, 33, 38, 43},                     "E1", "A1", "D2", "G2"},
		{num_strings = 5, open = {23, 28, 33, 38, 43},                 recent = {23, 28, 33, 38, 43},                 "B0", "E1", "A1", "D2", "G2"},
		{num_strings = 6, open = {40, 45, 50, 55, 59, 64},             recent = {40, 45, 50, 55, 59, 64},             "E2", "A2", "D3", "G3", "B3", "E4"},
		{num_strings = 7, open = {35, 40, 45, 50, 55, 59, 64},         recent = {35, 40, 45, 50, 55, 59, 64},         "B1", "E2", "A2", "D3", "G3", "B3", "E4"},
		{num_strings = 8, open = {30, 35, 40, 45, 50, 55, 59, 64},     recent = {30, 35, 40, 45, 50, 55, 59, 64},     "F#1", "B1", "E2", "A2", "D3", "G3", "B3", "E4"},
		{num_strings = 9, open = {25, 30, 35, 40, 45, 50, 55, 59, 64}, recent = {25, 30, 35, 40, 45, 50, 55, 59, 64}, "C#1", "F#1", "B1", "E2", "A2", "D3", "G3", "B3", "E4"}
	},
	
	note_sequence = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"},
	
	note_list =
	{
		-- {idx = 1, offset = 6, string_idx = 2, pitch = 25, velocity = 127, off_velocity = 80, duration = 1},
	},
	
	-- table, storing last clicked note object.
	-- That's different from last selected, as you can "re-click" an already selected note
	last_note_clicked,
	
	note_list_selected = {}
}

function App.Init()
	local script_path = debug.getinfo(1).source:match("@?(.*[\\|/])")
	App.ctx = reaper.ImGui_CreateContext('Riffer script')
	App.icon_font = reaper.ImGui_CreateFont(script_path .. "icons.ttf", 14)
	reaper.ImGui_AttachFont(App.ctx, App.icon_font)
	Colors.text = reaper.ImGui_GetStyleColor(App.ctx, reaper.ImGui_Col_Text())
	App.window_indent = reaper.ImGui_StyleVar_IndentSpacing()
	App.window_w = reaper.ImGui_GetWindowWidth(App.ctx)
end

function App.Loop()
	App.is_visible, App.is_open = reaper.ImGui_Begin(App.ctx, App.window_title, true)
	
	if App.is_visible then
		App.mouse_x, App.mouse_y = reaper.ImGui_GetMousePos(App.ctx)
		App.window_w = reaper.ImGui_GetWindowWidth(App.ctx)
		
		-- if reaper.ImGui_GetKeyMods(App.ctx) == reaper.ImGui_KeyModFlags_Ctrl() and reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_Z()) then
		-- 	UR.PopUndo()
		-- end
		-- if reaper.ImGui_GetKeyMods(App.ctx) == reaper.ImGui_KeyModFlags_Ctrl() + reaper.ImGui_KeyModFlags_Shift() and reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_Z()) then
		-- 	UR.PopRedo()
		-- end
		if reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Key_ModCtrl()) and not reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Key_ModShift()) and reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_Z()) then
			msg("undo")
		end
		if reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Key_ModCtrl()) and reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Key_ModShift()) and reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_Z()) then
			msg("redo")
		end

		UI.Render_CB_Strings()
		UI.Render_CB_Signature()
		UI.Render_CB_Quantize()
		UI.Render_SI_Measures()
		UI.Render_CB_NoteDisplay()
		UI.Render_BTN_Settings()
		UI.Render_TXT_Help()
		UI.Render_Editor()
		UI.Render_Toolbar()
		
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