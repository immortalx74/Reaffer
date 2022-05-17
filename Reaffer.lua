-- Reaffer
-- Based on Ample Sound's riffer found in their guitar/bass VSTs
-- immortalx

-- TODO 
-- When reducing measure count, keep all notes (even those on a higher measure count) and if necessary,
-- shorten notes (ONLY visually) which happen to belong to a valid measure, but extend beyond its boundary.
--
-- Implement Cut, Copy, Paste
--
-- Allow multiple selection with marquee. Don't mimic riffer exact behavior. (it always sets leftmost note as the "active" one?)
--
-- Implement Undo system. Shouldn't affect selection. Just clear selection if a deleted note was selected.

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