extends Window

func _process(delta):
	if Input.is_action_just_pressed("esc_menu"):
		if visible:
			hide()
		else:
			show()
	
func _on_settings_button_pressed():
	Settings.PopupSettings()
	hide()

func _on_visibility_changed():
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		$ColorRect/VBoxContainer/ReturnToSelectionButton.hide()
	else:
		$ColorRect/VBoxContainer/ReturnToSelectionButton.show()

func _on_close_requested():
	hide()


func _on_return_to_selection_button_pressed():
	Globals.SetClientState(Globals.CLIENT_STATE_LIST.CLIENT_PREGAME)
