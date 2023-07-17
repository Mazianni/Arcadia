extends Node

var scenes_dictionary = {
	
}

var current_scene

func ChangeScene(newscenename, parent_node):
	var newscenepath = scenes_dictionary[newscenename]
	assert(newscenepath != null) #,"Invalid Scene Name: " + newscenename)
	find_child(current_scene).queue_free()
	var newscene = newscenepath.instantiate()
	find_child(parent_node).add_child(newscene)
	current_scene = newscene
	
