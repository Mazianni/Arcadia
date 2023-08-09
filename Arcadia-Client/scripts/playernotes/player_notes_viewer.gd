extends Node

@onready var NoteTree = $MarginContainer/HBoxContainer/VBoxContainer
@onready var NoteInstance = load("res://scenes/Admin/PlayerNotes/PlayernoteInstance.tscn")
@onready var NoteHeaderInstance = load("res://scenes/Admin/PlayerNotes/PlayernoteHeader.tscn")

@onready var ShowOnlyUsersWithNotesToggle : CheckButton = $MarginContainer/HBoxContainer/ShowOnlyExistingNotes

@onready var NoteEditDialog : Window  = $"../../../EditNoteDialog"
@onready var NoteEditDialogTextEdit = $"../../../EditNoteDialog/VBoxContainer/TextEdit"

@onready var NoteAddDialog : Window = $"../../../AddNoteDialog"
@onready var NoteAddDialogTextEdit = $"../../../AddNoteDialog/VBoxContainer/TextEdit"
@onready var NoteAddDialogTitle = $"../../../AddNoteDialog/VBoxContainer/LineEdit"

var player_notes:Dictionary = {}
var player_list:Array = []

var last_edited_note_number
var last_edited_note_username
var last_added_note_username

func _ready():
	Server.connect("player_notes_recieved", Callable(self, "UpdateNotes"))
	Server.player_list_recieved.connect(Callable(self, "UpdatePlayerList"))
	Server.RequestNotes()
	Server.GetPlayerList()
	
func UpdateNotes(new_notes:Dictionary):
	player_notes = new_notes.duplicate(true)
	var existing_note_headers : Array = []
	if NoteTree.get_children(): #check for old note headers.
		for C in NoteTree.get_children():
			if C.username in player_list:
				if ShowOnlyUsersWithNotesToggle.button_pressed:
					if not player_notes.keys().has(C):
						C.queue_free()
				else:
					existing_note_headers.append(C.username)
					continue
			else:
				C.queue_free()
	for I in player_list: #create new note headers
		if existing_note_headers.has(I):
			continue
		if ShowOnlyUsersWithNotesToggle.button_pressed:
			if not player_notes.keys().has(I):
				continue
		var new_header = NoteHeaderInstance.instantiate()
		NoteTree.add_child(new_header)
		new_header.connect("add_note_button_pressed", Callable(self, "AddNotePressed"))
		new_header.username = I
		new_header.DrawUsername()
	for PN in NoteTree.get_children(): #update all note headers.
		var header_node : PlayerNoteHeader = PN
		var existing_nodes : Array = header_node.NoteContainerBox.get_children()
		var existing_nodes_text : Array
		for K in existing_nodes:
			existing_nodes_text.append(K.number)
		if player_notes.size() == 0:
			continue
		if player_notes[header_node.username].keys().size():
			for N in player_notes[header_node.username]["Notes"].keys():
				if existing_nodes_text.has(N):
					var updating_note : PlayerNoteInstance = header_node.NoteContainerBox.get_node(N)
					updating_note.last_edited = player_notes[header_node.username]["Notes"][N]["LastEdited"]
					updating_note.subject = player_notes[header_node.username]["Notes"][N]["Note"]
					updating_note.RenderText()
					continue
				var new_note = NoteInstance.instantiate()
				new_note.connect("edit_button_pressed", Callable(self, "NoteEditButtonPressed"))
				new_note.connect("remove_button_pressed", Callable(self, "NoteRemoveButtonPressed"))
				new_note.name = N
				new_note.number = N
				print(player_notes[header_node.username])
				print(N)
				new_note.title = player_notes[header_node.username]["Notes"][N]["Description"]
				new_note.date = player_notes[header_node.username]["Notes"][N]["Date"]
				new_note.last_edited = player_notes[header_node.username]["Notes"][N]["LastEdited"]
				new_note.subject = player_notes[header_node.username]["Notes"][N]["Note"]
				new_note.creator = player_notes[header_node.username]["Notes"][N]["Creator"]
				new_note.username = header_node.username
				header_node.AddNode(new_note)
			
func AddNotePressed(username:String):
	last_added_note_username = username
	NoteAddDialog.title = "Add Player Note for " + username
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
	NoteEditDialog.title = "Edit Note #"+number+" for "+username
	NoteEditDialogTextEdit.text = player_notes[username]["Notes"][number]["Note"]
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

func _on_player_note_refresh_timer_timeout():
	Server.RequestNotes()
	Server.GetPlayerList()
	
func UpdatePlayerList(new_players:Array):
	player_list = new_players
	print(player_list)
