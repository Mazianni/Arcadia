extends Node

var CurrentSettingsDict : Dictionary = {}
var DefaultSettingsDict : Dictionary = {
	"Measurement Units" : "Metric"
}
var MeasurementUnitOptions : Array = ["Metric", "Imperial"]

var settingscene = load("res://scenes/SettingsScreen.tscn")

func LoadSettingsFromJSON():
	var save_dir = "user://"
	var save_file = "settings.json"
	var load_dict : Dictionary = {}
	var loadfile = File.new()
	var temp
	loadfile.open(save_dir+save_file, File.READ)
	temp = loadfile.get_as_text()
	load_dict = parse_json(temp)
	CurrentSettingsDict = load_dict.duplicate(true)
	loadfile.close()
	
func SaveSettingsToJSON():
	print("saving settings")
	var save_dir = "user://"
	var save_file = "settings.json"
	var file = File.new()
	file.open(save_dir+save_file, File.WRITE)
	file.store_line(to_json(CurrentSettingsDict))
	file.close()	
	
func PopupSettings():
	var newsettingwindow = settingscene.instance()
	Gui.GlobalGUI.add_child(newsettingwindow)