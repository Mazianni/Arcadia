extends Window

@onready var newticketdialog = %NewTicketDialog
@onready var addplayertoticketdialog = $AddPlayerToTicketDialog
@onready var editnotedialog = $EditNoteDialog
@onready var addnotedialog = $AddNoteDialog

func _on_new_ticket_dialog_close_requested():
	newticketdialog.hide()

func _on_add_player_to_ticket_dialog_close_requested():
	addplayertoticketdialog.hide()

func _on_edit_note_dialog_close_requested():
	editnotedialog.hide()

func _on_add_note_dialog_close_requested():
	addnotedialog.hide()
	
func _on_close_requested():
	hide()
