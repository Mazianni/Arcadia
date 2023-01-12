extends KinematicBody2D

var velocity = Vector2()
var direction = Vector2()

func on_movement():
	velocity = Vector2()

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
