extends RigidBody2D

var target : Node2D
var rot_power : int = 0.5
var base_speed : Vector2 = Vector2(20, 20)
@export var starting : bool = true
@export var ending : bool = false
var start_begun : bool = false
var end_begun : bool = false

func _ready():
	$CPUParticles2D2.emitting = true
	start_projectile()

func _on_body_entered(body):
	end_projectile()
	
func _on_timer_timeout():
	end_projectile()
	
func _process(delta):
	if starting:
		start_projectile()
	if ending:
		end_projectile()
		
func start_projectile():
	if start_begun:
		return
	return
	
func end_projectile():
	if end_begun:
		return
	ending = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	var tween = create_tween()
	$CPUParticles2D.emitting = false
	tween.tween_property(self, "modulate", Color(1,1,1,0),1)
