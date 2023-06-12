Input = {}

function Input.GetShortcuts()
	if reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Mod_Ctrl()) and not reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Mod_Shift()) and reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_Z()) then
		UR.PopUndo()
	end
	if reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Mod_Ctrl()) and reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Mod_Shift()) and reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_Z()) then
		UR.PopRedo()
	end
	if reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Mod_Ctrl()) and reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_C()) then
		Clipboard.Copy()
	end
	if reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Mod_Ctrl()) and reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_X()) then
		Clipboard.Cut()
	end
	if reaper.ImGui_IsKeyDown(App.ctx, reaper.ImGui_Mod_Ctrl()) and reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_V()) then
		if #Clipboard.note_list > 0 then App.attempts_paste = true; end
	end
	
	if reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_F1()) then
		Debug.enabled = not Debug.enabled
	end
	
	if reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_S()) then
		App.active_tool = e_Tool.Select
	end
	if reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_D()) then
		App.active_tool = e_Tool.Draw
	end
	if reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_E()) then
		App.active_tool = e_Tool.Erase
	end
	if reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_W()) then
		App.active_tool = e_Tool.Move
	end
	if reaper.ImGui_IsKeyPressed(App.ctx, reaper.ImGui_Key_Escape()) then
		App.attempts_paste = false
	end
end