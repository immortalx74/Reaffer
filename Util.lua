Util = {}

function Util.HorSpacer(num_spacers)
	for i = 0, num_spacers - 1 do
		reaper.ImGui_SameLine(App.ctx)
		reaper.ImGui_Spacing(App.ctx)
	end
	reaper.ImGui_SameLine(App.ctx)
end

function Util.NumGridDivisions()
	App.num_grid_divisions = App.num_measures * App.signature[App.signature_cur_idx].beats * App.signature[App.signature_cur_idx].subs
	return App.num_grid_divisions
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

function Util.GetCellX()
	return math.floor((App.mouse_x - App.arrange_win_x + App.scroll_x -15) / App.note_w) - 1
end

function Util.GetCellY()
	return math.floor((App.mouse_y - App.arrange_win_y - App.top_margin + 5) / App.note_h)
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

function Util.GetCellNearestOccupied(cx, cy, direction)
	local cur = App.num_grid_divisions

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