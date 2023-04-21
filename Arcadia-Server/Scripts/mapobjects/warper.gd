extends Node

var position : Vector2 = Vector2(0,0)
var warp_to : String = "none"
var parent_map : String = "none"

func _on_Area2D_body_entered(body):
	DataRepository.MapManager.MovePlayerToMap(body, parent_map, warp_to, position)
