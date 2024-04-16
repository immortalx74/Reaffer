-- Reaffer
-- Based on Ample Sound's riffer found in their guitar/bass VSTs
-- immortalx

-- TODO 
-- When reducing measure count, keep all notes internally (even those on a higher measure count) and if necessary,
-- shorten notes duration (ONLY visually) which happen to start on a valid measure, but their duration extends beyond the measure's boundary.
--
-- Current dragging system allows each note's properties to be clamped individually
-- Riffer works differently. It clamps all notes to the lowest possible change of that particular property (pitch, position, etc.)
-- Sometimes the first behavior is desirable though. Maybe have a setting for this?
--
-- There's currently no way to change tuning. Not an easy way to do that.
-- What happens to the notes that fall outside of a string's range,
-- when you change tuning during a session? Needs thinking
--
-- Generated MIDI item is just a test. No reason to develop it further until articulations are implemented.

package.path = reaper.ImGui_GetBuiltinPath() .. '/?.lua'
require 'imgui' '0.8.7'

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
dofile(script_path .. "Clipboard.lua")
dofile(script_path .. "Input.lua")
dofile(script_path .. "Debug.lua")

App.Init()
reaper.defer(App.Loop)
