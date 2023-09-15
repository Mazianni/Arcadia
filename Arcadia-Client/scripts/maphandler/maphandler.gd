extends Node

var last_world_state = 0
var world_state_buffer = []
var current_map : String
var current_map_reference
var interpolation_offset = 0
var interpolation_offset_base = 16.99
var MainPlayerObject : PlayerObject
var MapObjectResourceDictionary : Dictionary = {
	"Chest":preload("res://scenes/MapObjects/Chest.tscn")
}
var MapProjectileResourceDictionary : Dictionary = {
	"Thunder Strike":preload("res://scenes/Projectiles/Thunder Strike/projectile.tscn")
}
var MapDict : Dictionary = {
	"Test" : preload("res://scenes/maps/Test/Test.tscn"),
	"Test2" : preload("res://scenes/maps/Test2/Test2.tscn")
}

signal map_loaded
signal map_load_failed
signal map_changed_to(node)

@onready var mainviewportcontainer : SubViewportContainer = $SubViewportContainer
@onready var mainviewport : SubViewport = $SubViewportContainer/SubViewport
@onready var main_node : Node = self

func _ready():
	#Server.world_update_recieved.connect(Callable(self,"ProcessWorldUpdate"))
	map_loaded.connect(Callable(self, "MapLoadedFirstTime"))
	Globals.show_viewport.connect(Callable(self, "ToggleViewport"))
	Globals.create_main_player_obj.connect(Callable(self, "CreatePlayerNode"))
	
func CreatePlayerNode():
	MainPlayerObject = Globals.player_spawn.instantiate()
	MainPlayerObject.name = Globals.character_uuid
	MainPlayerObject.SpawnCamera()
	
func ToggleViewport(show:bool):
	if show:
		mainviewportcontainer.show()
	else:
		mainviewportcontainer.hide()

func UpdateWorldState(world_state):
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		return
	if world_state == null:
		return
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
		
#func _physics_process(delta):
#	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
#		return
#	Server.RequestWorldState()

#func ProcessWorldUpdate():
#	return
#	var map_node : MapBase
#	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
#		return
#	if current_map_reference.name != current_map: #map name not set yet - invalid condition.
#		current_map_reference.name = current_map
#	if current_map == null:
#		return
#	interpolation_offset = interpolation_offset_base + Server.latency
#	var render_time = (Time.get_unix_time_from_system() * 1000) - interpolation_offset
#	if world_state_buffer.size() > 1:
#		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2]["T"]:
#			world_state_buffer.remove_at(0)
#		if world_state_buffer.size() > 4:
#			world_state_buffer.remove_at(0)
#		if world_state_buffer.size() > 2:
#			map_node = main_node.get_node(str(current_map))
#			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
#			for player in world_state_buffer[2]["PN"].keys():
#				if str(player) == "T":
#					continue
#				if not world_state_buffer[1]["PN"].has(player):
#					continue
#				if world_state_buffer[1]["PN"][player]["M"] != current_map:
#					continue
#				if main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players/").has_node(str(player)):
#					#var newpos = lerp(main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players/"+str(player)).get_global_position(),world_state_buffer[2]["PN"][player]["P"], interpolation_factor)
#					var newpos = lerp(world_state_buffer[1]["PN"][player]["P"],world_state_buffer[2]["PN"][player]["P"], interpolation_factor)
#					main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players/"+str(player)).MovePlayer(newpos)
#					main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players/"+str(player)).UpdateSprite(world_state_buffer[1]["PN"][player]["MV"])
#				else:
#					if player == Globals.character_uuid:
#						main_node.get_node(str(current_map)).AddPlayerNodeToMap(MainPlayerObject, world_state_buffer[2]["PN"][player]["P"])
#					else:
#						main_node.get_node(str(current_map)).SpawnNewPlayer(player, world_state_buffer[2]["PN"][player]["P"], false)
#			for ground_item in world_state_buffer[2]["GN"].keys():
#				if main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Objects/").has_node(str(ground_item)):
#					var newpos = lerp(world_state_buffer[1]["GN"][ground_item]["P"],world_state_buffer[2]["GN"][ground_item]["P"], interpolation_factor)
#					main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Objects/"+str(ground_item)).position = newpos
#				else:
#					main_node.get_node(str(current_map)).AddGroundItem(world_state_buffer[2]["GN"][ground_item]["D"], ground_item, world_state_buffer[2]["GN"][ground_item]["P"])
#			for old_ground_item in main_node.get_node(str(current_map)).ground_items:
#				if is_instance_valid(old_ground_item):
#					if old_ground_item.uuid not in world_state_buffer[1]["GN"].keys():
#						old_ground_item.free()
#			for i in current_map_reference.GetMapPlayers():
#				if not i.name in world_state_buffer[2]["PN"].keys():
#					current_map_reference.DespawnPlayer(i.name)
#		elif render_time > world_state_buffer[1].T:
#			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
#			for player in world_state_buffer[1]["PN"].keys():
#				if str(player) == "T":
#					continue
#				if not world_state_buffer[0]["PN"].has(player):
#					continue
#				if world_state_buffer[0]["PN"][player]["M"] != current_map:
#					continue
#				map_node = main_node.get_node(str(current_map))
#				if main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players").has_node(str(player)):
#					var position_delta = (world_state_buffer[1]["PN"][player]["P"] - world_state_buffer[0]["PN"][player]["P"])
#					var new_position = world_state_buffer[1]["PN"][player]["P"] + (position_delta * extrapolation_factor)
#					main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players/"+str(player)).MovePlayer(new_position)
#					main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players/"+str(player)).UpdateSprite(world_state_buffer[1]["PN"][player]["D"], world_state_buffer[1]["PN"][player]["MV"])
#		HandleMapObjects(world_state_buffer[1])
#		HandleMapProjectiles(world_state_buffer[1])
		
