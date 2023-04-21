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
			return i
			
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
	if input.length() < start_location-1:
		Logging.log_warning("length"+str(input.length()) +"start location "+str(start_location))
		return false
	elif input[start_location-1] == to_find:
		return true
	return false
	
func Match3(input:String, to_find:String, start_location:int):
	if (input.length() < start_location-1) || (input.length() <= start_location+2):
		return false
	elif input[start_location-1] == to_find:
		if input[start_location] == to_find:
			return true
	return false
			
	
			
