extends Node

func _ready():
	connect("mouse_entered", self, "entered")
	connect("mouse_exited", self, "exited")
	
func entered():
	Globals.MouseOnUi = true
	print("Mouse Entered UI")
	
func exited():
	Globals.MouseOnUi = false
	print("Mouse Exited UI")
	
	
