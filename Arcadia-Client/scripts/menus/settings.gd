extends Node

func _pressback():
	var root = get_tree().get_root().get_node("RootNode")
	var level = root.get_node("SettingsRender")
	root.remove_child(level)
	level.call_deferred("free")
	
	var next_level_resource = load("res://scenes/MainMenu.tscn")
	var next_level = next_level_resource.instance()
	root.call_deferred("add_child", next_level)

func _on_Back_pressed():
	_pressback()
