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
		if App.note_sequence[i] == wname then
			idx = i
			break
		end
	end
	
	local oct = string.sub(note_name, len, len)
	local base = 12 -- pitch of C0
	return (base + idx - 1) + (oct * 12)
end