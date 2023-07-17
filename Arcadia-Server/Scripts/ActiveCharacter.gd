class_name ActiveCharacter extends Node

var IsNewCharacter = false
var BaseSpecies : SpeciesBase
var ActiveController : Node
var CurrentPosition : Vector2
var CurrentMap : String
var CurrentCollider
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

func _ready():
	connect("tree_exiting", Callable(self, "OnDeleted"))
	if IsNewCharacter != true:
		LoadJSON(self.name)
	if not CheckJSONExists(self.name): #check if JSON exists, if not, create and store defaults.
		IsNewCharacter = true
	
	CreateCollider()
	
func OnDeleted():
	WriteJSON(CharacterData["uuid"])
	CurrentCollider.queue_free()
		
func CheckJSONExists(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData["username"])
	var save_file = save_dir+"/"+str(character_name)+".json"
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	var json_exists = true
	if not FileAccess.file_exists(save_file): # This is a new character, and thus loaded defaults as done in the init proc are standard.
		file.store_line(JSON.new().stringify(CharacterData))
		file.close()
		json_exists = false
	return json_exists
	
func LoadJSON(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData["username"])
	var save_file = save_dir+"/"+str(character_name)+".json"
	var load_dict = {}
	var loadfile
	var temp
	loadfile = FileAccess.open(save_file, FileAccess.READ)
	temp = loadfile.get_as_text()
	var test_json_conv = JSON.new()
	test_json_conv.parse(temp)
	load_dict = test_json_conv.get_data()
	CharacterData = load_dict.duplicate(true)
	BaseSpecies = DataRepository.races[CharacterData["Species"]]
	loadfile.close()	
		
func WriteJSON(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData["username"])
	var save_file = save_dir+"/"+str(character_name)+".json"
	var file = FileAccess.open(save_file, FileAccess.WRITE)
	CharacterData["LastPosition"] = CurrentPosition
	file.store_line(JSON.new().stringify(CharacterData))
	var err = file.get_error()
	file.close()
	if err != OK:
		Logging.log_error("[FILE] Error encountered during save of character "+CharacterData["Name"]+ " with code "+str(err))
	
func CreateCollider():
	var new_collider = DataRepository.collider_resource.instantiate()
	new_collider.name = CharacterData["uuid"]
	new_collider.ControllingCharacter = self
	CurrentCollider = new_collider
	print("fart")
	if CharacterData["LastMap"]:
		DataRepository.MapManager.MovePlayerToMapStandalone(new_collider, CharacterData["LastMap"], Helpers.string_to_vector2(CharacterData["LastPosition"]))
		
func CreateNewCharacter(uuid, species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height):
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
	Logging.log_notice("New character by name of "+str(character_name)+" created.")


