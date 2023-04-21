extends Node

onready var viewport = get_viewport()
onready var game_size = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height"))

func _ready():
	viewport.connect("size_changed", self, "resize_viewport")
	resize_viewport()
	get_node("AnimationPlayer").set_current_animation("introscreenfade")

func resize_viewport():
	var new_size = OS.get_window_size()
	var scale_factor

	if new_size.x < game_size.x:
		scale_factor = game_size.x/new_size.x
		new_size = Vector2(new_size.x*scale_factor, new_size.y*scale_factor)
	if new_size.y < game_size.y:
		scale_factor = game_size.y/new_size.y
		new_size = Vector2(new_size.x*scale_factor, new_size.y*scale_factor)
		
func _on_Timer_timeout():
	Globals.currentscene = Globals.CURRENT_SCENE.SCENE_LOGIN
	Gui.ChangeGUIScene("LoginScreen")
	yield(get_tree().create_timer(0.2),"timeout")
	queue_free()
