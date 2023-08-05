class_name PlayerNoteInstance extends Node

var number
var title
var date
var subject
var creator
var username
var last_edited

@onready var TitleLabel = $VBoxContainer/Title/Label
@onready var DateLabel = $VBoxContainer/Date/Label
@onready var CreatorLabel = $VBoxContainer/Creator/Label
@onready var Description = $VBoxContainer/Description/ScrollContainer/Label
@onready var DescriptionContainer = $VBoxContainer/Description

signal edit_button_pressed(number, username)
signal remove_button_pressed(number, username)

func _ready():
	RenderText()

func RenderText():
	TitleLabel.text = "#"+number+" - "+title
	DateLabel.text = "Time and Date: "+date
	if last_edited:
		DateLabel.text += " Last Edited on: "+last_edited
	CreatorLabel.text = "Added By: "+creator
	Description.text = subject

func _on_ExpandButton_pressed():
	DescriptionContainer.visible = !DescriptionContainer.visible

func _on_EditButton_pressed():
	emit_signal("edit_button_pressed", number, username)
	
func _on_RemoveButton_pressed():
	emit_signal("remove_button_pressed", number, username)
