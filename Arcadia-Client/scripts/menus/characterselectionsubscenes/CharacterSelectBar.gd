extends Node

var displayname
var originator
var is_empty_slot
var assigned_uuid

onready var ConfirmationDiag = $DeleteButton/ConfirmationDialog
onready var DeleteButton = $DeleteButton

signal SelectButtonPressed(charname, empty)
signal DeleteConfirmed(charname)

func _ready():
	get_node("CharacterSelectButton").text = displayname
	connect("SelectButtonPressed", originator, "SelectCharacter")
	connect("DeleteConfirmed", originator, "DeleteCharacter")
	if is_empty_slot:
		DeleteButton.hide()

func _on_SelectButton_pressed():
	emit_signal("SelectButtonPressed", assigned_uuid, is_empty_slot)

func _on_DeleteButton_pressed():
	ConfirmationDiag.dialog_text = "Are you sure you wish to delete " +displayname+"? This action cannot be undone."
	ConfirmationDiag.popup()
	
func _on_ConfirmationDialog_confirmed():
	ConfirmationDiag.hide()
	emit_signal("DeleteConfirmed", assigned_uuid)
	get_node("CharacterSelectButton").text = "Empty Slot"
	is_empty_slot = true
	assigned_uuid = null
	DeleteButton.hide()
	
