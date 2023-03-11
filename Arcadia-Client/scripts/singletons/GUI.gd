extends Node


var floating_box_instance = preload("res://scenes/FloatingMessageBox.tscn")

onready var GlobalGUI = get_tree().get_root().get_node("RootNode/GUI")

func CreateFloatingMessage(message, type):
	var GUI = get_tree().get_root().get_node("RootNode/GUI/CanvasLayer/FloatingMessageContainer")
	var fbi = floating_box_instance.instance()
	fbi.name = Globals.uuid_generator.v4()
	fbi.type = type
	fbi.message = message
	GUI.add_child(fbi)
