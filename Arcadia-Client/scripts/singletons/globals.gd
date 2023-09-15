extends Node

var maphandler

var player_spawn = preload("res://scenes/PlayerTemplate.tscn")


enum RANK_FLAGS {NONE, MANAGE_TICKETS, IS_STAFF}
enum TICKET_FLAGS {TICKET_OPEN, TICKET_STAFF_ASSIGNED, TICKET_CLOSED}
enum SPELL_TYPE_FLAGS{SPELL_OFFENSIVE, SPELL_DEFENSIVE}
enum SPELL_EFFECT_TYPE{SPELL_TRACKER, SPELL_AOE, SPELL_SPECIAL}
enum CLIENT_STATE_LIST {CLIENT_UNAUTHENTICATED, CLIENT_PREGAME, CLIENT_INGAME}
enum SERVER_CONNECTION_STATE {DISCONNECTED, CONNECTED}
enum CURRENT_SCENE {SCENE_LOGIN, SCENE_SELECTION, SCENE_CREATION, SCENE_PLAYING}
enum MESSAGE_CATEGORY {IC, OOC, LOOC, ADMIN, ETC}

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
var ability_trees : Dictionary
var known_spells : Array
var uuid_generator = preload("res://uuid.gd")
var uuid
var persistent_uuid
var character_uuid
var client_state
var serverconn
var currentscene
var inventory_uuids : Dictionary
var is_client_admin = false #you may think you're very clever by setting this to true. you're not.
var config_file
var client_version = "0.1a"
var measurement_units : String = "Imperial"
var selected_player : Node
var warping : bool = false
var authorized_token : String

signal character_list_refresh_requested
signal show_viewport(show)
signal scene_changed(scene_enum)
signal create_main_player_obj
signal player_selected(node)

func _ready():
	uuid = uuid_generator.v4()
	client_state = CLIENT_STATE_LIST.CLIENT_UNAUTHENTICATED
	serverconn = SERVER_CONNECTION_STATE.DISCONNECTED
	CheckSettingsExist()
	CheckPersistentUUIDExists()
	Settings.LoadSettingsFromJSON()
	
func SetSelectedPlayer(node):
	selected_player = node
	player_selected.emit(node)
	if selected_player:
		selected_player.set_material(null)
	if node == null:
		CombatHandler.ClientCombatHandler_UpdateSelectedPlayer("")
	else:
		CombatHandler.ClientCombatHandler_UpdateSelectedPlayer(selected_player.name)
	
func SetClientState(new_state):
	client_state = new_state
	Server.ReportClientState(client_state)
	match new_state:
		CLIENT_STATE_LIST.CLIENT_PREGAME:
			Gui.ChangeGUIScene("CharacterSelect")
			if CharacterList.size():
				character_list_refresh_requested.emit()
			maphandler.ClearScenes()
			get_tree().get_root().get_node("RootNode").ShowBackground(true)
			show_viewport.emit(false)
		CLIENT_STATE_LIST.CLIENT_INGAME:
			Gui.ChangeGUIScene("MainGameUI")
			InventoryPredicate.ClientPredicate_RequestSelfInventoryUUIDs()
			get_tree().get_root().get_node("RootNode").ShowBackground(false)
			show_viewport.emit(true)
			create_main_player_obj.emit()
			CombatHandler.ClientCombatHandler_RequestSelfSpells()
		CLIENT_STATE_LIST.CLIENT_UNAUTHENTICATED:
			Gui.ChangeGUIScene("LoginScreen")				
			maphandler.ClearScenes()
			get_tree().get_root().get_node("RootNode").ShowBackground(true)
			show_viewport.emit(false)
	scene_changed.emit(new_state)
			
func CheckSettingsExist():
	var save_dir = "user://"
	var newsave = FileAccess.open(save_dir, FileAccess.READ)
	if FileAccess.file_exists(save_dir+"setting.json"):
		FileAccess.open(save_dir+"settings.json", FileAccess.WRITE_READ)
		newsave.store_line(JSON.stringify(Settings.DefaultSettingsDict))
		newsave.close()

func CheckPersistentUUIDExists():
	var save_dir = "user://"
	var save_file = "persistent.json"
	var newsave = FileAccess.open(save_dir, FileAccess.READ)
	if not FileAccess.file_exists(save_dir+save_file):
		FileAccess.open(save_dir+"/"+save_file, FileAccess.WRITE_READ)
		newsave.store_line(JSON.stringify(uuid_generator.v4()))
		newsave.close()
	else:
		var loadfile = FileAccess.open(save_dir+save_file, FileAccess.READ)
		persistent_uuid = loadfile.get_as_text()
		loadfile.close()

	
	
