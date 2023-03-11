extends Node

var type = "neutral"
var message = ""
var color : Color
var flash_animation = preload("res://new_animation.tres")

func _ready():
	match type:
		"good":
			color = Color.green
		"neutral":
			color = Color.white
		"bad":
			color = Color.red
	get_node("CenterContainer/Label").add_color_override("font_color", color)
	get_node("CenterContainer/Label").text = message
	get_node("AnimationPlayer").set_current_animation("flash")

func _on_Timer_timeout():
	var tween : Tween = get_node("Tween")
	tween.interpolate_property(self, "modulate:a", 1, 0, 1)
	tween.start()

func _on_DeleteTimer_timeout():
	self.queue_free()
