class_name ItemGrabberDummy extends Sprite2D

func _process(delta):
	position = get_global_mouse_position()
	var grab_node : ItemGrabber = get_tree().get_nodes_in_group("grabbed_item")[0]
	self.texture = grab_node.texture
