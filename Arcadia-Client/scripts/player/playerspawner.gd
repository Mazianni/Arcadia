extends Node

var player_spawn = preload("res://scenes/PlayerTemplate.tscn")
var controllable_player_spawn = preload("res://scenes/PlayerObject.tscn")
var camera_scene = preload("res://scenes/MainCamera.tscn")
	
func SpawnNewPlayer(player_id, spawn_position, is_main):
	var new_player = player_spawn.instance()
	new_player.position = spawn_position
	new_player.name = str(player_id)
	get_node("PrimarySort/ObjectSortContainer/Players").add_child(new_player)
	if is_main:
		var camera = camera_scene.instance()
		new_player.add_child(camera)
		
func DespawnPlayer(player_id):
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("PrimarySort/ObjectSortContainer/Players"+player_id).queue_free()
