class_name ActiveCharacter extends Node

var IsNewCharacter = false
var BaseSpecies : SpeciesBase
var ActiveController : Node
var CurrentPosition : String
var CurrentMap : String
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
	"LastPosition":"",
	"LastPlayed":""
}

func _ready():
	if IsNewCharacter != true:
		LoadJSON(self.name)
	if not CheckJSONExists(self.name): #check if JSON exists, if not, create and store defaults.
		IsNewCharacter = true
		
	
func CheckJSONExists(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData["username"])
	var save_file = save_dir+"/"+str(character_name)+".json"
	var file = File.new()
	var json_exists = true
	if not file.file_exists(save_file): # This is a new character, and thus loaded defaults as done in the init proc are standard.
		file.open(save_file, File.WRITE)
		file.store_line(to_json(CharacterData))
		file.close()
		json_exists = false
	return json_exists
	
func LoadJSON(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData["username"])
	var save_file = save_dir+"/"+str(character_name)+".json"
	var load_dict = {}
	var loadfile = File.new()
	var temp
	loadfile.open(save_file, File.READ)
	temp = loadfile.get_as_text()
	load_dict = parse_json(temp)
	CharacterData = load_dict.duplicate(true)
	loadfile.close()	
		
func WriteJSON(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData["username"])
	var save_file = save_dir+"/"+str(character_name)+".json"
	var file = File.new()
	file.open(save_file, File.WRITE)
	file.store_line(to_json(CharacterData))
	file.close()	
		
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
	WriteJSON(uuid)
	Logging.log_notice("New character by name of "+str(character_name)+" created.")


