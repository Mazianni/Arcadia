extends RigidBody2D

var target : Node2D
var rot_power : int = 0.5
var base_speed : Vector2 = Vector2(20, 20)

func _physics_process(delta):
	
	var angle : float = get_angle_to(target.get_global_position())
	if angle > 180:
		apply_torque(float(rot_power))
	if angle < 180:
		apply_torque(-float(rot_power))

func Cast(trg):
	target = trg
	apply_central_impulse(base_speed.rotated(get_angle_to(target.get_global_position())))

func _on_body_entered(body):
	queue_free()
	
func _on_timer_timeout():
	queue_free()
