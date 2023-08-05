class_name PlayerContainer extends PlayerDataContainerBase

var ActiveCharacterPath = preload("res://Scenes/Instances/ActiveCharacter.tscn")

var PlayerStats 
var HasLoaded = false
var PlayerData : Dictionary =  {"username":"", "displayname":"", "rank":"", "ooc_color":"", "character_dict":{},"lastlogin":0, "persistent_uuid":""}
var associated_uuid
var associated_pid # godot node names are a special type in 4.0, not strings.
var CurrentActiveCharacter : ActiveCharacter
var ClientState

signal loaded
signal load_failed(pid)

func _ready():
	connect("tree_exiting", Callable(self, "OnDeleted"))
	await get_tree().create_timer(0.1).timeout # wait for a little while for username to populate.
	CheckSaveDataExists()
	MigrateSaveData()
	
func MigrateSaveData(): #IMPL whatever the fuck this was
	return true
#	for I in DataRepository.DefaultPlayerData.keys():
#		if !I in PlayerData.keys():
#			PlayerData[I] = DataRepository.DefaultPlayerDataPlayerData[I]
	#		Logging.log_warning("[SAVES] Key "+I+" not found in "+PlayerData["username"]+"'s save. Adding.")
	
func HandleStateUpdate(client_state):
	if not client_state:
		Logging.log_error("[PLAYER CONTAINER] HandleStateUpdate called with a null arg on "+name+" "+PlayerData["username"])
		return
		
	match client_state:
		DataRepository.CLIENT_STATE_LIST.CLIENT_PREGAME:
			ClientState = DataRepository.CLIENT_STATE_LIST.CLIENT_PREGAME
			if CurrentActiveCharacter:
				Logging.log_notice("[PLAYER CONTAINER] ClientState for "+name+" "+PlayerData["username"]+" going from INGAME to PREGAME.")
				if CurrentActiveCharacter.CurrentCollider:
					CurrentActiveCharacter.CurrentCollider.queue_free()
				CurrentActiveCharacter.queue_free()
				
		DataRepository.CLIENT_STATE_LIST.CLIENT_INGAME:
			Logging.log_notice("[PLAYER CONTAINER] ClientState for "+name+" "+PlayerData["username"]+" going from PREGAME to INGAME.")
			ClientState = DataRepository.CLIENT_STATE_LIST.CLIENT_INGAME
			
func OnDeleted():
	if DataRepository.CurrentState == DataRepository.SERVER_STATE.SERVER_SHUTTING_DOWN:
		return
	WriteSaveData()

func CheckSaveDataExists(): #Verify that the directory and JSON file for this player exists; if not, create it with defaults.
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData["username"])
	var dir = DirAccess.open(save_dir)
	if DirAccess.get_open_error():
		Logging.log_error("[FILE] Error opening directory "+save_dir)
		return
	Logging.log_notice("Checking save data for " + str(PlayerData["username"]))
	if not dir.dir_exists(save_dir):
		dir.make_dir(save_dir)
		Logging.log_notice("Creating save directory for " + str(PlayerData["username"]) + " at dir " + save_dir)
	if not dir.file_exists(save_dir+"/"+str(PlayerData["username"])+".json"):
		var newsave = FileAccess.open(save_dir+"/"+str(PlayerData["username"])+".json", FileAccess.WRITE)
		newsave.store_line(JSON.stringify(PlayerData))
		Logging.log_notice("Creating save JSON for " + str(PlayerData["username"]))
		var err = newsave.get_error()
		newsave.close()
	LoadSaveData()
		
func LoadSaveData():
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData["username"])
	var save_file = save_dir+"/"+str(PlayerData["username"])+".json"
	var return_dict : Dictionary = SaveHandler.ReadFile(save_file)
	if not return_dict: #IMPLEMENT handling for a failure to load player data.
		Logging.log_error("[FILE] SaveHandler returned null data for "+str(PlayerData["username"]))
		return
	PlayerData = return_dict.duplicate(true)
	HasLoaded = true
	emit_signal("loaded", self.name)
	
func WriteSaveData():
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData["username"])
	var save_file = save_dir+"/"+str(PlayerData["username"])+".json"
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	var err = file.get_error()
	file.store_line(JSON.stringify(PlayerData))
	if !err:
		Logging.log_notice("Data for " + str(PlayerData["username"]) + " saved.")
	else:
		Logging.log_error("[FILE] Error encountered during save for "+str(PlayerData["username"])+" with code "+str(err))
	file.close()
	save_callback.emit(name, "PlayerContainer", PlayerData["username"])
	
func DeleteSaveData(charname):
	Logging.log_notice("Deleting character "+charname+" for "+PlayerData["username"])
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData["username"])
	var save_file = save_dir+"/"+str(charname)+".json"
	var dir : DirAccess = DirAccess.open(save_dir)
	dir.remove(save_file)
	var err = DirAccess.get_open_error()
	if !err:
		Logging.log_notice("Data for " + str(PlayerData["username"])+" character "+charname + " deleted.")
	else:
		Logging.log_error("[FILE] Error encountered during save deletion for "+str(PlayerData["username"])+" with code "+str(err))	
	
func DeleteCharacter(char_name):
	PlayerData["character_dict"].erase(char_name)
	DeleteSaveData(char_name)
	WriteSaveData()
	
func CreateActiveCharacter(character_name, player_id):
	Logging.log_notice("Attempting to load existing character for "+str(player_id)+": "+character_name)
	CurrentActiveCharacter = ActiveCharacterPath.instantiate()
	CurrentActiveCharacter.name = character_name
	CurrentActiveCharacter.ActiveController = self
	self.add_child(CurrentActiveCharacter)
	CurrentActiveCharacter.CharacterData["LastPlayed"] = Time.get_unix_time_from_system()
	
func CreateNewActiveCharacter(cuuid, species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height):
	Logging.log_notice("Creating new character for "+PlayerData["username"]+": "+character_name+" UUID "+str(cuuid))
	CurrentActiveCharacter = ActiveCharacterPath.instantiate()
	CurrentActiveCharacter.name = cuuid
	CurrentActiveCharacter.ActiveController = self
	CurrentActiveCharacter.CreateNewCharacter(cuuid, species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height)
	CurrentActiveCharacter.CurrentMap = DataRepository.spawns[DataRepository.races[species_name].valid_spawns[0]]["MapName"]
	CurrentActiveCharacter.CurrentPosition = DataRepository.spawns[DataRepository.races[species_name].valid_spawns[0]]["pos"]
	PlayerData["character_dict"][cuuid] = character_name
	self.add_child(CurrentActiveCharacter)
	WriteSaveData()
	CurrentActiveCharacter.WriteJSON(cuuid)
	
	
	
