extends Node

func _playbuttonpress():
	var root = get_tree().get_root().get_node("RootNode")
	var level = root.get_node("MenuRender2D")
	root.remove_child(level)
	level.call_deferred("free")
	
	# var next_level_resource = load("res://scenes/CharacterSelection.tscn") commented out until later for now. 
	var next_level_resource = load("res://scenes/Game.tscn")
	var next_level = next_level_resource.instantiate()
	root.call_deferred("add_child", next_level)
	
func _settingsbuttonpress():
	var root = get_tree().get_root().get_node("RootNode")
	var level = root.get_node("MenuRender2D")
	root.remove_child(level)
	level.call_deferred("free")
	
	var next_level_resource = load("res://scenes/Settings.tscn")
	var next_level = next_level_resource.instantiate()
	root.call_deferred("add_child", next_level)
	
func _quitbuttonpress():
	get_tree().quit()

func _on_PlayButton_pressed():
	_playbuttonpress()
	
func _on_Settings_pressed():
	_settingsbuttonpress()

func _on_Quit_pressed():
	_quitbuttonpress()
