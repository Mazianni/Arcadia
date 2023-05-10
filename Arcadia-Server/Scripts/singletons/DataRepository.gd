extends Node

# This file exists mostly to hold all the singleton declarations which are copied or referenced at one point or another.

enum SERVER_STATE {SERVER_LOADING, SERVER_LOADED, SERVER_SHUTTING_DOWN}
enum MESSAGE_TYPE {NORMAL, YELL}


onready var dbname = OS.get_executable_path().get_base_dir()+"/playerdata.db"
onready var uuid_generator = load("res://uuid.gd")
onready var collider_resource = load("res://Scenes/Instances/player/PlayerCollider.tscn")
onready var warper_resource = load("res://Scenes/MapObjects/Warper.tscn")
onready var Server = get_tree().get_root().get_node("Server")

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")

var db

var serverversion = "0.1a"
var saves_directory : String
var CurrentState 
var MapManager : Node

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
var markdown_array : Array = [["b","[b]"],["/b","[/b]"],["i","[i]"],["/i","[/i]"]]
var default_emote_range : int = 350


func _ready():
	saves_directory = "user://"+ "saves"
	print(saves_directory)
	var filecheck = File.new()
	if not filecheck.file_exists(saves_directory):
		var dir = Directory.new()
		dir.make_dir(saves_directory)
	MapManager = get_node("/root/Server/MapManager")
		
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
