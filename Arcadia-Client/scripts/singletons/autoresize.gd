extends ParallaxBackground

@onready var viewport = get_viewport()
@onready var game_size = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height"))

func _ready():
	viewport.connect("size_changed", Callable(self, "resize_viewport"))
	resize_viewport()

func resize_viewport():
	var new_size = get_window().get_size()
	var scale_factor = 1
	if new_size.y > 700:
		scale_factor = 2

	set_scale(Vector2(scale_factor, scale_factor))

