extends Node


# Called when the node enters the scene tree for the first time.
func CreateText(maintext, subtext):
	$VBoxContainer/RichTextLabel.text = maintext
	$VBoxContainer/RichTextLabel2.text = subtext
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1.5)
	await tween.finished
	var timer = get_tree().create_timer(1.5)
	timer.timeout.connect(Callable(self, "FadeOut"))


func FadeOut():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.5)
	await tween.finished
	queue_free()
