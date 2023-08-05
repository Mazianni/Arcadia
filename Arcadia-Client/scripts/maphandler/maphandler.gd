extends Node

var last_world_state = 0
var world_state_buffer = []
var current_map : String
var current_map_reference
var interpolation_offset = 0
var interpolation_offset_base = 0

signal map_loaded
signal map_load_failed

@onready var mainviewportcontainer : SubViewportContainer = $SubViewportContainer
@onready var mainviewport : SubViewport = $SubViewportContainer/SubViewport
@onready var main_node : Node = mainviewport

func _ready():
	Server.world_update_recieved.connect(Callable(self,"ProcessWorldUpdate"))
	map_loaded.connect(Callable(self, "MapLoadedFirstTime"))
	Globals.show_viewport.connect(Callable(self, "ToggleViewport"))
	
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
		
func _physics_process(delta):
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		return
	Server.RequestWorldState()

func ProcessWorldUpdate():
	if current_map_reference.name != current_map: #map name not set yet - invalid condition.
		current_map_reference.name = current_map
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		return
	if current_map == null:
		return
	interpolation_offset = interpolation_offset_base + Server.latency
	var render_time = Time.get_unix_time_from_system() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2]["T"]:
			world_state_buffer.remove_at(0)
		if world_state_buffer.size() > 10:
			world_state_buffer.remove_at(0)
		if world_state_buffer.size() > 2:
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2]["PN"].keys():
				if str(player) == "T":
					continue
				if not world_state_buffer[1]["PN"].has(player):
					continue
				if world_state_buffer[1]["PN"][player]["M"] != current_map:
					continue
				if main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players/").has_node(str(player)):
					var newpos = lerp(world_state_buffer[1]["PN"][player]["P"],world_state_buffer[2]["PN"][player]["P"], interpolation_factor)
					main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players/"+str(player)).MovePlayer(newpos)
				else:
					if player == Globals.character_uuid:
						main_node.get_node(str(current_map)).SpawnNewPlayer(player, world_state_buffer[2]["PN"][player]["P"], true)
					else:
						main_node.get_node(str(current_map)).SpawnNewPlayer(player, world_state_buffer[2]["PN"][player]["P"], false)
		elif render_time > world_state_buffer[1].T:
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
			for player in world_state_buffer[1]["PN"].keys():
				if str(player) == "T":
					continue
				if not world_state_buffer[0]["PN"].has(player):
					continue
				if world_state_buffer[0]["PN"][player]["M"] != current_map:
					continue
				if main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players").has_node(str(player)):
					var position_delta = (world_state_buffer[1]["PN"][player]["P"] - world_state_buffer[0]["PN"][player]["P"])
					var new_position = world_state_buffer[1]["PN"][player]["P"] + (position_delta * extrapolation_factor)
					main_node.get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players/"+str(player)).MovePlayer(new_position)

func ChangeMap(mapname):
	var path = "res://scenes/maps/"
	print(path+str(mapname)+"/"+str(mapname)+".tscn")
	var newmapres = load(path+str(mapname)+"/"+str(mapname)+".tscn")
	if not newmapres:
		Gui.CreateFloatingMessage("There was an error loading the map for your character. Please report this to a developer.", "bad")
		Globals.SetClientState(Globals.CLIENT_STATE_LIST.CLIENT_PREGAME)
		emit_signal("map_load_failed")
		return
	var newmapinstance = newmapres.instantiate()
	newmapinstance.name = mapname
	mainviewport.add_child(newmapinstance)
	if current_map_reference:
		current_map_reference.queue_free()
	current_map_reference = newmapinstance
	current_map = mapname
	map_loaded.emit()
	
func MapLoadedFirstTime():
	Globals.SetClientState(Globals.CLIENT_STATE_LIST.CLIENT_INGAME)

func ClearScenes():
	if current_map_reference:
		current_map_reference.queue_free()
		current_map_reference = null
	current_map = ""
