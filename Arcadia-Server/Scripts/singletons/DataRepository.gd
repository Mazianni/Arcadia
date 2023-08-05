extends Node

# This file exists mostly to hold all the singleton declarations which are copied or referenced at one point or another.

enum CLIENT_STATE_LIST {CLIENT_UNAUTHENTICATED, CLIENT_PREGAME, CLIENT_INGAME}
enum SERVER_STATE {SERVER_LOADING, SERVER_LOADED, SERVER_SHUTTING_DOWN, CAN_SHUTDOWN}
enum MESSAGE_TYPE {NORMAL, YELL}

@onready var dbname = OS.get_executable_path().get_base_dir()+"/playerdata.db"
@onready var uuid_generator = load("res://uuid.gd")
@onready var collider_resource = load("res://Scenes/Instances/player/PlayerCollider.tscn")
@onready var warper_resource = load("res://Scenes/MapObjects/Warper.tscn")
@onready var Server : MainServer = get_tree().get_root().get_node("Server")
@onready var stateprocessing : StateProcessor
@onready var mapmanager : MapManager
@onready var Admin : AdminManager
@onready var PlayerMgmt : PlayerManager 

var serverversion = "0.1a"
var saves_directory : String
var CurrentState 
var MapManager : Node
var db : SQLite

var races : Dictionary = {
	"Human" : load("res://Resources/Races/human.tres")
}
var spawns : Dictionary = {
	"Default" : {"MapName":"Test", "pos": Vector2(430, 372)}
}
var chat_commands_dict : Dictionary = {
	"yell":{"distance":450, "command":"/yell ", "allcaps":true, "particle":"[b]yells[/b]", "start_formatting":"[b]", "end_formatting":"[/b]"}
}
var functional_commands_dict : Dictionary = {
	"/help" : "It works."
}
var category_bbcode_colors : Dictionary = {
	"Emote" : "#97c4a3",
	"OOC" : "#00469c",
	"LOOC" : "#81b1eb",
	"ADMIN":"#c685ff"
}
var approved_users_for_races : Dictionary = {} #format is initial key: "username" : {"race1":"false"}
var pid_to_username : Dictionary = {}
var hair_styles : Dictionary = {}
var default_emote_range : int = 350


func _ready():
	saves_directory = "user://"+ "saves"
	SubsystemManager.subsystem_manager_loaded_subsystem.connect(Callable(self, "ConnectSubsystem"))
	if not FileAccess.file_exists(saves_directory):
		var dir = DirAccess.open(saves_directory)
		if not DirAccess.dir_exists_absolute(saves_directory):
			dir.make_dir(saves_directory)
			
func ConnectSubsystem(nodename:String, node:Node):
	match nodename:
		"Admin":
			Admin = node
			Logging.log_notice("[DATA REPOSITORY] Subsystem "+node.name+" connected to ADMIN.")
		"MapManager":
			mapmanager = node
			Logging.log_notice("[DATA REPOSITORY] Subsystem "+node.name+" connected to MAPMANAGER.")
		"StateProcessing":
			stateprocessing = node
			Logging.log_notice("[DATA REPOSITORY] Subsystem "+node.name+" connected to STATEPROCESSOR.")
		"PlayerManager":
			PlayerMgmt = node
			Logging.log_notice("[DATA REPOSITORY] Subsystem "+node.name+" connected to PLAYERMANAGER.")

func SetServerState(new_state):
	CurrentState = new_state
	match new_state:
		SERVER_STATE.SERVER_LOADING:
			Logging.log_notice("[SERVER STATE] ServerState is now LOADING.")
		SERVER_STATE.SERVER_LOADED:
			Logging.log_notice("[SERVER STATE] ServerState is now LOADED.")
		SERVER_STATE.SERVER_SHUTTING_DOWN:
			Logging.log_notice("[SERVER STATE] ServerState is now SHUTTING DOWN.")
		SERVER_STATE.CAN_SHUTDOWN:
			Logging.log_notice("[SERVER STATE] ServerState is now CAN_SHUTDOWN.")
		
func remove_pid_assoc(player_id):
	pid_to_username.erase(str(player_id))
	
func WriteNewUserToDB(username, hashed, salt):
	db = SQLite.new()
	db.path = dbname
	db.open_db()
	var tableName = "playerdata"
	var dict : Dictionary = Dictionary()
	var success = false
	dict["username"] = username
	dict["hash"] = hashed
	dict["salt"] = salt
	success = db.insert_row(tableName, dict)
	db.close_db()
	return success
	
func GetDataFromDB(table, selection, data): #table = name of table selection = column name data = data to select from. Boolean return.
	db = SQLite.new()
	db.path = dbname
	db.open_db()
	var dbreturn = db.select_rows(table, selection, data)
	db.close_db()
	return dbreturn
