extends RigidBody2D

var target : Node2D
var rot_power : int = 0.5
var uuid : String
var ability_name : String
var caster : Node
var pinned_to_caster : bool = false 

@export var starting : bool = true
@export var ending : bool = false

func _ready():
	uuid = DataRepository.uuid_generator.v4()
	name = uuid
	
func GetMapProjectileData():
	var return_dict : Dictionary = {
		"type" : ability_name,
		"pos": get_global_position(),
		"rot": rotation
	}
	return return_dict

func _physics_process(delta):
	if pinned_to_caster:
		position = caster.get_global_position()
	
	if target && is_instance_valid(target) && not starting:
		#rotation = lerp(rotation, get_angle_to(target.get_global_position()), 0.5)
		rotation = lerp(rotation,get_global_position().angle_to_point(target.get_global_position()), 0.1)
		apply_central_force(Vector2(cos(rotation), sin(rotation))*200)

		
func Cast(casting_node, trg):
	target = trg
	caster = casting_node
	if target:
		var vector : Vector2 = target.get_global_position() - get_global_position()
		vector = vector.normalized()
		apply_central_impulse(vector*500)
	else:
		apply_central_impulse(casting_node.direction*200)

func _on_body_entered(body):
	end_projectile()
	
func _on_timer_timeout():
	end_projectile()
	
func start_projectile():
	starting = false
	
func end_projectile():
	ending = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	var tween = create_tween()
	$CPUParticles2D.emitting = false
	tween.tween_property(self, "modulate", Color(1,1,1,0),1)
	await tween.finished
	queue_free()

func _on_hitbox_body_entered(body):
	if body == caster:
		return
	end_projectile()
