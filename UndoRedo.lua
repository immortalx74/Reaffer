UR = 
{
	undo_stack = {},
	redo_stack = {}
	-- {type = ?, note_list = {	{idx = ?, offset = ?, etc}, {idx = ?, offset = ?, etc}, ...	}	}
	-- {type = ?, note_list = {	{idx = ?, offset = ?, etc}, {idx = ?, offset = ?, etc}, ...	}	}
}

function UR.PushUndo(type, note_list)
	local new_rec = {type = type, note_list = note_list}
	UR.undo_stack[#UR.undo_stack + 1] = new_rec
end

function UR.PopUndo()
	if #UR.undo_stack == 0 then return; end
	
	local last_rec = UR.undo_stack[#UR.undo_stack]
	local type = last_rec.type
	
	-- do op
	if type == e_OpType.Insert then
		for i, v in ipairs(last_rec.note_list) do
			table.remove(App.note_list, v.idx)
		end
	end
	
	-- push to the redo stack, pop from the undo
	UR.redo_stack[#UR.redo_stack + 1] = last_rec
	UR.undo_stack[#UR.undo_stack] = nil
end

function UR.PushRedo()
end

function UR.PopRedo()
	if #UR.redo_stack == 0 then return; end
	
	-- restore op
	local last_rec = UR.redo_stack[#UR.redo_stack]
	local type = last_rec.type
	
	if type == e_OpType.Insert then
		for i, v in ipairs(last_rec.note_list) do
			-- NOTE restoring notes to their original idx (slow). Could restore them to the end of the table. Needs thinking.
			table.insert(App.note_list, v.idx, v)
		end
	end
	
	-- push to the undo stack, pop from the redo
	UR.undo_stack[#UR.undo_stack + 1] = last_rec
	UR.redo_stack[#UR.redo_stack] = nil
end