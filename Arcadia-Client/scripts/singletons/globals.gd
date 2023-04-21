extends Node

var MouseOnUi = false
var CharacterList : Dictionary = {}
var RaceList : Dictionary
var PronounsList : Dictionary = {
	"Masculine": "He/Him/His",
	"Feminine": "She/Her/Hers",
	"Nonbinary": "They/Them/Theirs"
}
var BodytypeList : Array = ["Bodytype A", "Bodytype B"]
var HairList : Array = ["Ponytail"]
var DirectionsList : Dictionary = {
	1 : "south",
	2 : "east",
	3 : "north",
	4 : "west"
}

var uuid_generator = preload("res://uuid.gd")
var uuid
var character_uuid
var client_state
var serverconn
var currentscene

var config_file

enum CLIENT_STATE_LIST {CLIENT_UNAUTHENTICATED, CLIENT_PREGAME, CLIENT_INGAME}
enum SERVER_CONNECTION_STATE {DISCONNECTED, CONNECTED}
enum CURRENT_SCENE {SCENE_LOGIN, SCENE_SELECTION, SCENE_CREATION, SCENE_PLAYING}
enum MESSAGE_CATEGORY {IC, OOC, LOOC, ADMIN, ETC}

func _ready():
	uuid = uuid_generator.v4()
	client_state = CLIENT_STATE_LIST.CLIENT_UNAUTHENTICATED
	serverconn = SERVER_CONNECTION_STATE.DISCONNECTED
	CheckSettingsExist()
	Settings.LoadSettingsFromJSON()
	
func CheckSettingsExist():
	var save_dir = "user://"
	var dir = Directory.new()
	dir.open(save_dir)
	if not dir.dir_exists(save_dir):
		dir.make_dir(save_dir)
	if not dir.file_exists(save_dir+"setting.json"):
		var newsave = File.new()
		newsave.open(save_dir+"/"+"settings.json", File.WRITE)
		newsave.store_line(to_json(Settings.DefaultSettingsDict))
		newsave.close()

	
	
