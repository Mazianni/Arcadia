extends RigidBody2D

var target : Node2D
var rot_power : int = 0.5
var base_speed : Vector2 = Vector2(20, 20)

func _ready():
	$CPUParticles2D2.emitting = true

func _on_body_entered(body):
	end_projectile()
	
func _on_timer_timeout():
	end_projectile()
	
func end_projectile():
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	var tween = create_tween()
	$CPUParticles2D.emitting = false
	tween.tween_property(self, "modulate", Color(1,1,1,0),1)
	await tween.finished
	queue_free()
