extends Node

enum RANK_FLAGS {NONE, MANAGE_TICKETS, IS_STAFF}
enum TICKET_FLAGS {TICKET_OPEN, TICKET_STAFF_ASSIGNED, TICKET_CLOSED}

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
var persistent_uuid
var character_uuid
var client_state
var serverconn
var currentscene

var is_admin_client = false #you may think you're very clever by setting this to true. you're not.

var config_file
var client_version = "0.1a"

enum CLIENT_STATE_LIST {CLIENT_UNAUTHENTICATED, CLIENT_PREGAME, CLIENT_INGAME}
enum SERVER_CONNECTION_STATE {DISCONNECTED, CONNECTED}
enum CURRENT_SCENE {SCENE_LOGIN, SCENE_SELECTION, SCENE_CREATION, SCENE_PLAYING}
enum MESSAGE_CATEGORY {IC, OOC, LOOC, ADMIN, ETC}

func _ready():
	uuid = uuid_generator.v4()
	client_state = CLIENT_STATE_LIST.CLIENT_UNAUTHENTICATED
	serverconn = SERVER_CONNECTION_STATE.DISCONNECTED
	CheckSettingsExist()
	CheckPersistentUUIDExists()
	Settings.LoadSettingsFromJSON()
	
func CheckSettingsExist():
	var save_dir = "user://"
	var newsave = File.new()
	if newsave.file_exists(save_dir+"setting.json"):
		print("fuck")
		newsave.open(save_dir+"settings.json", File.WRITE)
		newsave.store_line(to_json(Settings.DefaultSettingsDict))
		newsave.close()

func CheckPersistentUUIDExists():
	var save_dir = "user://"
	var save_file = "persistent.json"
	var newsave = File.new()
	if not newsave.file_exists(save_dir+save_file):
		newsave.open(save_dir+"/"+save_file, File.WRITE)
		newsave.store_line(to_json(uuid_generator.v4()))
		newsave.close()
	else:
		var loadfile = File.new()
		loadfile.open(save_dir+save_file, File.READ)
		persistent_uuid = loadfile.get_as_text()
		loadfile.close()

	
	
