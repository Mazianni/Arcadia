extends Node

var last_world_state = 0
var world_state_buffer = []
var current_map : String
var current_map_reference
var interpolation_offset = 40
var interpolation_offset_base = 40

func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
		
func _physics_process(delta):
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		return
	if current_map == null:
		return
	interpolation_offset = interpolation_offset_base + Server.latency
	var render_time = Time.get_unix_time_from_system() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2:
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if player == Globals.character_uuid:
					if world_state_buffer[2][player]["M"] != current_map:
						ChangeMap(world_state_buffer[2][player]["M"])
				if not world_state_buffer[1].has(player):
					continue
				if world_state_buffer[1][player]["M"] != current_map:
					continue
				if get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players/").has_node(str(player)):
					var newpos = lerp(world_state_buffer[1][player]["P"],world_state_buffer[2][player]["P"], interpolation_factor)
					get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players/"+str(player)).MovePlayer(newpos)
				else:
					if player == Globals.character_uuid:
						get_node(str(current_map)).SpawnNewPlayer(player, world_state_buffer[2][player]["P"], true)
					else:
						get_node(str(current_map)).SpawnNewPlayer(player, world_state_buffer[2][player]["P"], false)
		elif render_time > world_state_buffer[1].T:
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if player == Globals.character_uuid:
					if world_state_buffer[1][player]["M"] != current_map:
						ChangeMap(world_state_buffer[1][player]["M"])
				if not world_state_buffer[0].has(player):
					continue
				if world_state_buffer[0][player]["M"] != current_map:
					continue
				if get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players").has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					get_node(str(current_map)+"/PrimarySort/ObjectSortContainer/Players/"+str(player)).MovePlayer(new_position)

func ChangeMap(mapname):
	var path = "res://scenes/maps/"
	print(path+str(mapname)+"/"+str(mapname)+".tscn")
	var newmapres = load(path+str(mapname)+"/"+str(mapname)+".tscn")
	var newmapinstance = newmapres.instantiate()
	newmapinstance.name = mapname
	self.add_child(newmapinstance)
	if current_map_reference:
		current_map_reference.queue_free()
	current_map_reference = newmapinstance
	current_map = mapname

func ClearScenes():
	if current_map_reference:
		current_map_reference.queue_free()
		current_map_reference = null
	current_map = ""
