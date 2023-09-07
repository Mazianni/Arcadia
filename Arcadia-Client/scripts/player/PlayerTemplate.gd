class_name PlayerObject extends CharacterBody2D

var camera_scene = preload("res://scenes/MainCamera.tscn")

var effects : Dictionary
var effect_timers : Dictionary

func MovePlayer(location, do_tween : bool = true):
	if do_tween:
		var tween = create_tween()
		tween.tween_property(self, "position", location, 0.05)
	set_position(location)
	
func SpawnCamera():
	var camera : Node = camera_scene.instantiate()
	add_child(camera)
	
func UpdateEffects():
	for i in effects.keys():
		if effects[i].has("ephemeral"):
			if effect_timers.keys.has(i):
				var timer : Timer = effect_timers[i]
				timer.start(effects[i]["timer"]-Time.get_unix_time_from_system())
			else:
				var timer = Timer.new()
				timer.start(effects[i]["timer"]-Time.get_unix_time_from_system())
				timer.timeout.connect(Callable(self, "RemoveStack").bind(i))
				effect_timers[i] = timer
				
func RemoveStack(stack:String):
	if effects[stack]["amount"] > 1:
		effects[stack]["amount"] -= 1
	else:
		effects.erase(stack)
		effect_timers[stack].queue_free()

func UpdateSprite(direction, moving):

	if moving:
		$Sprite2D.hide()
		$animations/walk_east.hide()
		$animations/walk_west.hide()
		$animations/walk_south.hide()
		$animations/walk_north.hide()
		match direction:
			Vector2(1,0):
				$animations/walk_east.show()
				$animations/walk_east.play("default")
			Vector2(-1,0):
				$animations/walk_west.show()
				$animations/walk_west.play("default")
			Vector2(0,-1):
				$animations/walk_north.show()
				$animations/walk_north.play("default")
			Vector2(0,1):
				$animations/walk_south.show()
				$animations/walk_south.play("default")
	else:
		$animations/walk_east.hide()
		$animations/walk_west.hide()
		$animations/walk_south.hide()
		$animations/walk_north.hide()
		$animations/walk_east.stop()
		$animations/walk_west.stop()
		$animations/walk_south.stop()
		$animations/walk_north.stop()
		$Sprite2D.show()
		match direction:
			Vector2(1,0):
				$Sprite2D.texture = preload("res://sprites/player/human_new/new_human_east.tres")
			Vector2(-1,0):
				$Sprite2D.texture = preload("res://sprites/player/human_new/new_human_west.tres")
			Vector2(0,-1):
				$Sprite2D.texture = preload("res://sprites/player/human_new/new_human_north.tres")
			Vector2(0,1):
				$Sprite2D.texture = preload("res://sprites/player/human_new/new_human_south.tres")

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouse:
		if Input.is_action_just_pressed("click"):
			Globals.SetSelectedPlayer(self)
			material = preload("res://resources/shaders/outline_material.tres")
