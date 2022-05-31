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
	table.sort(Clipboard.note_list, function (k1, k2) return k1.offset < k2.offset; end)
	return true
end

function Clipboard.Paste(cx, cy)
	local temp = {}
	for i, v in ipairs(Clipboard.note_list) do
		temp[#temp + 1] = Util.CopyNote(v)
	end
	
	local right_bound = Util.NumGridDivisions()
	local src_offset = temp[1].offset
	local diff = 0
	local dst_offset = 0
	
	for i, v in ipairs(temp) do
		diff = v.offset - src_offset
		dst_offset = cx + diff
		v.offset = dst_offset

		if v.offset + v.duration > right_bound then
			return
		end
		
		for j, w in ipairs(App.note_list) do
			if (v.string_idx == w.string_idx) and (Util.RangeOverlap(v.offset, v.offset + v.duration - 1, w.offset, w.offset + w.duration - 1)) then
				return
			end
		end
	end
	
	for i, v in ipairs(temp) do
		App.note_list[#App.note_list + 1] = Util.CopyNote(v)
	end
	
	UR.PushUndo(e_OpType.Insert, temp)
	Util.ClearTable(App.note_list_selected)
	App.attempts_paste = false
end