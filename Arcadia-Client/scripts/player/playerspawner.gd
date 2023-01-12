extends Node

func _ready():
	_spawnplayer()

func _spawnplayer():
	var root = get_tree().get_root().get_node("RootNode")
	
	var next_level_resource = load("res://scenes/PlayerObject.tscn")
	var next_level = next_level_resource.instance()
	root.call_deferred("add_child", next_level)
