-- Reaffer
-- Based on Ample Sound's riffer found in their guitar/bass VSTs
-- immortalx

-- TODO 
-- When reducing measure count, keep all notes internally (even those on a higher measure count) and if necessary,
-- shorten notes duration (ONLY visually) which happen to start on a valid measure, but their duration extends beyond the measure's boundary.
--
-- Implement Cut, Copy, Paste
--
-- Allow multiple selection with marquee. Don't mimic riffer exact behavior. (it always sets leftmost note as the "active" one?)
-- Also, auto-scroll when marquee is close to editor edges
--
-- Implement Undo system. Shouldn't keep selection. Just clear selection if a deleted note was selected.
--
-- Clamp moving notes. They currently can end out of the editor boundaries and can overlap each other.
-- Also, when a note moves to another string, try to match the same pitch on different fret, if possible.
-- If not, try to match pitch on higher/lower octave when moving up/down respectively.
-- 
-- Current dragging system allows each note's properties to be clamped individually
-- Riffer works differently. It clamps all notes to the lowest possible change of that particular property (pitch, position, etc.)
-- Sometimes the first behavior is desirable though. Maybe have a setting for this?
--
-- There's currently no way to change tuning. Not an easy way to do that.
-- What happens to the notes that fall outside of a string's range,
-- when you change tuning during a session? Needs thinking

function msg(txt)
	reaper.ShowConsoleMsg(tostring(txt) .. "\n")
end

local script_path = debug.getinfo(1).source:match("@?(.*[\\|/])")
dofile(script_path .. "Constants.lua")
dofile(script_path .. "App.lua")
dofile(script_path .. "UI.lua")
dofile(script_path .. "Toolbar.lua")
dofile(script_path .. "Util.lua")
dofile(script_path .. "Editor.lua")
dofile(script_path .. "UndoRedo.lua")

App.Init()
reaper.defer(App.Loop)