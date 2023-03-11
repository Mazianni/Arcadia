extends Control

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			get_node("/root/RootNode/GUI/MainGUI/PanelContainer/Chatbox/ChatInput/OneLineChat").release_focus()
