extends Node2D

@onready var initial_viewport_size : Vector2 = get_viewport().size

func _ready():
	get_viewport().connect("size_changed", Callable(self, "resize_viewport"))
	var difference_x = get_viewport().size.x/2
	var difference_y = get_viewport().size.y/2
	self.position = Vector2(difference_x, difference_y)	
	
func resize_viewport():
	var difference_x = get_viewport().size.x/2
	var difference_y = get_viewport().size.y/2
	self.position = Vector2(difference_x, difference_y)
