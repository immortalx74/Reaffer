-- Reaffer ---------------------------------------------------

-- TODO 
-- When reducing measure count, keep all notes (even those on a higher measure count) and if necessary,
-- shorten notes (ONLY visually) which happen to belong to a valid measure, but extend beyond its boundary.
--
-- Implement Select, Move and Erase tools.
--
-- Implement Cut, Copy, Paste
--
-- Allow multiple selection with marquee. Don't mimic riffer exact behavior.
-- Use Select tool and click&drag on any empty area on arrange box.
-- "base" note is the last clicked note.
--
-- Implement Undo system. Shouldn't affect selection. Just clear selection if a deleted note was selected.
--
-- Add widgets for currently selected note(s). Velocity, Off Velocity, Pitch
-- Riffer works as follows with multiple selection: Chooses the "leftmost" note as the "base" of selection
-- It then allows the base note properties to be changed as normal, but clamps the rest of the notes.
-- Hard to explain in words...
--
-- Allow Select All shortcut
--
-- Provide option for note display: Fret, Pitch, Fret&Pitch, Velocity, Off-Velocity

function msg(txt)
	reaper.ShowConsoleMsg(tostring(txt))
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