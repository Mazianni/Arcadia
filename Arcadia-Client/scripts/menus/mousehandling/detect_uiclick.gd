extends Control

@onready var ChatBar = $ChatboxContainer/Chatbox/ChatInput/OneLineChat
@onready var RPBox = $RPDialog/MarginContainer/RPBox/TextEdit
@onready var RPDialog = $RPDialog
@onready var AdminButton = $GridContainer/AdminPanelButton
@onready var TicketViewerResource = load("res://scenes/TicketViewer.tscn")
@onready var AdminPanelResource = load("res://scenes/Admin/AdminPanel.tscn")
@onready var InventoryPanelResource = load("res://scenes/Inventory/InventoryPanel.tscn")
@onready var MarkupDialog = $RPDialog/MarkupDialog

var ticketviewer : Window
var adminpanel : Window
var inventorypanel : Window

func _ready():
	ChatManager.HookMainUI($ChatboxContainer/Chatbox/ScrollContainer/ChatOutputContainer)
	ChatManager.SetCurrentChatTab($ChatboxContainer/Chatbox/ChatSelect/ChatSelectTabs.get_current_tab_control())
	Server.IsClientAdmin()
	Server.connect("admin_verified", Callable(self, "OnAdminVerification"))
	
func _input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ENTER:
			if ChatBar.has_focus():
				if ChatBar.text:
					ChatManager.SendChat(ChatBar.text, false)
					ChatBar.set_text("")
					
func OnAdminVerification(decision:bool):
	if decision:
		AdminButton.show()
	
func _on_RP_pressed():
	var vis = false
	match $RPDialog.visible:
		false:
			vis = false
		true:
			vis = true
	if(!vis):
		$RPDialog.popup()
	else:
		$RPDialog.hide()
			
func _on_RPDialog_modal_closed():
	Globals.MouseOnUi = false

func _on_SubmitButton_pressed():
	if RPBox.text:
		ChatManager.SendChat(RPBox.text, true)
		RPBox.set_text("")
		$RPDialog.hide()

func _on_ChatSelectTabs_tab_changed(tab):
	ChatManager.SetCurrentChatTab($ChatboxContainer/Chatbox/ChatSelect/ChatSelectTabs.get_tab_control(tab))

func _on_TicketsButton_pressed():
	if !ticketviewer:
		var tvi = TicketViewerResource.instantiate()
		add_child(tvi)
		tvi.popup()
		ticketviewer = tvi
	else:
		ticketviewer.popup()

func _on_OneLineChat_mouse_exited():
	ChatBar.release_focus()

func _on_TextEdit_mouse_exited():
	RPBox.release_focus()

func _on_AdminPanelButton_pressed():
	if !adminpanel:
		adminpanel = AdminPanelResource.instantiate()
		add_child(adminpanel)
		adminpanel.popup()
	else:
		adminpanel.popup()

func _on_markup_dialog_close_requested():
	MarkupDialog.hide()

func _on_rp_dialog_close_requested():
	RPDialog.hide()

func _on_inventory_button_pressed():
	if not inventorypanel:
		inventorypanel = InventoryPanelResource.instantiate()
		add_child(inventorypanel)
		inventorypanel.show()
	else:
		Server.RequestInventorySync()
		inventorypanel.show()
