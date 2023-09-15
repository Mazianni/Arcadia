class_name PlayerCollider extends RigidBody2D

var ControllingCharacter : ActiveCharacter
var CurrentMap
var player_state
@export var direction : Vector2
@export var moving : bool = false
var last_input : float = 0
var last_vector : Vector2 = Vector2.ZERO
var normal_max :int = 155
var walking_max : int = 155
var running_max : int = 255
var dashing_max : int = 750
@export var dashing : bool = false
var acting_forces : bool = false
@export var running : bool = false
var teleport_to : Vector2

func _physics_process(delta):
	UpdatePlayerState()
	
	if linear_velocity.is_equal_approx(Vector2.ZERO):
		moving = false
	else:
		moving = true
	if teleport_to != Vector2.ZERO:
		set_global_position(teleport_to)
		teleport_to = Vector2.ZERO
		
func _integrate_forces(state:PhysicsDirectBodyState2D):
	if state.linear_velocity.length() > normal_max && not acting_forces: 
		state.linear_velocity=state.linear_velocity.normalized()*normal_max
	if last_vector == Vector2.ZERO && not acting_forces && not dashing:
		state.linear_velocity = Vector2.ZERO
		
func UpdateVector(vector, direction): # TODO verify velocity does not exceed sane limits
	if dashing:
		apply_central_impulse(vector*50) # dampen input considerably.
	else:
		apply_central_impulse(vector*550)
	self.direction = direction
	last_vector = vector
	if vector != Vector2.ZERO:
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
		
func SetDash():
	dashing = true
	if last_input < Time.get_unix_time_from_system()+1:
		apply_central_force(last_vector * 1750)
	else:
		apply_central_force(direction * 1750)
	normal_max = dashing_max
	get_tree().create_timer(0.3).timeout.connect(Callable(self, "UnsetDash"))
	
func UnsetDash():
	if running:
		normal_max = running_max
	else:
		normal_max = walking_max
	dashing = false

func _on_hitbox_area_entered(area):
	print("shit3")


func _on_hitbox_body_entered(body):
	print("shit4")
