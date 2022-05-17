Util = {}

function Util.HorSpacer(num_spacers)
	for i = 0, num_spacers - 1 do
		reaper.ImGui_SameLine(App.ctx)
		reaper.ImGui_Spacing(App.ctx)
	end
	reaper.ImGui_SameLine(App.ctx)
end

function Util.NumGridDivisions()
	return (App.num_measures * App.signature[App.signature_cur_idx].beats * App.signature[App.signature_cur_idx].subs)
end

function Util.Clamp(n, n_min, n_max)
	if n < n_min then n = n_min
	elseif n > n_max then n = n_max
	end
	
	return n
end

function Util.PackRGBA(r, g, b, a)
	return (r<<24 | g<<16 | b<<8 | a)
end

function Util.VelocityColor(v)
	v = Util.Clamp(v, 0, 127)
	local g = 23
	local bt = math.floor(127 - v)
	local rt = 127 - bt
	
	local r = math.floor(Util.Clamp((255 * rt) / 127, 0, 255))
	local b = math.floor(Util.Clamp((255 * bt) / 127, 0, 255))
	
	return Util.PackRGBA(r, g, b, 255)
end

function Util.NotePitchToName(note_pitch)
	local mul = math.floor(note_pitch / 12)
	local idx = note_pitch - (mul * 12)
	return App.note_sequence[idx + 1] .. mul - 1
end

function Util.NoteNameToPitch(note_name)
	
	local len = string.len(note_name)
	local wname
	
	if len == 2 then
		wname = string.sub(note_name, 1, 1)
	else
		wname = string.sub(note_name, 1, 2)
	end
	
	local idx = 0
	
	for i, v in ipairs(App.note_sequence) do
		if v == wname then
			idx = i
			break
		end
	end
	
	local oct = string.sub(note_name, len, len)
	local base = 12 -- pitch of C0
	return (base + idx - 1) + (oct * 12)
end

function Util.NotePitchToFret(pitch, string_idx)
	local open = App.instrument[App.num_strings - 3].open[App.num_strings - string_idx]
	return math.floor(pitch - open)
end

function Util.GetCellX()
	return math.floor((App.mouse_x - App.editor_win_x + App.scroll_x -15) / App.note_w) - 1
end

function Util.GetCellY()
	return math.floor((App.mouse_y - App.editor_win_y - App.top_margin + 5) / App.note_h)
end

function Util.IsCellEmpty(cx, cy, duration_inclusive)
	for i, note in ipairs(App.note_list) do
		local start_x = note.offset
		local end_x = start_x + note.duration - 1
		if duration_inclusive then
			if (cx >= start_x) and (cx <= end_x) and (note.string_idx == cy) then return false; end
		else
			if (cx == start_x) and (note.string_idx == cy) then return false; end
		end
	end
	return true
end

-- TODO Need to do Left direction too. (Or not?)
function Util.GetCellNearestOccupied(cx, cy, direction)
	local cur = Util.NumGridDivisions()
	
	if direction == e_Direction.Right then
		for i, note in ipairs(App.note_list) do
			if (cy == note.string_idx) and (note.offset > cx) then
				if note.offset < cur then
					cur = note.offset
				end
			end
		end
		return cur
	end
end

function Util.CreateMIDI()
	local ppq = 960
	local q = {0.25, 0.5, 1, 2, 4, 8, 16}
	-- {"1/1", "1/2", "1/4", "1/8", "1/16", "1/32", "1/64"},
	ratio = ppq / q[App.quantize_cur_idx]

	local track = reaper.GetSelectedTrack(0, 0)
	if track == nil then return; end

	local start_time_secs = reaper.GetCursorPositionEx(0)
	local end_time_secs = reaper.TimeMap2_beatsToTime(0, 0, App.num_measures)
	local new_item = reaper.CreateNewMIDIItemInProj(track, start_time_secs, start_time_secs + end_time_secs)
	local take = reaper.GetActiveTake(new_item)
	local start_ppq = reaper.MIDI_GetPPQPosFromProjTime(take, start_time_secs)

	local note_begin
	local note_end
	
	for i, note in ipairs(App.note_list) do
		note_begin = start_ppq + (note.offset * ratio)
		note_end = note_begin + (note.duration * ratio)
		reaper.MIDI_InsertNote(take, false, false, note_begin, note_end, 0, note.pitch, note.velocity)
	end
end

function Util.CopyNote(note)
	local t = {idx = note.idx, offset = note.offset, string_idx = note.string_idx, pitch = note.pitch, velocity = note.velocity, duration = note.duration}
	return t
end

function Util.ClearTable(t)
	for i, v in ipairs(t) do
		t[i] = nil
	end
end

function Util.IsNoteSelected(note)
	local idx = note.idx
	
	for i, v in ipairs(App.note_list_selected) do
		if v.idx == idx then
			return true
		end
	end 
	
	return false
end

function Util.IsNoteAtCellSelected(cx, cy)
	for i, v in ipairs(App.note_list_selected) do
		if (cx >= v.offset) and (cx < v.offset + v.duration) and (cy == v.string_idx) then
			return true
		end
	end
	
	return false
end

function Util.GetNoteIndexAtCell(cx, cy)
	for i, v in ipairs(App.note_list) do
		if (cx >= v.offset) and (cx < v.offset + v.duration) and (cy == v.string_idx) then
			return i
		end
	end

	return 0 -- Not found
end

function Util.UpdateSelectedNotes()
	if #App.note_list == 0 or #App.note_list_selected == 0 then return; end
	for i, v in ipairs(App.note_list_selected) do
		App.note_list_selected[i] = Util.CopyNote(App.note_list[App.note_list_selected[i].idx])
	end
end

function Util.RecalculateStoredNoteIndices()
	if #App.note_list == 0 then return; end
	for i, v in ipairs(App.note_list) do
		v.idx = i
	end
end