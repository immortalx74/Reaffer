e_Tool = 
{
	Create = 1,
	Select = 2,
	Move = 3,
	Draw = 4,
	Erase = 5,
	Undo = 6,
	Redo = 7,
	Cut = 8,
	Copy = 9,
	Paste = 10
}

e_NoteDisplay = 
{
	Pitch = 1,
	Fret = 2,
	PitchAndFret = 3,
	Velocity = 4,
	OffVelocity = 5,
	MIDIPitch = 6
}

e_Direction = 
{
	Left = 1,
	Right = 2
}

e_MouseButton = 
{
	Left = 1,
	Right = 2,
	Middle = 3
}

e_OpType = 
{
	NoOp = 1,
	Insert = 2,
	Delete = 3,
	ModifyPitchAndDuration = 4,
	ModifyVelocityAndOffVelocity = 5,
	Move = 6
	-- more here...
}

Colors = 
{
	lane = 0x606060FF,
	bg = 0x0F0F0FFF,
	active_tool = 0x3D85E0FF,
	note_preview = 0xFFFFFF88,
	note_preview_paste = 0xAAAAAA55,
	red = 0xFF0000FF,
	text = 0xFFFFFFFF,
	marquee_box = 0xFFFFFF44
}