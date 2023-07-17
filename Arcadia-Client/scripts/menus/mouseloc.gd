extends Node

func _ready():
	connect("mouse_entered", Callable(self, "entered"))
	connect("mouse_exited", Callable(self, "exited"))
	
func entered():
	Globals.MouseOnUi = true
	print("Mouse Entered UI")
	
func exited():
	Globals.MouseOnUi = false
	print("Mouse Exited UI")
	
	
