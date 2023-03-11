extends Node

# This file exists mostly to hold all the singleton declarations which are copied or referenced at one point or another.

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db
onready var dbname = OS.get_executable_path().get_base_dir()+"/playerdata.db"
onready var uuid_generator = load("res://uuid.gd")
var approved_users_for_races = {} #format is initial key: "username" : {"race1":"false"}
var pid_to_username = {}
var saves_directory : String
var races = {
	"Human" : load("res://Resources/Races/human.tres")
}
var hair_styles = {}

func _ready():
	saves_directory = OS.get_executable_path().get_base_dir() + "/saves"
	print(saves_directory)
	var filecheck = File.new()
	if not filecheck.file_exists(saves_directory):
		var dir = Directory.new()
		dir.make_dir(saves_directory)
		
func remove_pid_assoc(player_id):
	pid_to_username.erase(player_id)

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
