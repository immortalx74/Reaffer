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
	if #App.note_list_selected == 0 then
		return false
	end
	
	Util.ClearTable(Clipboard.note_list)
	Clipboard.note_list = Util.CopyTable(App.note_list_selected)
	return true
end

function Clipboard.Paste(cx, cy)
	-- do paste
	-- copy clipboard to temp table and sort by offset
	-- first pass: check each note if it "fits". The first one that doesn't fit means operation should be cancelled
	-- second pass: copy the notes from temp table to App.note_list
	local temp = {}
	temp = Util.CopyTable(Clipboard.note_list)
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
			msg("doesn't fit")
			return -- return or break?
		end
	end

	for i, v in ipairs(temp) do
		App.note_list[#App.note_list + 1] = Util.CopyNote(v)
	end

	Util.ClearTable(App.note_list_selected)
	
	-- for i, v in ipairs(Clipboard.note_list) do
	-- 	local new_note = Util.CopyNote(v)
	-- 	new_note.offset = v.offset + cx
	-- 	table.insert(App.note_list, new_note)
	-- end
	App.attempts_paste = false
end