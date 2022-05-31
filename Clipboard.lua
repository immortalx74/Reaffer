Clipboard = 
{
	note_list = {}
}

function Clipboard.Cut()
	if Clipboard.Copy() then 
		Editor.EraseNotes(App.note_list_selected[1].offset, App.note_list_selected[1].string_idx)
	end
end

function Clipboard.Copy()
	if #App.note_list_selected == 0 then return false; end
	
	Util.ClearTable(Clipboard.note_list)
	Clipboard.note_list = Util.CopyTable(App.note_list_selected)
	return true
end

-- NOTE: WIP. Doesn't check for overlapping notes, out of bounds of measures, etc
function Clipboard.Paste(cx, cy)
	local temp = {}
	for i, v in ipairs(Clipboard.note_list) do
		temp[#temp + 1] = Util.CopyNote(v)
	end

	table.sort(temp, function (k1, k2) return k1.offset < k2.offset; end)
	local src_offset = temp[1].offset
	local diff = 0
	local dst_offset = 0
	
	for i, v in ipairs(temp) do
		diff = v.offset - src_offset
		dst_offset = cx + diff
		
		if Util.IsCellEmpty(dst_offset, v.string_idx, true) then
			v.offset = dst_offset
		else
			return
		end
	end

	for i, v in ipairs(temp) do
		App.note_list[#App.note_list + 1] = Util.CopyNote(v)
	end

	UR.PushUndo(e_OpType.Insert, temp)
	Util.ClearTable(App.note_list_selected)
	App.attempts_paste = false
end