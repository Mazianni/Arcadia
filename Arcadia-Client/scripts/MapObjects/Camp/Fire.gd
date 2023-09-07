extends Node


func _ready():
	pass # Replace with function body.

func _process(delta):
	var tween = create_tween()
	tween.tween_property($Sprite2D/PointLight2D,"energy", randf_range(0.5, 1), 0.2)
