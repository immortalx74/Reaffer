UR = 
{
	last_op = nil,
	undo_stack = {},
	redo_stack = {}
	-- {type = ?, note_list = {	{offset = ?, etc}, {idx = ?, offset = ?, etc}, ...	}	}
	-- {type = ?, note_list = {	{offset = ?, etc}, {idx = ?, offset = ?, etc}, ...	}	}

	-- NOTE If the type is move, include indices.
	-- {type = ?, indices = {}, note_list = {	{offset = ?, etc}, {idx = ?, offset = ?, etc}, ...	}	}
}

function UR.PushUndo(type, note_list)
	local new_rec = {type = type, note_list = Util.CopyTable(note_list)}
	
	if type == e_OpType.Move then
		new_rec.indices = Util.CopyTable(note_list.indices)
	end
	
	UR.undo_stack[#UR.undo_stack + 1] = new_rec
	
	-- clear redo stack
	if #UR.redo_stack > 0 then
		Util.ClearTable(UR.redo_stack)
	end
end

function UR.PopUndo()
	if #UR.undo_stack == 0 then return; end
	
	local last_rec = UR.undo_stack[#UR.undo_stack]
	local type = last_rec.type
	
	if type == e_OpType.Delete then
		for i, v in ipairs(last_rec.note_list) do
			table.insert(App.note_list, v)
		end
	end
	
	if type == e_OpType.Insert then
		for i, v in ipairs(last_rec.note_list) do
			local idx = Util.GetNoteIndexAtCell(v.offset, v.string_idx)
			table.remove(App.note_list, idx)
		end
	end
	
	if type == e_OpType.ModifyPitchAndDuration then
		local temp = {}
		
		for i, v in ipairs(last_rec.note_list) do
			local idx = Util.GetNoteIndexAtCell(v.offset, v.string_idx)
			
			temp.pitch = App.note_list[idx].pitch
			temp.duration = App.note_list[idx].duration
			
			App.note_list[idx].pitch = v.pitch
			App.note_list[idx].duration = v.duration
			
			v.pitch = temp.pitch
			v.duration = temp.duration
		end
	end
	
	if type == e_OpType.ModifyVelocityAndOffVelocity then
		local temp = {}
		
		for i, v in ipairs(last_rec.note_list) do
			local idx = Util.GetNoteIndexAtCell(v.offset, v.string_idx)
			
			temp.velocity = App.note_list[idx].velocity
			temp.off_velocity = App.note_list[idx].off_velocity
			
			App.note_list[idx].velocity = v.velocity
			App.note_list[idx].off_velocity = v.off_velocity
			
			v.velocity = temp.velocity
			v.off_velocity = temp.off_velocity
		end
	end
	
	if type == e_OpType.Move then
		local temp = {}
		-- pitch may be modified by moving note to different string. So we account for that too
		for i, v in ipairs(last_rec.note_list) do
			-- local idx = Util.GetNoteIndexAtCell(v.offset, v.string_idx)
			local idx = last_rec.indices[i]
			
			temp.offset = App.note_list[idx].offset
			temp.string_idx = App.note_list[idx].string_idx
			temp.pitch = App.note_list[idx].pitch
			
			App.note_list[idx].offset = v.offset
			App.note_list[idx].string_idx = v.string_idx
			App.note_list[idx].pitch = v.pitch
			
			v.offset = temp.offset
			v.string_idx = temp.string_idx
			v.pitch = temp.pitch
		end
	end
	
	-- push to the redo stack, pop from the undo
	UR.redo_stack[#UR.redo_stack + 1] = last_rec
	UR.undo_stack[#UR.undo_stack] = nil
	
	Util.ClearTable(App.note_list_selected)
	App.last_note_clicked = nil
end

function UR.PopRedo()
	if #UR.redo_stack == 0 then return; end
	
	-- restore op
	local last_rec = UR.redo_stack[#UR.redo_stack]
	local type = last_rec.type
	
	if type == e_OpType.Insert then
		for i, v in ipairs(last_rec.note_list) do
			table.insert(App.note_list, v)
		end
	end
	
	if type == e_OpType.Delete then
		for i, v in ipairs(last_rec.note_list) do
			local idx = Util.GetNoteIndexAtCell(v.offset, v.string_idx)
			table.remove(App.note_list, idx)
		end
	end
	
	if type == e_OpType.ModifyPitchAndDuration then
		local temp = {}
		
		for i, v in ipairs(last_rec.note_list) do
			local idx = Util.GetNoteIndexAtCell(v.offset, v.string_idx)
			
			temp.pitch = App.note_list[idx].pitch
			temp.duration = App.note_list[idx].duration
			
			App.note_list[idx].pitch = v.pitch
			App.note_list[idx].duration = v.duration
			
			v.pitch = temp.pitch
			v.duration = temp.duration
		end
	end
	
	if type == e_OpType.ModifyVelocityAndOffVelocity then
		local temp = {}
		
		for i, v in ipairs(last_rec.note_list) do
			local idx = Util.GetNoteIndexAtCell(v.offset, v.string_idx)
			
			temp.velocity = App.note_list[idx].velocity
			temp.off_velocity = App.note_list[idx].off_velocity
			
			App.note_list[idx].velocity = v.velocity
			App.note_list[idx].off_velocity = v.off_velocity
			
			v.velocity = temp.velocity
			v.off_velocity = temp.off_velocity
		end
	end
	
	if type == e_OpType.Move then
		local temp = {}
		
		for i, v in ipairs(last_rec.note_list) do
			local idx = last_rec.indices[i]
			
			temp.offset = App.note_list[idx].offset
			temp.string_idx = App.note_list[idx].string_idx
			temp.pitch = App.note_list[idx].pitch
			
			App.note_list[idx].offset = v.offset
			App.note_list[idx].string_idx = v.string_idx
			App.note_list[idx].pitch = v.pitch
			
			v.offset = temp.offset
			v.string_idx = temp.string_idx
			v.pitch = temp.pitch
		end
	end
	
	-- push to the undo stack, pop from the redo
	UR.undo_stack[#UR.undo_stack + 1] = last_rec
	UR.redo_stack[#UR.redo_stack] = nil
end