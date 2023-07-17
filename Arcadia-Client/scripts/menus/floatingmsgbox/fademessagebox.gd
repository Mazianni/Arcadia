extends Node

var message = ""

func _ready():
	$CenterContainer/Label.text = message
	var tween : Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 1)

func _on_Timer_timeout():
	var tween : Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 1)

func _on_DeleteTimer_timeout():
	self.queue_free()

