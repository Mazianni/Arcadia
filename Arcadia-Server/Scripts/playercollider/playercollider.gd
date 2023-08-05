class_name PlayerCollider extends CharacterBody2D

var ControllingCharacter : ActiveCharacter
var player_state
var direction = Vector2()

func _ready():
	velocity = Vector2()

func _physics_process(delta):
	UpdatePlayerState()
	velocity = Vector2.ZERO

func UpdateVector(vector, direction): # TODO verify velocity does not exceed sane limits
	velocity = vector
	direction = direction
	velocity = velocity.normalized()
	set_velocity(velocity * 280)
	move_and_slide()

func UpdatePlayerState():
	if ControllingCharacter:
		ControllingCharacter.CurrentPosition = get_global_position()
		player_state = {"T":"","P": get_global_position(), "M":ControllingCharacter.CurrentMap, "D":direction}
		DataRepository.Server.GeneratePlayerStates(ControllingCharacter.CharacterData["uuid"],player_state)
		
func GetPlayerState():
	if ControllingCharacter:
		ControllingCharacter.CurrentPosition = get_global_position()
		var pstate : Dictionary = {"T":"","P": get_global_position(), "M":ControllingCharacter.CurrentMap, "D":direction}
		return pstate
