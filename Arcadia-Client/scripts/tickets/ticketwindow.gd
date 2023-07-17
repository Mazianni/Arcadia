extends Node

@onready var MessageBox = $VBoxContainer/Panel/ScrollContainer/VBoxContainer
@onready var TextInput = $VBoxContainer/TextEdit
@onready var LineResource = load("res://scenes/Tickets/TicketWindowTextLine.tscn")

var ticket:Dictionary
var ticket_number:String

signal message_sent(message, ticket_number)

func _ready():
	RenderMessages()
	self.window_title = "#"+ticket_number + " - " +ticket["Title"]
	
func RenderMessages():
	for L in MessageBox.get_children():
		L.queue_free()
	for I in ticket["Messages"].keys():
		var newline = LineResource.instantiate()
		newline.timestamp = ticket["Messages"][I]["T"]
		newline.sender = ticket["Messages"][I]["Sender"]
		newline.message = ticket["Messages"][I]["Message"]
		MessageBox.add_child(newline)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if $VBoxContainer/TextEdit.text && $VBoxContainer/TextEdit.has_focus():
			emit_signal("message_sent", $VBoxContainer/TextEdit.text, ticket_number)
			$VBoxContainer/TextEdit.text = ""
		
