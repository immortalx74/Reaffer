-- Reaffer ---------------------------------------------------
function msg(txt)
	reaper.ShowConsoleMsg(txt)
end

local script_path = debug.getinfo(1).source:match("@?(.*[\\|/])")
dofile(script_path .. "Constants.lua")
dofile(script_path .. "Colors.lua")
dofile(script_path .. "App.lua")
dofile(script_path .. "UI.lua")
dofile(script_path .. "Util.lua")
dofile(script_path .. "Toolbar.lua")
dofile(script_path .. "Editor.lua")

App.Init()
reaper.defer(App.Loop)