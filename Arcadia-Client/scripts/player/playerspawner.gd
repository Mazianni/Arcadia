
class_name MapBase extends Node2D
@onready var ground_item_scene_resource = load("res://Scripts/ArcadiaInventory/Item/Ground/GroundItem2D.tscn")
	
var ground_items : Array = []

func AddPlayerNodeToMap(player_node : PlayerObject, position : Vector2):
	get_node("PrimarySort/ObjectSortContainer/Players").add_child(player_node)
	
func SpawnNewPlayer(player_id, spawn_position, is_main):
	var new_player : PlayerObject = Globals.player_spawn.instantiate()
	new_player.position = spawn_position
	new_player.name = str(player_id)
	get_node("PrimarySort/ObjectSortContainer/Players").add_child(new_player)
		
func DespawnPlayer(player_id):
	get_node("PrimarySort/ObjectSortContainer/Players/"+player_id).queue_free()
	
func GetGroundItem(uuid : String):
	if get_node("PrimarySort/ObjectSortContainer/Objects").has_node(uuid):
		return get_node("PrimarySort/ObjectSortContainer/Objects").get_node(uuid)
	
func AddGroundItem(item : Dictionary, uuid : String, position:Vector2):
	var new_node = ground_item_scene_resource.instantiate()
	new_node.held_item = item
	new_node.CurrentMap = self.name
	new_node.CurrentMapRef = self
	new_node.uuid = uuid
	new_node.position = position
	new_node.name = uuid
	get_node("PrimarySort/ObjectSortContainer/Objects").add_child(new_node)
	ground_items.append(new_node)
	
func GetMapPlayers():
	return get_node("PrimarySort/ObjectSortContainer/Players").get_children()
	
func AddMapObject(obj:Node):
	get_node("PrimarySort/ObjectSortContainer/Structures").add_child(obj)
	
func HasMapObject(id:String):
	return get_node("PrimarySort/ObjectSortContainer/Structures").has_node(id)
	
func GetMapObjects():
	return get_node("PrimarySort/ObjectSortContainer/Structures").get_children()
	
func AddMapProjectile(obj:Node):
	get_node("PrimarySort/ObjectSortContainer/Projectiles").add_child(obj)
	
func HasMapProjectile(id:String):
	return get_node("PrimarySort/ObjectSortContainer/Projectiles").has_node(id)
	
func GetMapProjectiles():
	return get_node("PrimarySort/ObjectSortContainer/Projectiles").get_children()
