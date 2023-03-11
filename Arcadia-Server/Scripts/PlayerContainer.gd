extends Node

var ActiveCharacterPath = preload("res://Scenes/Instances/ActiveCharacter.tscn")

var PlayerStats 
var HasLoaded = false
var PlayerData : Dictionary =  {"username":"", "displayname":"", "rank":"", "ooc_color":"", "character_dict":{},"lastlogin":0}
var associated_uuid
var ActiveCharacter : ActiveCharacter

func _ready():
	yield(get_tree().create_timer(0.1), "timeout") # wait for a little while for username to populate.
	CheckSaveDataExists()
	LoadSaveData()

func CheckSaveDataExists(): #Verify that the directory and JSON file for this player exists; if not, create it with defaults.
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData["username"])
	print(DataRepository.saves_directory)
	print(save_dir)
	var dir = Directory.new()
	dir.open(save_dir)
	Logging.log_notice("Checking save data for " + str(PlayerData["username"]))
	if not dir.dir_exists(save_dir):
		dir.make_dir(save_dir)
		Logging.log_notice("Creating save directory for " + str(PlayerData["username"]) + " at dir " + save_dir)
	if not dir.file_exists(save_dir+"/"+str(PlayerData["username"])+".json"):
		var newsave = File.new()
		newsave.open(save_dir+"/"+str(PlayerData["username"])+".json", File.WRITE)
		newsave.store_line(to_json(PlayerData))
		Logging.log_notice("Creating save JSON for " + str(PlayerData["username"]))
		newsave.close()
		
func LoadSaveData():
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData["username"])
	var save_file = save_dir+"/"+str(PlayerData["username"])+".json"
	var load_dict : Dictionary = {}
	var loadfile = File.new()
	var temp
	loadfile.open(save_file, File.READ)
	temp = loadfile.get_as_text()
	load_dict = parse_json(temp)
	PlayerData = load_dict.duplicate(true)
	loadfile.close()
	HasLoaded = true
	
func WriteSaveData():
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData["username"])
	var save_file = save_dir+"/"+str(PlayerData["username"])+".json"
	var file = File.new()
	file.open(save_file, File.WRITE)
	file.store_line(to_json(PlayerData))
	Logging.log_notice("Data for " + str(PlayerData["username"]) + " saved.")
	
func DeleteSaveData(charname):
	Logging.log_notice("Deleting character "+charname+" for "+PlayerData["username"])
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData["username"])
	var save_file = save_dir+"/"+str(charname)+".json"
	var dir = Directory.new()
	dir.open(save_dir)
	dir.remove(save_file)
	
func DeleteCharacter(char_name):
	PlayerData.erase(char_name)
	DeleteSaveData(char_name)
	
func CreateActiveCharacter(character_name, player_id):
	ActiveCharacter = ActiveCharacterPath.instance()
	ActiveCharacter.name = character_name
	ActiveCharacter.ActiveController = self
	self.add_child(ActiveCharacter)
	Logging.log_notice("Loading existing character for "+str(player_id)+": "+character_name)
	ActiveCharacter.CharacterData["LastPlayed"] = OS.get_system_time_secs()
	
func CreateNewActiveCharacter(cuuid, species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height):
	Logging.log_notice("Creating new character for "+PlayerData["username"]+": "+character_name+" UUID "+str(cuuid))
	ActiveCharacter = ActiveCharacterPath.instance()
	ActiveCharacter.name = cuuid
	ActiveCharacter.ActiveController = self
	ActiveCharacter.CreateNewCharacter(cuuid, species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height)
	PlayerData["character_dict"][cuuid] = character_name
	self.add_child(ActiveCharacter)
	WriteSaveData()
	
	
	
