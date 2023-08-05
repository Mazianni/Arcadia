class_name StateProcessor extends SubsystemBase

var world_state : Dictionary = {}

func SubsystemInit(node_name:String):
	subsystem_start_success.emit(name, self)
	
func SubsystemShutdown(node_name:String):
	subsystem_shutdown.emit(name, self)

func _physics_process(delta):
	if not get_parent().player_state_collection.is_empty():
		world_state = get_parent().player_state_collection.duplicate(true)
		for player in world_state.keys():
			world_state[player].erase("T")
		world_state["T"] = Time.get_unix_time_from_system()
		
func GenerateWorldStateForUser(pid:int):
	if DataRepository.PlayerMgmt.has_node(str(pid)):
		var playernode : ActiveCharacter = DataRepository.PlayerMgmt.get_node(str(pid)).CurrentActiveCharacter
		var generated_dict : Dictionary = {"PN" = {}}
		for i in world_state:
			if i == "T":
				continue
			if world_state[i]["M"] == playernode.CurrentMap:
				generated_dict["PN"] = {}
				generated_dict["PN"][i] = world_state[i].duplicate(true)
		generated_dict["T"] = Time.get_unix_time_from_system()
		generated_dict["PN"][playernode.CharacterData["uuid"]] = playernode.CurrentCollider.GetPlayerState()
		return generated_dict
