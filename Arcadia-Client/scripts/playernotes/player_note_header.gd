extends Node

@onready var NoteContainerBox = $VBoxContainer/PanelContainer/ScrollContainer/HBoxContainer/VBoxContainer
@onready var UsernameLabel = $VBoxContainer/Panel/HBoxContainer/Label

var username : String

signal add_note_button_pressed(username)

func _ready():
	UsernameLabel.text = username
	
func AddNode(node2add:Node):
	NoteContainerBox.add_child(node2add)
	
func _on_AddNote_pressed():
	emit_signal("add_note_button_pressed", username)
