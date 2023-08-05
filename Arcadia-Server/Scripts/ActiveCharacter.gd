class_name ActiveCharacter extends PlayerDataContainerBase

var IsNewCharacter = false
var BaseSpecies : SpeciesBase
var ActiveController : PlayerContainer
var CurrentPosition : Vector2
var CurrentMap : String
var CurrentCollider : PlayerCollider
var CharacterData : Dictionary = {
	"uuid":"",
	"Name":"",
	"Species":"",
	"Age":"",
	"Gender":"",
	"Stats":{
		
	},
	"Inventory": {
		
	},
	"hair_style":"",
	"hair_color":"",
	"ear_style":"",
	"tail_style":"",
	"accessory_one_style":"",
	"skin_color":"",
	"height":0,
	"LastMap":"",
	"LastPosition": Vector2(0,0),
	"LastPlayed":0
}

signal load_success(pid, map)
signal load_failed(pid)
signal creation_successful
signal collider_created(pid, map)

func _ready():
	connect("tree_exiting", Callable(self, "OnDeleted"))
	load_failed.connect(Callable(DataRepository.Server,"ReturnCharacterLoadFailed"))
	load_failed.connect(Callable(self,"OnLoadFailed"))
	collider_created.connect(Callable(DataRepository.Server, "ReturnCharacterLoaded"))
	load_success.connect(Callable(self, "OnLoadSuccessful"))
	if IsNewCharacter != true:
		LoadJSON(self.name)
	if not CheckJSONExists(self.name): #check if JSON exists, if not, create and store defaults.
		IsNewCharacter = true

func OnDeleted():
	if DataRepository.CurrentState == DataRepository.SERVER_STATE.SERVER_SHUTTING_DOWN:
		return
	WriteJSON(CharacterData["uuid"])
	if CurrentCollider && is_instance_valid(CurrentCollider):
		CurrentCollider.queue_free()
	if ActiveController && is_instance_valid(ActiveController):
		ActiveController.CurrentActiveCharacter = null
		
func OnLoadFailed(pid):
	DataRepository.Server.SetClientState(DataRepository.CLIENT_STATE_LIST.CLIENT_PREGAME, ActiveController.associated_pid)
	queue_free()
	
func OnLoadSuccessful(pid, map):
	CreateCollider()
	load_failed.disconnect(Callable(self,"OnLoadFailed"))
	load_failed.disconnect(Callable(DataRepository.Server,"ReturnCharacterLoadFailed"))
	load_success.disconnect(Callable(self, "OnLoadSuccessful"))
	
func CheckJSONExists(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData["username"])
	var save_file = save_dir+"/"+str(character_name)+".json"
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	var json_exists = true
	if not FileAccess.file_exists(save_file): # This is a new character, and thus loaded defaults as done in the init proc are standard.
		file.store_line(JSON.stringify(CharacterData))
		file.close()
		json_exists = false
	return json_exists
	
func LoadJSON(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData["username"])
	var save_file = save_dir+"/"+str(character_name)+".json"
	var load_dict : Dictionary = {}
	var loadfile = FileAccess.open(save_file, FileAccess.READ)
	var temp : String
	temp = loadfile.get_as_text()
	var test_json_conv = JSON.new()
	test_json_conv.parse(temp)
	if(loadfile.get_error()):
		Logging.log_error("[FILE] Error loading save file for "+character_name+" username "+ActiveController.PlayerData["username"])
		loadfile.close()
		load_failed.emit(ActiveController.associated_pid)
		return
	if(test_json_conv.get_error_message()):
		Logging.log_error("[FILE] Error parsing JSON for "+character_name+" username "+ActiveController.PlayerData["username"])
		loadfile.close()
		load_failed.emit(ActiveController.associated_pid)
		return
	if(test_json_conv.get_data() == null):
		Logging.log_error("[FILE] Null data/corrupt data parsed in save file for "+character_name+" username "+ActiveController.PlayerData["username"])
		load_failed.emit(ActiveController.associated_pid)
		loadfile.close()
		return
	load_dict = test_json_conv.get_data()
	CharacterData = load_dict.duplicate(true)
	BaseSpecies = DataRepository.races[CharacterData["Species"]]
	loadfile.close()
	print(CharacterData["LastMap"])
	load_success.emit(ActiveController.associated_pid, CurrentMap)
		
func WriteJSON(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData["username"])
	var save_file = save_dir+"/"+str(character_name)+".json"
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	CharacterData["LastPosition"] = CurrentPosition
	file.store_line(JSON.stringify(CharacterData))
	var err = file.get_error()
	file.close()
	if err != OK:
		Logging.log_error("[FILE] Error encountered during save of character "+CharacterData["Name"]+ " with code "+str(err))
	
func CreateCollider():
	
	var new_collider = DataRepository.collider_resource.instantiate()
	new_collider.name = CharacterData["uuid"]
	new_collider.ControllingCharacter = self
	CurrentCollider = new_collider
	if CharacterData["LastMap"]:
		DataRepository.mapmanager.MovePlayerToMapStandalone(new_collider, CharacterData["LastMap"], Helpers.string_to_vector2(CharacterData["LastPosition"]))
		CurrentMap = CharacterData["LastMap"]
	collider_created.emit(ActiveController.associated_pid, CurrentMap)
	collider_created.disconnect(Callable(DataRepository.Server, "ReturnCharacterLoaded"))
	
func CreateNewCharacter(uuid, species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height):
	var result : bool = true
	var message : String = "New character "+character_name+" \ncreated successfully"
	BaseSpecies = DataRepository.races[species_name]
	CharacterData["uuid"] = name
	CharacterData["Species"] = species_name
	CharacterData["Name"] = character_name
	CharacterData["Age"] = age
	CharacterData["Gender"] = gender
	CharacterData["Stats"] = BaseSpecies.base_stats.duplicate(true)
	CharacterData["hair_style"] = hair_style
	CharacterData["hair_color"] = hair_color
	CharacterData["skin_color"] = skin_color
	CharacterData["ear_style"] = ear_style
	CharacterData["tail_style"] = tail_style
	CharacterData["accessory_one_style"] = accessory_one_style
	CharacterData["height"] = height
	CharacterData["LastMap"] = DataRepository.spawns[BaseSpecies.valid_spawns[0]]["MapName"]
	CharacterData["LastPosition"] = DataRepository.spawns[BaseSpecies.valid_spawns[0]]["pos"]
	WriteJSON(uuid)
	Logging.log_notice("New character by name of "+str(character_name)+" created successfully.")
	DataRepository.Server.ReturnNewCharacterCreated(ActiveController.associated_pid, result, message)
	queue_free()
