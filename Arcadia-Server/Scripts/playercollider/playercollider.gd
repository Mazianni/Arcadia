class_name PlayerCollider extends CharacterBody2D

var ControllingCharacter : ActiveCharacter
var CurrentMap
var player_state
var direction
var moving : bool = false
var last_input : float = 0

func _ready():
	velocity = Vector2()

func _physics_process(delta):
	UpdatePlayerState()
	
	move_and_slide()
	if velocity.is_equal_approx(Vector2.ZERO):
		moving = false
	else:
		moving = true
	
func UpdateVector(vector, direction): # TODO verify velocity does not exceed sane limits
	velocity = vector
	velocity = velocity.normalized()
	set_velocity(velocity * 280)
	self.direction = direction
	last_input = Time.get_unix_time_from_system()

func UpdatePlayerState():
	if ControllingCharacter:
		ControllingCharacter.CurrentPosition = get_global_position()
		player_state = {"T":"","P": get_global_position(), "M":ControllingCharacter.CurrentMap, "D":direction, "MV":moving}
		DataRepository.Server.GeneratePlayerStates(ControllingCharacter.CharacterData.uuid,player_state)
		
func GetPlayerState():
	if ControllingCharacter:
		ControllingCharacter.CurrentPosition = get_global_position()
		var pstate : Dictionary = {"T":"","P": get_global_position(), "M":ControllingCharacter.CurrentMap, "D":direction, "MV":moving}
		return pstate
