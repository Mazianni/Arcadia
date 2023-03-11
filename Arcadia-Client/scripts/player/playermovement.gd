extends KinematicBody2D

var velocity = Vector2()
var direction = Vector2()

var player_state

func on_movement():
	velocity = Vector2()
	
	if Globals.MouseOnUi:
		return

	if Input.is_action_pressed("up"):
		velocity.y -= 1
		direction = Vector2(0, -1)
		get_node("Icon").texture = load("res://sprites/player/player_m_north.png")
		
	if Input.is_action_pressed("down"):
		velocity.y += 1
		direction = Vector2(0, 1)	
		get_node("Icon").texture = load("res://sprites/player/player_m_south.png")
		
	if Input.is_action_pressed("left"):
		velocity.x -= 1
		direction = Vector2(-1, 0)
		get_node("Icon").texture = load("res://sprites/player/player_m_west.png")
		
	if Input.is_action_pressed("right"):
		velocity.x += 1
		direction = Vector2(1, 0)
		get_node("Icon").texture = load("res://sprites/player/player_m_east.png")
		
	velocity = velocity.normalized()
	velocity = move_and_slide(velocity * 280)

func _physics_process(delta):
	on_movement()
	UpdatePlayerState()
	
func UpdatePlayerState():
	player_state = {"T:": Server.client_clock, "P:": get_global_position(), "M:":null, "D":null}
	print(player_state)
	Server.SendPlayerState(player_state)
