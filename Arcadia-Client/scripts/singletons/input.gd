extends Node

var request_velocity = Vector2()
var direction = Vector2()

func ready() -> void:
	get_viewport().connect("gui_focus_changed", Callable(self, "_on_focus_changed"))

func _physics_process(delta):
	pass
	if Globals.client_state == Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		on_movement()
		
func _on_focus_changed(control:Control) -> void:
	if control != null:
		print(control.name)
		print("shit")

func on_movement():
	print("fart")
	request_velocity = Vector2.ZERO
	
	if Globals.MouseOnUi:
		return

	if Input.is_action_pressed("up"):
		request_velocity.y -= 1
		direction = Vector2(0, -1)
		
	if Input.is_action_pressed("down"):
		request_velocity.y += 1
		direction = Vector2(0, 1)
		
	if Input.is_action_pressed("left"):
		request_velocity.x -= 1
		direction = Vector2(-1, 0)
		
	if Input.is_action_pressed("right"):
		request_velocity.x += 1
		direction = Vector2(1, 0)
		
	request_velocity = request_velocity.normalized()
	Server.RequestMovement(request_velocity, direction)
