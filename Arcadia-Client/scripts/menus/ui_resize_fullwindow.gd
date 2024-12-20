extends Node

@onready var viewport = get_viewport()
@onready var game_size = Vector2(get_parent().size.x)

func _ready():
	viewport.connect("size_changed", Callable(self, "resize_viewport"))
	resize_viewport()

func resize_viewport():
	var new_size = get_window().get_size()
	var scale_factor

	if new_size.x < game_size.x:
		scale_factor = game_size.x/new_size.x
		new_size = Vector2(new_size.x*scale_factor, new_size.y*scale_factor)
	if new_size.y < game_size.y:
		scale_factor = game_size.y/new_size.y
		new_size = Vector2(new_size.x*scale_factor, new_size.y*scale_factor)

	viewport.set_size_2d_override(true, new_size)
