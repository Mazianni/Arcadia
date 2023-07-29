extends Node

@onready var TicketContainer = $HBoxContainer/PanelContainer/ScrollContainer/VBoxContainer
@onready var TicketWindowContainer = $"../../../TicketWindowContainer"

@onready var NewTicketDialog = %NewTicketDialog
@onready var NewTicketTitle = $"../../../NewTicketDialog/VBoxContainer/TicketTitle"
@onready var NewTicketDesc = $"../../../NewTicketDialog/VBoxContainer/TicketDesc"
@onready var NewTicketPlayerSelection = $"../../../NewTicketDialog/VBoxContainer/UserNameSelection"
@onready var NewTicketCritical = $"../../../NewTicketDialog/VBoxContainer/CriticalCheck"

@onready var TicketSoundNotifPlayer = $"../../../TicketNotif"

@onready var AddPlayerToTicketDialog = $"../../../AddPlayerToTicketDialog"
@onready var AddPlayerToTicketTicketSelection = $"../../../AddPlayerToTicketDialog/VBoxContainer/TicketSelection"
@onready var AddPlayerToTicketUserSelection = $"../../../AddPlayerToTicketDialog/VBoxContainer/UserSelection"

@onready var MiniTicketResource = load("res://scenes/Tickets/AdminTicketInstance.tscn")
@onready var TicketWindowResource = load("res://scenes/Tickets/TicketWindow.tscn")


var tickets : Dictionary
var cached_tickets : Dictionary

func _ready():
	Server.admin_tickets_recieved.connect(RenderTickets)
	Server.tickets_recieved.connect(DoUpdate)
	Server.player_list_recieved.connect(PopulateUserSelectionDialog)
	Server.GetTickets(true)
	
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
			nmt.ticket_box_clicked.connect(OpenTicketWindow)
			nmt.close_button_pressed.connect(CloseTicket)
			nmt.claim_button_pressed.connect(ClaimTicket)
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
		ntw.message_sent.connect(SendTicketMessage)
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
	if !NewTicketPlayerSelection.selected:
		Gui.CreateFloatingMessage("Select a player to open a ticket with them.", "bad")
	Server.OpenTicket(NewTicketTitle.text, NewTicketDesc.text, NewTicketPlayerSelection.get_item_text(NewTicketPlayerSelection.selected), NewTicketCritical.pressed)
	NewTicketTitle.text = ""
	NewTicketDesc.text = ""
	NewTicketPlayerSelection.selected = -1
	NewTicketCritical.button_pressed = false
	NewTicketDialog.hide()
	
func PopulateUserSelectionDialog(supplied:Array = Array()):
	var players : Array
	if !supplied.size():
		players = await Server.player_list_recieved
	else:
		players = supplied
	for I in players:
		AddPlayerToTicketUserSelection.add_item(I)
		NewTicketPlayerSelection.add_item(I)
	for I in tickets.keys():
		AddPlayerToTicketTicketSelection.add_item(I)
		
func AddUserToTicket(username:String, ticket_number:String):
	pass
	
func CloseTicket(ticket_number:String):
	Server.CloseTicket(ticket_number)
	
func SendTicketMessage(message:String, ticket_number:String):
	Server.SendMessageToTicket(message, ticket_number)
	
func ClaimTicket(ticket_number:String):
	Server.ClaimTicket(ticket_number)
	
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

func _on_Tickets_tab_hover(tab):
	Server.GetTickets(true)

func _on_Timer_timeout():
	Server.GetTickets(true)

func _on_AddPlayerToTicketDialog_about_to_show():
	Server.GetPlayerList()
	PopulateUserSelectionDialog()

func _on_AddButton_pressed():
	if AddPlayerToTicketUserSelection.selected && AddPlayerToTicketTicketSelection.selected:
		AddUserToTicket(AddPlayerToTicketUserSelection.get_item_text(AddPlayerToTicketUserSelection.selected), AddPlayerToTicketTicketSelection.get_item_text(AddPlayerToTicketTicketSelection.selected))
	AddPlayerToTicketTicketSelection.selected = -1
	AddPlayerToTicketUserSelection.selected = -1

func _on_NewTicketDialog_about_to_show():
	Server.GetPlayerList()
	PopulateUserSelectionDialog()


func _on_NewTicketWithPlayer_pressed():
	NewTicketDialog.popup()

func _on_AddPlayerToTicket_pressed():
	AddPlayerToTicketDialog.popup()
