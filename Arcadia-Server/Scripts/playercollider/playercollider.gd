extends KinematicBody2D

var ControllingCharacter : ActiveCharacter
var player_state
var velocity = Vector2()
var direction = Vector2()

func _physics_process(delta):
	UpdatePlayerState()
	velocity = Vector2.ZERO

func UpdateVector(vector, direction): # TODO verify velocity does not exceed sane limits
	velocity = vector
	direction = direction
	velocity = velocity.normalized()
	move_and_slide(velocity * 280)

func UpdatePlayerState():
	if ControllingCharacter:
		ControllingCharacter.CurrentPosition = get_global_position()
		player_state = {"T":"","P": get_global_position(), "M":ControllingCharacter.CurrentMap, "D":direction}
		get_tree().get_root().get_node("Server").GeneratePlayerStates(ControllingCharacter.CharacterData["uuid"],player_state)
