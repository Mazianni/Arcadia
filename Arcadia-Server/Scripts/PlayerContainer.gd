extends Node

var ActiveCharacterPath = preload("res://Scenes/Instances/ActiveCharacter.tscn")

var PlayerStats 
var HasLoaded = false
var PlayerData : Dictionary =  {"username":"", "displayname":"", "rank":"", "ooc_color":"", "character_dict":{},"lastlogin":0, "persistent_uuid":""}
var associated_uuid
var ActiveCharacter : ActiveCharacter

signal loaded

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
	
func OnDeleted():
	WriteSaveData()

func CheckSaveDataExists(): #Verify that the directory and JSON file for this player exists; if not, create it with defaults.
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData["username"])
	print(DataRepository.saves_directory)
	print(save_dir)
	var dir = DirAccess.open(save_dir)
	Logging.log_notice("Checking save data for " + str(PlayerData["username"]))
	if not dir.dir_exists(save_dir):
		dir.make_dir(save_dir)
		Logging.log_notice("Creating save directory for " + str(PlayerData["username"]) + " at dir " + save_dir)
	if not dir.file_exists(save_dir+"/"+str(PlayerData["username"])+".json"):
		var newsave = FileAccess.open(save_dir+"/"+str(PlayerData["username"])+".json", FileAccess.WRITE)
		newsave.store_line(JSON.new().stringify(PlayerData))
		Logging.log_notice("Creating save JSON for " + str(PlayerData["username"]))
		var err = newsave.get_error()
		newsave.close()
	LoadSaveData()
		
func LoadSaveData():
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData["username"])
	var save_file = save_dir+"/"+str(PlayerData["username"])+".json"
	var load_dict : Dictionary = {}
	var loadfile = FileAccess.open(save_file, FileAccess.READ)
	var temp
	temp = loadfile.get_as_text()
	var test_json_conv = JSON.new()
	test_json_conv.parse(temp)
	load_dict = test_json_conv.get_data()
	PlayerData = load_dict.duplicate(true)
	loadfile.close()
	HasLoaded = true
	emit_signal("loaded", self.name)
	
func WriteSaveData():
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData["username"])
	var save_file = save_dir+"/"+str(PlayerData["username"])+".json"
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	var err = file.get_error()
	file.store_line(JSON.new().stringify(PlayerData))
	if !err:
		Logging.log_notice("Data for " + str(PlayerData["username"]) + " saved.")
	else:
		Logging.log_error("[FILE] Error encountered during save for "+str(PlayerData["username"])+" with code "+str(err))
	file.close()
	
func DeleteSaveData(charname):
	Logging.log_notice("Deleting character "+charname+" for "+PlayerData["username"])
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData["username"])
	var save_file = save_dir+"/"+str(charname)+".json"
	var dir : DirAccess = DirAccess.open(save_dir)
	dir.remove(save_file)
	var err = dir.get_open_error()
	if !err:
		Logging.log_notice("Data for " + str(PlayerData["username"]) + " Deleted.")
	else:
		Logging.log_error("[FILE] Error encountered during save deletion for "+str(PlayerData["username"])+" with code "+str(err))	
	
func DeleteCharacter(char_name):
	PlayerData["character_dict"].erase(char_name)
	DeleteSaveData(char_name)
	WriteSaveData()
	
func CreateActiveCharacter(character_name, player_id):
	ActiveCharacter = ActiveCharacterPath.instantiate()
	ActiveCharacter.name = character_name
	ActiveCharacter.ActiveController = self
	self.add_child(ActiveCharacter)
	Logging.log_notice("Loading existing character for "+str(player_id)+": "+character_name)
	ActiveCharacter.CharacterData["LastPlayed"] = Time.get_unix_time_from_system()
	
func CreateNewActiveCharacter(cuuid, species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height):
	Logging.log_notice("Creating new character for "+PlayerData["username"]+": "+character_name+" UUID "+str(cuuid))
	ActiveCharacter = ActiveCharacterPath.instantiate()
	ActiveCharacter.name = cuuid
	ActiveCharacter.ActiveController = self
	ActiveCharacter.CreateNewCharacter(cuuid, species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height)
	ActiveCharacter.CurrentMap = DataRepository.spawns[DataRepository.races[species_name].valid_spawns[0]]["MapName"]
	ActiveCharacter.CurrentPosition = DataRepository.spawns[DataRepository.races[species_name].valid_spawns[0]]["pos"]
	PlayerData["character_dict"][cuuid] = character_name
	self.add_child(ActiveCharacter)
	WriteSaveData()
	ActiveCharacter.WriteJSON(cuuid)
	
	
	
