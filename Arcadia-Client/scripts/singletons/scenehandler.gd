extends Node

var scenes_dictionary = {
	
}

var current_scene

func ChangeScene(newscenename, parent_node):
	var newscenepath = scenes_dictionary[newscenename]
	assert(newscenepath != null,"Invalid Scene Name: " + newscenename)
	find_node(current_scene).queue_free()
	var newscene = newscenepath.instance()
	find_node(parent_node).add_child(newscene)
	current_scene = newscene
	