func ChangeMap(mapname):
	var path = "res://scenes/maps/"
	var newmapres
	if MapDict.has(mapname):
		newmapres = MapDict[mapname]
	else:
		newmapres = load(path+str(mapname)+"/"+str(mapname)+".tscn")
	if not newmapres:
		Gui.CreateFloatingMessage("There was an error loading the map for your character. Please report this to a developer.", "bad")
		Globals.SetClientState(Globals.CLIENT_STATE_LIST.CLIENT_PREGAME)
		emit_signal("map_load_failed")
		return
	var newmapinstance = newmapres.instantiate()
	newmapinstance.name = mapname
	if current_map_reference:
		current_map_reference.get_node("PrimarySort/ObjectSortContainer/Players").remove_child(MainPlayerObject)
		newmapinstance.AddPlayerNodeToMap(MainPlayerObject)
	mainviewport.add_child(newmapinstance)
	if current_map_reference:
		current_map_reference.queue_free()
	current_map_reference = newmapinstance
	current_map = mapname
	map_loaded.emit()
	map_changed_to.emit(current_map_reference)
	
func TriggerTransition():
	var tween = create_tween()
	tween.tween_property($SubViewportContainer/TransitionModulate, "color", Color.BLACK, 0.1)
	get_tree().create_timer(0.3).timeout.connect(Callable(self, "FinishTransition"))

func FinishTransition():
	var tween = create_tween()
	tween.tween_property($SubViewportContainer/TransitionModulate, "color", Color.WHITE, 0.1)
	
func MapLoadedFirstTime():
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		Globals.SetClientState(Globals.CLIENT_STATE_LIST.CLIENT_INGAME)
	
func HandleMapObjects(world_state : Dictionary):
	for i in world_state["MO"].keys():
		if current_map_reference.HasMapObject(i):
			continue
		var subdict : Dictionary = world_state["MO"][i].duplicate(true)
		if subdict.has("type"):
			if MapObjectResourceDictionary.has(subdict["type"]):
				var new_scene = MapObjectResourceDictionary[subdict["type"]].instantiate()
				new_scene.name = i
				new_scene.ApplyProperties(subdict["subdata"].duplicate(true))
				current_map_reference.AddMapObject(new_scene)
	for i in current_map_reference.GetMapObjects():
		if not world_state["MO"].has(i.name):
			i.queue_free()
			
func HandleMapProjectiles(world_state : Dictionary):
	for i in world_state["PR"].keys():
		if current_map_reference.HasMapProjectile(i):
			continue
		var subdict : Dictionary = world_state["PR"][i].duplicate(true)
		if subdict.has("type"):
			if MapProjectileResourceDictionary.has(subdict["type"]):
				var new_scene = MapProjectileResourceDictionary[subdict["type"]].instantiate()
				new_scene.name = i
				new_scene.position = subdict["pos"]
				current_map_reference.AddMapProjectile(new_scene)
	for i in current_map_reference.GetMapProjectiles():
		if not world_state["PR"].has(i.name):
			i.end_projectile()
		if is_instance_valid(i) && world_state["PR"].has(i.name):
			i.position = world_state["PR"][i.name]["pos"]
			i.rotation = world_state["PR"][i.name]["rot"]
	

func ClearScenes():
	world_state_buffer.clear()
	if current_map_reference:
		current_map_reference.queue_free()
		current_map_reference = null
	current_map = ""
	if MainPlayerObject:
		if is_instance_valid(MainPlayerObject):
			MainPlayerObject.queue_free()
