extends Node

var type = "neutral"
var message = ""
var color : Color
var flash_animation = preload("res://new_animation.tres")

func _ready():
	match type:
		"good":
			color = Color.GREEN
		"neutral":
			color = Color.WHITE
		"bad":
			color = Color.RED
	get_node("CenterContainer/Label").add_theme_color_override("font_color", color)
	get_node("CenterContainer/Label").text = message
	get_node("AnimationPlayer").set_current_animation("flash")

func _on_Timer_timeout():
	var tween : Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1)

func _on_DeleteTimer_timeout():
	self.queue_free()
