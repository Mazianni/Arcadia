extends Node

var message = ""

func _ready():
	$CenterContainer/Label.text = message
	var tween : Tween = get_node("Tween")
	tween.interpolate_property(self, "modulate:a", 0, 1, 1)
	tween.start()

func _on_Timer_timeout():
	var tween : Tween = get_node("Tween")
	tween.interpolate_property(self, "modulate:a", 1, 0, 1)
	tween.start()

func _on_DeleteTimer_timeout():
	self.queue_free()

