extends ParallaxBackground

onready var viewport = get_viewport()
onready var game_size = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height"))

func _ready():
	viewport.connect("size_changed", self, "resize_viewport")
	resize_viewport()

func resize_viewport():
	var new_size = OS.get_window_size()
	var scale_factor = round(new_size.y / 640)
	print(scale_factor)

	set_scale(Vector2(scale_factor, scale_factor))

