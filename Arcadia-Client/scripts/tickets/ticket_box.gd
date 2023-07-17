extends Node

@onready var label = $Panel/HBoxContainer/TicketButton/Label
@onready var close_button = $Panel/HBoxContainer/CloseTicket
@onready var animation_player = $AnimationPlayer

var ticket_number
var title
var status
var new_message

signal ticket_box_clicked(ticket_number)
signal close_button_pressed(ticket_number)

func _ready():
	name = ticket_number
	label.text = str(ticket_number)+" "+title
	OnUpdate()
	
func OnUpdate():
	match status:
		Globals.TICKET_FLAGS.TICKET_OPEN:
			animation_player.set_current_animation("slowflash")
			
		Globals.TICKET_FLAGS.TICKET_STAFF_ASSIGNED:
			animation_player.stop()
			
		Globals.TICKET_FLAGS.TICKET_CLOSED:
			animation_player.set_current_animation("closed")
			label.text = "#"+ticket_number +" "+ title+" [CLOSED]"
			
	if status == Globals.TICKET_FLAGS.TICKET_STAFF_ASSIGNED && new_message:
		animation_player.set_animation("new_message")
	
func _on_TicketButton_pressed():
	emit_signal("ticket_box_clicked", ticket_number)
	if new_message:
		new_message = false
	
func _on_CloseTicket_pressed():
	emit_signal("close_button_pressed", ticket_number)
