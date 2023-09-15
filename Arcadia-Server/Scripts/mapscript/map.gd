class_name MapBase extends SubViewport

# DO NOT USE THIS SCRIPT DIRECTLY. MAKE A COPY AND PUT IT IN THE DIRECTORY FOR YOUR MAP, THEN ATTACH THAT COPY.

var map_name : String = "none"
var default_spawn_map : bool = false
var default_spawn_location : Vector2 = Vector2(0,0)

var ground_items : Array

@onready var ground_item_scene_resource = load("res://Scripts/ArcadiaInventory/Item/Ground/GroundItem2D.tscn")

func AddPlayerChild(node):
		$PrimarySort/ObjectSortContainer/Players.call_deferred("add_child", node)
	
func RemovePlayerChild(node):
		$PrimarySort/ObjectSortContainer/Players.call_deferred("remove_child", node)
		
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
	
func GenerateMapProjectiles():
	var return_dict : Dictionary = {}
	for i in get_node("PrimarySort/ObjectSortContainer/Projectiles").get_children():
		return_dict[i.uuid] = i.GetMapProjectileData()
	return return_dict
	
func NotifyPlayerAreaEntered(player, text, subtext, requesting_body):
	if player.name in DataRepository.mapmanager.RecentWarps:
		await get_tree().create_timer(0.1).timeout
		if requesting_body.overlaps_body(player):
			for i in get_tree().get_nodes_in_group("PlayerCollider"):
				if player.name == i.name:
					DataRepository.Server.NotifyPlayerAreaEntered(player.ControllingCharacter.ActiveController.associated_pid, text, subtext)
