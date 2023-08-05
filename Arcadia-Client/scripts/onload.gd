extends Node

@onready var background : ParallaxBackground = $ParallaxBackground

func _ready():
	Gui.ChangeGUIScene("LoginScreen")

func _on_SettingsButton_pressed():
	Settings.PopupSettings()
	
func ShowBackground(show:bool):
	if show:
		background.show()
	else:
		background.hide()
