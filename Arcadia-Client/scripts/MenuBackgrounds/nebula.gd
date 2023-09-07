extends Node

var time : float = 0

func _process(delta):
	time += 0.0001
	$ColorRect.material.set_shader_parameter("time", time)
