Debug = {enabled = false}

function Debug.ShowContainers()
	local opt = {"NoOp", "Insert", "Delete", "Pitch + dur", "Vel", "Move"}
	if reaper.ImGui_BeginListBox(App.ctx, "Undo stack", 300, 200 ) then
		if #UR.undo_stack > 0 then
			for i, v in ipairs(UR.undo_stack) do
				local rec = v.note_list
				reaper.ImGui_Text(App.ctx, "[Rec: " .. i .. ", Type: " .. opt[v.type] .. "]")
				for j, m in ipairs(rec) do
					reaper.ImGui_Text(App.ctx, "	Note: " .. rec[j].offset .. "-" .. rec[j].string_idx)
				end
			end
		end
		reaper.ImGui_EndListBox(App.ctx)
	end
	
	reaper.ImGui_SameLine(App.ctx)
	
	if reaper.ImGui_BeginListBox(App.ctx, "Redo stack", 300, 200 ) then
		if #UR.redo_stack > 0 then
			for i, v in ipairs(UR.redo_stack) do
				local rec = v.note_list
				reaper.ImGui_Text(App.ctx, "[Rec: " .. i .. ", Type: " .. opt[v.type] .. "]")
				for j, m in ipairs(rec) do
					reaper.ImGui_Text(App.ctx, "	Note: " .. rec[j].offset .. "-" .. rec[j].string_idx)
				end
			end
		end
		reaper.ImGui_EndListBox(App.ctx)
	end
	
	reaper.ImGui_SameLine(App.ctx)
	if reaper.ImGui_BeginListBox(App.ctx, "Clipboard", 300, 200 ) then
		if #Clipboard.note_list > 0 then
			for i, v in ipairs(Clipboard.note_list) do
				reaper.ImGui_Text(App.ctx, "Note: " .. v.offset .. "-" .. v.string_idx)
			end
		end
		reaper.ImGui_EndListBox(App.ctx)
	end
	
	if reaper.ImGui_BeginListBox(App.ctx, "Notes", 300, 200 ) then
		if #App.note_list > 0 then
			for i, v in ipairs(App.note_list) do
				reaper.ImGui_Text(App.ctx, i .. " - X:" .. v.offset  .. " - Y:" .. v.string_idx .. " - Dur:" ..v.duration)
			end
		end
		reaper.ImGui_EndListBox(App.ctx)
	end
	
	reaper.ImGui_SameLine(App.ctx)
	if reaper.ImGui_BeginListBox(App.ctx, "Selected", 300, 200 ) then
		if #App.note_list_selected > 0 then
			for i, v in ipairs(App.note_list_selected) do
				local idx = App.note_list_selected.indices[i]
				reaper.ImGui_Text(App.ctx, idx .. " - X:" .. v.offset .. " - Y:" .. v.string_idx .. " - Dur:" ..v.duration)
			end
		end
		reaper.ImGui_EndListBox(App.ctx)
	end
	
	reaper.ImGui_SameLine(App.ctx)
	if reaper.ImGui_BeginListBox(App.ctx, "Last Clicked", 300, 50 ) then
		if App.last_note_clicked ~= nil then
			reaper.ImGui_Text(App.ctx, App.last_note_clicked.idx .. " - X:" .. App.last_note_clicked.offset .. " - Y:" .. App.last_note_clicked.string_idx .. " - Dur:" ..App.last_note_clicked.duration)
		end
		reaper.ImGui_EndListBox(App.ctx)
	end
end