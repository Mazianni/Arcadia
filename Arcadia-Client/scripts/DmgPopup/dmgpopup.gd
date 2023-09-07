extends Control


func RenderPopup(damage, type, critical:=false):
	var linger_time = 1
	var extra_rand = 0
	var font_color = Color.WHITE.to_html()
	if damage < 4000:
		scale = Vector2(1.2, 1.2)
		extra_rand = 3
	elif damage > 6000:
		scale = Vector2(1.4, 1.4)
		extra_rand = 5
		linger_time = 2
	elif damage > 8000:
		scale = Vector2(1.6, 1.6)
		linger_time = 3
		extra_rand = 7
		
	match type:
		"heal":
			font_color = Color.LAWN_GREEN.to_html()
			
	$RichTextLabel.text = "[center][color="+font_color+"]"+str(damage)+"[/color][/center]"
	var rand_x = randi_range(-30-extra_rand, 30+extra_rand)
	var rand_y = randi_range(-30-extra_rand, 0)
	var new_pos = Vector2(position.x+rand_x, position.y+rand_y)
	var tween = create_tween()
	tween.tween_property(self, "position", new_pos, 0.1)
	var timer = get_tree().create_timer(linger_time)
	timer.timeout.connect(Callable(self, "fadeout"))
	
func fadeout():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 0.5)
	tween.finished.connect(Callable(self, "queue_free"))
