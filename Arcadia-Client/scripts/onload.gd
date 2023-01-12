extends Node
#dump to main menu when ready.
func _ready():
	var root = get_node("../RootNode/GUI")
	var next_level_resource = load("res://scenes/LoginScreen.tscn")
	var next_level = next_level_resource.instance()
	root.call_deferred("add_child", next_level)
