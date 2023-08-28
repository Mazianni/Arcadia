class_name MapBase extends Node

# DO NOT USE THIS SCRIPT DIRECTLY. MAKE A COPY AND PUT IT IN THE DIRECTORY FOR YOUR MAP, THEN ATTACH THAT COPY.

var map_name : String = "none"
var warpers : Dictionary = {} # format as "warper name" : {"destination":"mapname", "pos":vector2(0,0)}
var default_spawn_map : bool = false
var default_spawn_location : Vector2 = Vector2(0,0)

var ground_items : Array

@onready var ground_item_scene_resource = load("res://Scripts/ArcadiaInventory/Item/Ground/GroundItem2D.tscn")

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
		get_node("PrimarySort/ObjectSortContainer/Warpers").add_child(node)
	
func RemovePlayerChild(node):
		get_node("PrimarySort/ObjectSortContainer/Warpers").remove_child(node)
		
func AddGroundItem(item : Dictionary, position : Vector2):
	var new_node = ground_item_scene_resource.instantiate()
	new_node.held_item = item
	new_node.CurrentMap = self.name
	new_node.CurrentMapRef = self
	new_node.position = position
	get_node("PrimarySort/ObjectSortContainer/Objects").add_child(new_node)
	ground_items.append(new_node)
	
func GenerateGroundItemDict():
	var return_dict : Dictionary = {}

	for i in ground_items:
		if not is_instance_valid(i):
			continue
		var ground_item : GroundItem = i
		var item_detail_dict : Dictionary = {
			"texture":ground_item.held_item["texture"]
			}
		return_dict[ground_item.uuid] = {"P":ground_item.get_global_position(), "I":ground_item.held_item["uuid"], "D":item_detail_dict}
	return return_dict
	
func GenerateMapObjects():
	var return_dict : Dictionary = {}
	for i in get_node("PrimarySort/ObjectSortContainer/Structures").get_children():
		return_dict[i.uuid] = i.GetMapObjectData()
	return return_dict
