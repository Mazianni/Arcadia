extends Node

var Server : Node

func _ready():
	Server = get_tree().get_root().get_node("Server")

static func string_to_vector2(string := "") -> Vector2:
	if string:
		var new_string: String = string
		new_string.erase(0, 1)
		new_string.erase(new_string.length() - 1, 1)
		var array: Array = new_string.split(", ")

		return Vector2(array[0], array[1])

	return Vector2.ZERO
	
func Username2PID(username:String):
	for i in DataRepository.pid_to_username.keys():
		if DataRepository.pid_to_username[i]["username"] == username:
			return int(i)
			
func PID2Username(pid:int):
	if Server.has_node(str(pid)):
		return Server.get_node(str(pid)).PlayerData["username"]
		
func GetActiveStaff():
	var staff_array : Array
	for I in get_tree().get_nodes_in_group("players"):
		if Admin.HasRank(I):
			if Admin.CheckPermissions("Is Staff", I):
				staff_array.append(I)
	return staff_array
	
func NotifyStaff(message:String):
	for I in get_tree().get_nodes_in_group("players"):
		if Admin.HasRank(I):
			if Admin.CheckPermissions("Manage Tickets", I):
				Server.SendSingleChat(ChatHandler.FormatSimpleMessage(message), int(I.name))

func NotifyStaffUrgent(message:String):
	for I in get_tree().get_nodes_in_group("players"):
		if Admin.HasRank(I):
			if Admin.CheckPermissions("Manage Tickets", I):
				Server.SendSingleChat(ChatHandler.FormatSimpleMessage(message), int(I.name))
				#Server.GrabAttention() 
				#TODO make this play a sound to catch people's attention.

func NotifyUsersInArray(users_to_message:Array, message:String):
	for I in users_to_message:
		if Server.has_node(str(Username2PID(I))):
			var user =  Server.get_node(str(Username2PID(I)))
			Server.SendSingleChat(ChatHandler.FormatSimpleMessage(message), int(user.name))
				
func GetMessageOriginator(username:bool = false, playerid:int = 0):
	if !playerid:
		Logging.log_error("[HELPER] No PID supplied to GetMessageOriginator()!")
		return
	if Server.has_node(str(playerid)):
		if(username):
			return 	Server.get_node(str(playerid)).PlayerData["username"]
		else:
			return Server.get_node(str(playerid)).ActiveCharacter.CharacterData["Name"]
	
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
	
func Match2(input:String, to_find:String, start_location:int):
	if input.length() <= start_location+1:
		return false
	if (input[start_location+1] == to_find) && (input[start_location] == to_find):
		Logging.log_error("triggered" + to_find + str(start_location) + input + input[start_location])
		return true
	return false
	
func Match3(input:String, to_find:String, start_location:int):
	if (input.length() <= start_location+1) || (input.length() <= start_location+2):
		return false
	if input[start_location] == to_find:
		if input[start_location+1] == to_find:
			return true
	return false
	
func GetCurrentPlayerList():
	var return_array : Array
	for I in get_tree().get_nodes_in_group("players"):
		return_array.append(I.PlayerData["username"])
	return return_array
			
	
			
