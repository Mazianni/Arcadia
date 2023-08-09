extends Node

@onready var background : ParallaxBackground = $ParallaxBackground

func _ready():
	Gui.ChangeGUIScene("LoginScreen")
	var tooltip_resource = load("res://addons/wyvernbox_prefabs/tooltip.tscn")
	var new_tt = tooltip_resource.instantiate()
	add_child(new_tt)

func _on_SettingsButton_pressed():
	Settings.PopupSettings()
	
func ShowBackground(show:bool):
	if show:
		background.show()
	else:
		background.hide()
