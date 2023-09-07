extends Node

var message = ""

func _ready():
	$CenterContainer/Label.text = message
	var tween : Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,1), 1)

func _on_Timer_timeout():
	var tween : Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 1)
	tween.finished.connect(Callable(self, "timeout"))

func timeout():
	self.queue_free()

