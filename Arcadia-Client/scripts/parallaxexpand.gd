extends ParallaxBackground

@onready var viewport = get_viewport()
@onready var game_size = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height"))
var scroll_speed = 20

func _ready():
	viewport.connect("size_changed", Callable(self, "resize_viewport"))
	resize_viewport()

func resize_viewport():
	var new_size = get_window().get_size()
	var scale_factor = round(new_size.x / 1280)
	
	self.scale = Vector2()
	self.scale.x = scale_factor
	self.scale.y = scale_factor	
	
func _process(delta):
	var oldvec = get_scroll_offset()
	var newvec = Vector2(oldvec.x + scroll_speed * delta, 0)
	self.set_scroll_offset(newvec)
	print(newvec)
	
