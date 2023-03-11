extends Node

var player_spawn = preload("res://scenes/PlayerTemplate.tscn")

func _ready():
	_spawnplayer()

func _spawnplayer():
	var root = get_tree().get_root().get_node("RootNode/MapHandler/ViewportContainer/Viewport/"+self.name)
	
	var next_level_resource = load("res://scenes/PlayerObject.tscn")
	var next_level = next_level_resource.instance()
	root.call_deferred("add_child", next_level)
	
func SpawnNewPlayer(player_id, spawn_position):
	if get_tree().get_network_unique_id() == player_id:
		pass
	else:
		var new_player = player_spawn.instance()
		new_player.position = spawn_position
		new_player.name = str(player_id)
		get_node("OtherPlayers").add_child(new_player)
		
func DespawnPlayer(player_id):
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("OtherPlayers/"+player_id).queue_free()
