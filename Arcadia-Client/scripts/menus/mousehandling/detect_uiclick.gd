extends Control

onready var ChatBar = $ChatboxContainer/Chatbox/ChatInput/OneLineChat
onready var RPBox = $RPDialog/RPBox/TextEdit

func _ready():
	ChatManager.HookMainUI($ChatboxContainer/Chatbox/ChatOutputContainer)
	ChatManager.SetCurrentChatTab($ChatboxContainer/Chatbox/ChatSelect/ChatSelectTabs.get_current_tab_control())

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			if ChatBar.has_focus():
				ChatManager.SendChat(ChatBar.text, false)
				ChatBar.set_text("")

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
	ChatManager.SendChat(RPBox.text, true)
	RPBox.set_text("")

func _on_MarkupButton_pressed():
	var vis = false
	match $RPDialog/MarkupDialog.visible:
		false:
			vis = false
		true:
			vis = true
	if(!vis):
		$RPDialog/MarkupDialog.popup()
	else:
		$RPDialog/MarkupDialog.hide()

func _on_OneLineChat_focus_entered():
	Globals.MouseOnUi = true

func _on_OneLineChat_focus_exited():
	Globals.MouseOnUi = false

func _on_TextEdit_focus_entered():
	Globals.MouseOnUi = true

func _on_TextEdit_focus_exited():
	Globals.MouseOnUi = false
	
func _on_ChatSelectTabs_tab_changed(tab):
	ChatManager.SetCurrentChatTab($ChatboxContainer/Chatbox/ChatSelect/ChatSelectTabs.get_tab_control(tab))
