extends Window

@onready var TicketContainer = $"Panel/HBoxContainer/PanelContainer/Your Tickets/VBoxContainer"
@onready var NewTicketButton = $Panel/HBoxContainer/VBoxContainer/NewTicket
@onready var TicketWindowContainer = $TicketWindowContainer

@onready var NewTicketDialog = $NewTicketDialog
@onready var NewTicketTitle = $NewTicketDialog/VBoxContainer/TicketTitle
@onready var NewTicketDesc = $NewTicketDialog/VBoxContainer/TicketDesc
@onready var NewTicketCritical = $NewTicketDialog/VBoxContainer/CriticalCheck

@onready var TicketSoundNotifPlayer = $TicketNotif

@onready var MiniTicketResource = load("res://scenes/Tickets/TicketInstance.tscn")
@onready var TicketWindowResource = load("res://scenes/Tickets/TicketWindow.tscn")


var tickets : Dictionary
var cached_tickets : Dictionary

func _ready():
	Server.connect("tickets_recieved", Callable(self, "RenderTickets"))
	Server.connect("ticket_update_recieved", Callable(self, "DoUpdate"))
	Server.GetTickets()
	
func DoUpdate(ticket_number:String, ticket:Dictionary):
	cached_tickets = tickets.duplicate(true)
	tickets[ticket_number] = ticket
	RenderTickets(tickets)
		
func RenderTickets(recieved_tickets:Dictionary):
	if !cached_tickets.size():
		cached_tickets = recieved_tickets.duplicate(true)
	else:
		cached_tickets = tickets.duplicate(true)
	tickets = recieved_tickets.duplicate(true)
	for I in tickets.keys():
		if !TicketContainer.has_node(I):
			var nmt = MiniTicketResource.instantiate()
			nmt.ticket_number = I
			nmt.status = tickets[I]["Status"]
			nmt.title = tickets[I]["Title"]
			TicketContainer.add_child(nmt)
			nmt.connect("ticket_box_clicked", Callable(self, "OpenTicketWindow"))
			nmt.connect("close_button_pressed", Callable(self, "CloseTicket"))
		if TicketContainer.has_node(I):
			TicketContainer.get_node(I).status = tickets[I]["Status"]
			TicketContainer.get_node(I).OnUpdate()
			if cached_tickets.has(str(I)):
				if cached_tickets[str(I)]["Messages"].size() != tickets[str(I)]["Messages"].size():
					TicketContainer.get_node(I).new_message = true
					TicketContainer.get_node(I).OnUpdate()
					TicketSoundNotifPlayer.play()
		if TicketWindowContainer.has_node(I):
			var tw = TicketWindowContainer.get_node(I)
			tw.ticket = tickets[I]
			tw.RenderMessages()
		
func OpenTicketWindow(ticket_number:String):
	Server.GetUpdateOnTicket(ticket_number)
	if !TicketWindowContainer.has_node(ticket_number):
		var ntw = TicketWindowResource.instantiate()
		ntw.ticket = tickets[ticket_number].duplicate(true)
		ntw.name = ticket_number
		ntw.ticket_number = ticket_number
		ntw.connect("message_sent", Callable(self, "SendTicketMessage"))
		TicketWindowContainer.add_child(ntw)
		ntw.popup()
	else:
		TicketWindowContainer.get_node(ticket_number).popup()
		
func CreateTicket():
	if !NewTicketTitle.text:
		Gui.CreateFloatingMessage("A Title is required to open a new ticket.", "bad")
		return
	if !NewTicketDesc.text:
		Gui.CreateFloatingMessage("A description is required to open a new ticket.", "bad")	
		return
	Server.OpenTicket(NewTicketTitle.text, NewTicketDesc.text, "", NewTicketCritical.button_pressed)
	NewTicketTitle.text = ""
	NewTicketDesc.text = ""
	NewTicketCritical.button_pressed = false
	NewTicketDialog.hide()
	
func CloseTicket(ticket_number:String):
	Server.CloseTicket(ticket_number)
	
func SendTicketMessage(message:String, ticket_number:String):
	Server.SendMessageToTicket(message, ticket_number)
	
func _on_NewTicket_pressed():
	NewTicketDialog.popup()

func _on_SubmitButton_pressed():
	CreateTicket()


func _on_TicketTitle_focus_entered():
	Globals.MouseOnUi = true


func _on_TicketTitle_focus_exited():
	Globals.MouseOnUi = false


func _on_TicketDesc_focus_entered():
	Globals.MouseOnUi = true


func _on_TicketDesc_focus_exited():
	Globals.MouseOnUi = false

func _on_TicketViewer_about_to_show():
	Server.GetTickets()

func _on_new_ticket_dialog_close_requested():
	NewTicketDialog.hide()

func _on_close_requested():
	self.hide()
