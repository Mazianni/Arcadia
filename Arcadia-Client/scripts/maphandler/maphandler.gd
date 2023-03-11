extends Node

var last_world_state = 0
var world_state_buffer = []
var current_map : String
const interpolation_offset = 100

func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
		
func _physics_process(delta):
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		return
	var render_time = OS.get_system_time_msecs() - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2:
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if world_state_buffer[1][player]["M"] != current_map:
					continue
				if get_node("ViewportContainer/Viewport/GameRender2D/OtherPlayers").has_node(str(player)):
					var newpos = lerp(world_state_buffer[1][player]["P"],world_state_buffer[2][player]["P"], interpolation_factor)
					get_node("ViewportContainer/Viewport/GameRender2D/OtherPlayers/"+str(player)).MovePlayer(newpos)
				else:
					get_node("ViewportContainer/Viewport/GameRender2D").SpawnNewPlayer(player, world_state_buffer[2][player]["P"])
		elif render_time > world_state_buffer[1].T:
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if world_state_buffer[0][player]["M"] != current_map:
					continue
				if get_node("ViewportContainer/Viewport/GameRender2D/OtherPlayers").has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					get_node("ViewportContainer/Viewport/GameRender2D/OtherPlayers/"+str(player)).MovePlayer(new_position)

