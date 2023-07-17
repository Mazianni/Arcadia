extends Node

# DO NOT USE THIS SCRIPT DIRECTLY. MAKE A COPY AND PUT IT IN THE DIRECTORY FOR YOUR MAP, THEN ATTACH THAT COPY.

var map_name : String = "Test"
var warpers : Dictionary = {} # format as "warper name" : {"destination":"mapname", "pos":vector2(0,0)}
var default_spawn_map : bool = true
var default_spawn_location : Vector2 = Vector2(300,300)

func GenerateWarpers():
	if warpers.size():
		Logging.log_notice("Generating warpers for map "+str(map_name))
		for i in warpers.keys():
			var new_warper = DataRepository.warper_resource.instantiate()
			Logging.log_notice("Generating new warper at "+str(warpers[i]["pos"]+" linking to "+str(warpers[i]["destination"])))
			new_warper.position = warpers[i]["pos"]
			new_warper.warp_to = warpers[i]["destination"]
			new_warper.parent_map = self.name
			get_node("PrimarySort/ObjectSortContainer/Warpers").add_child(new_warper)
		
func AddPlayerChild(node):
		get_node("PrimarySort/ObjectSortContainer/Players").add_child(node)
	
func RemovePlayerChild(node):
		get_node("PrimarySort/ObjectSortContainer/Players").remove_child(node)
