extends Node

var current_loaded_GUI
var GUI_Scenes : Dictionary = {
	"LoginScreen":"res://scenes/LoginScreen.tscn",
	"CharacterSelect":"res://scenes/CharacterSelect.tscn",
	"CharacterCreation":"res://scenes/CharacterCreation.tscn",
	"MainGameUI":"res://scenes/MainGUI.tscn",
}

var floating_box_instance = preload("res://scenes/FloatingMessageBox.tscn")

onready var GlobalGUI = get_tree().get_root().get_node("RootNode/GUI")

func CreateFloatingMessage(message, type):
	var GUI = get_tree().get_root().get_node("RootNode/GUI/CanvasLayer/FloatingMessageContainer")
	var fbi = floating_box_instance.instance()
	fbi.name = Globals.uuid_generator.v4()
	fbi.type = type
	fbi.message = message
	GUI.add_child(fbi)
	
func ChangeGUIScene(newscenename):
	if current_loaded_GUI:
		current_loaded_GUI.queue_free()
	var newguisceneresource = load(GUI_Scenes[newscenename])
	var newguisceneinstance = newguisceneresource.instance()
	current_loaded_GUI = newguisceneinstance
	GlobalGUI.add_child(newguisceneinstance)
	
func RemoveActiveGUI():
	current_loaded_GUI.queue_free()
