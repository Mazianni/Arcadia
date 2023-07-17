extends Node

@onready var NoteTree = $HBoxContainer/NoteTree/ScrollContainer/VBoxContainer
@onready var NoteInstance = load("res://scenes/Admin/PlayerNotes/PlayernoteInstance.tscn")
@onready var NoteHeaderInstance = load("res://scenes/Admin/PlayerNotes/PlayernoteHeader.tscn")

@onready var ShowOnlyUsersWithNotesToggle = $HBoxContainer/VBoxContainer/ShowOnlyExistingNotes

@onready var NoteEditDialog = $"../../../EditNoteDialog"
@onready var NoteEditDialogTextEdit = $"../../../EditNoteDialog/VBoxContainer/TextEdit"

@onready var NoteAddDialog = $"../../../AddNoteDialog"
@onready var NoteAddDialogTextEdit = $"../../../AddNoteDialog/VBoxContainer/TextEdit"
@onready var NoteAddDialogTitle = $"../../../AddNoteDialog/VBoxContainer/LineEdit"

var player_notes:Dictionary

var last_edited_note_number
var last_edited_note_username
var last_added_note_username

func _ready():
	Server.connect("player_notes_recieved", Callable(self, "UpdateNotes"))
	Server.RequestNotes()
	Server.GetPlayerList()
	
func UpdateNotes(new_notes:Dictionary):
	player_notes = new_notes.duplicate(true)
	var note_render_dict : Dictionary
	if NoteTree.get_children():
		for C in NoteTree.get_children():
			C.queue_free()
	if ShowOnlyUsersWithNotesToggle.pressed:
		note_render_dict = player_notes
	else:
		note_render_dict = await Server.player_list_recieved
	for I in note_render_dict.keys():
		var new_header = NoteHeaderInstance.instantiate()
		NoteTree.add_child(new_header)
		new_header.connect("add_note_button_pressed", Callable(self, "AddNotePressed"))
		new_header.username = I
		if player_notes[I].keys().has(I):
			for N in player_notes[I].keys():
				var new_note = NoteInstance.instantiate()
				new_note.connect("edit_button_pressed", Callable(self, "NoteEditButtonPressed"))
				new_note.connect("delete_button_pressed", Callable(self, "NoteRemoveButtonPressed"))
				new_note.number = N
				new_note.title = player_notes[I][N]["Description"]
				new_note.date = player_notes[I][N]["Date"]
				new_note.last_edited = player_notes[I][N]["LastEdited"]
				new_note.subject = player_notes[I][N]["Note"]
				new_note.creator = player_notes[I][N]["Creator"]
				new_note.username = player_notes[I]
				new_header.AddNode(new_note)
			
func AddNotePressed(username:String):
	last_added_note_username = username
	NoteAddDialog.window_title = "Add Player Note for " + username
	NoteAddDialog.popup()
	
func AddNoteConfirmPressed():
	if NoteAddDialogTextEdit.text && NoteAddDialogTitle.text:
		NoteAddDialog.hide()
		Server.AddPlayerNote(last_added_note_username, NoteAddDialogTextEdit.text, NoteAddDialogTitle.text)
		NoteAddDialogTextEdit.text = ""
		last_added_note_username = ""
		NoteAddDialogTitle.text = ""
	else:
		Gui.CreateFloatingMessage("You must enter a note title and description to add one!", "bad")
		
func NoteEditButtonPressed(number:String, username:String):
	last_edited_note_number = number
	last_edited_note_username = username
	NoteEditDialog.window_title = "Edit Note #"+number+" for "+username
	NoteEditDialogTextEdit.text = player_notes[username][number]["Note"]
	NoteEditDialog.popup()
	
func NoteEditConfirmPressed():
	Server.EditPlayerNote(last_edited_note_username, last_edited_note_number, NoteEditDialogTextEdit.text)
	NoteEditDialogTextEdit.text = ""
	last_edited_note_number = ""
	last_edited_note_username = ""
	NoteEditDialog.hide()
	
func NoteRemoveButtonPressed(number:String, username:String):
	Server.RemovePlayerNote(username, number)
	Server.RequestNotes()
	
func _on_NoteEditConfirm_pressed():
	NoteEditConfirmPressed()
	
func _on_NoteAddConfirm_pressed():
	AddNoteConfirmPressed()
	
func _on_ShowOnlyExistingNotes_pressed():
	Server.RequestNotes()
	Server.GetPlayerList()
	
#func UpdateNotes(new_notes:Dictionary):
#	player_notes = new_notes.duplicate(true)
#	var root = NoteTree.create_item()
#	NoteTree.hide_root = true
#	for I in player_notes.keys():
#		var treechild = NoteTree.create_item(root)
#		var notenumber = 0
#		treechild.set_text(0, I)
#		for N in player_notes[I]:
#			notenumber += 1
#			var treechild_number = NoteTree.create_item(treechild)
#			var treechild_creator = NoteTree.create_item(treechild)
#			var treechild_date = NoteTree.create_item(treechild)
#			var treechild_desc = NoteTree.create_item(treechild)
#			treechild_number.set_text(0, "#"+notenumber+" - "+treechild_date.set_text(0, "Added On: "+player_notes[I][N]["Description"]))
#			treechild_creator.set_text(0, "Added By: "+player_notes[I][N]["Creator"])
#			treechild_date.set_text(0, "Added On: "+player_notes[I][N]["Date"])
#			treechild_desc.set_text(0, player_notes[I][N]["Note"])


