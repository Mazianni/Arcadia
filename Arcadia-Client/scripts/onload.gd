extends Node

func _ready():
	Gui.ChangeGUIScene("LoginScreen")


func _on_SettingsButton_pressed():
	Settings.PopupSettings()
