extends Node

var CurrentSettingsDict : Dictionary = {}
var DefaultSettingsDict : Dictionary = {
	"Measurement Units" : "Metric",
	"Music Volume": 0.5,
}
var MeasurementUnitOptions : Array = ["Metric", "Imperial"]

var settingscene = load("res://scenes/SettingsScreen.tscn")

signal settings_loaded

func _ready():
	LoadSettingsFromJSON()
	#	UnitSelectionOptions.selected = Settings.CurrentSettingsDict["Measurement Units"]
	print(CurrentSettingsDict)
	for I in DefaultSettingsDict.keys():
		if !CurrentSettingsDict.keys().has(I):
			CurrentSettingsDict[I] = DefaultSettingsDict[I]
	await get_tree().create_timer(0.01).timeout
	emit_signal("settings_loaded")

func LoadSettingsFromJSON():
	var save_dir = "user://"
	var save_file = "settings.json"
	var load_dict : Dictionary = {}
	var loadfile = FileAccess.open(save_dir+save_file, FileAccess.READ)
	var temp
	temp = loadfile.get_as_text()
	var test_json_conv = JSON.new()
	test_json_conv.parse(temp)
	load_dict = test_json_conv.get_data()
	CurrentSettingsDict = load_dict.duplicate(true)
	loadfile.close()
	
func SaveSettingsToJSON():
	var save_dir = "user://"
	var save_file = "settings.json"
	var file = FileAccess.open(save_dir+save_file, FileAccess.WRITE)
	file.store_line(JSON.stringify(CurrentSettingsDict))
	file.close()	
	
func PopupSettings():
	var newsettingwindow = settingscene.instantiate()
	Gui.GlobalGUI.add_child(newsettingwindow)
