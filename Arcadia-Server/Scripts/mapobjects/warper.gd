extends Node

@export var to_position : Vector2 = Vector2(0,0)
@export var warp_to : String = "none"
@export var parent_map : String = "none"

func _ready():
	call_deferred("set_name",DataRepository.uuid_generator.v4())

func _on_Area2D_body_entered(body):
	if body.name in DataRepository.mapmanager.RecentWarps:
		return
	DataRepository.mapmanager.MovePlayerToMap(body, parent_map, warp_to, to_position)
