extends Node

var Server : Node

func _ready():
	Server = get_tree().get_root().get_node("Server")

func string_to_vector2(string := "") -> Vector2:
	if string:
		var new_string: String = string
		new_string.erase(0, 1)
		new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")
		var string1 : String = array[0]
		var string2 : String = array[1]
		string1 = string1.replace("(", "")
		string2 = string2.replace(")", "")
		var vec : Vector2 = Vector2(float(string1),float(string2))
		return vec

	return Vector2.ZERO
	
func Username2PID(username:String):
	for i in DataRepository.pid_to_username.keys():
		if DataRepository.pid_to_username[i]["username"] == username:
			return int(i)
			
func PID2Username(pid:int):
	if DataRepository.PlayerMgmt.has_node(str(pid)):
		return DataRepository.PlayerMgmt.get_node(str(pid)).PlayerData.Username
		
func GetActiveStaff():
	var staff_array : Array = []
	for I in get_tree().get_nodes_in_group("players"):
		if DataRepository.Admin.HasRank(I):
			if DataRepository.Admin.CheckPermissions(DataRepository.Admin.RANK_FLAGS.IS_STAFF, I):
				staff_array.append(I)
	return staff_array
	
func NotifyStaff(message:String):
	for I in get_tree().get_nodes_in_group("players"):
		if DataRepository.Admin.HasRank(I):
			if DataRepository.Admin.CheckPermissions(DataRepository.Admin.RANK_FLAGS.MANAGE_TICKETS, I):
				Server.SendSingleChat(ChatHandler.FormatSimpleMessage(message), int(I.name))

func NotifyStaffUrgent(message:String):
	for I in get_tree().get_nodes_in_group("players"):
		if DataRepository.Admin.HasRank(I):
			if DataRepository.Admin.CheckPermissions(DataRepository.Admin.RANK_FLAGS.MANAGE_TICKETS, I):
				Server.SendSingleChat(ChatHandler.FormatSimpleMessage(message), int(I.name))
				#Server.GrabAttention() 
				#TODO make this play a sound to catch people's attention.

func NotifyUsersInArray(users_to_message:Array, message:String):
	for I in users_to_message:
		if DataRepository.PlayerMgmt.has_node(str(Username2PID(I))):
			var user =  DataRepository.PlayerMgmt.get_node(str(Username2PID(I)))
			Server.SendSingleChat(ChatHandler.FormatSimpleMessage(message), int(user.name))
				
func GetMessageOriginator(username:bool = false, playerid:int = 0):
	if !playerid:
		Logging.log_error("[HELPER] No PID supplied to GetMessageOriginator()!")
		return
	if DataRepository.PlayerMgmt.has_node(str(playerid)):
		if(username):
			return 	DataRepository.PlayerMgmt.get_node(str(playerid)).PlayerData.Username
		else:
			return DataRepository.PlayerMgmt.get_node(str(playerid)).CurrentActiveCharacter.CharacterData.Name
	
func HandleCommands(input:Dictionary, player_id:int):
	var command : String
	var has_command : bool = false
	var output_dict : Dictionary = {"T":Time.get_time_string_from_system(true), "category":"ETC"}
	for i in DataRepository.functional_commands_dict.keys():
		if i in input["text"]:
			command = i
			has_command = true
			break
	return has_command
	
func GetCurrentPlayerList():
	var return_array : Array = []
	for I in get_tree().get_nodes_in_group("players"):
		return_array.append(I.CharacterData.Name)
	return return_array
	
func GetCurrentCharactersList():
	var return_array : Array = []
	for I in get_tree().get_nodes_in_group("active_characters"):
		return_array.append(I.PlayerData.Username)
	return return_array	
	
func GetPlayersInRange(origin, given_distance:int):
	var return_array : Array = []
	for i in get_tree().get_nodes_in_group("PlayerCollider"):
		if i.CurrentMap != origin.CurrentMap:
			continue
		var distance : float = origin.CurrentCollider.get_global_position().distance_to(i.get_global_position())
		if distance > given_distance:
			continue
		return_array.append(i)
	return return_array
			
	
			
