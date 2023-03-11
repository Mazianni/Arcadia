extends Node

func _ready():
	var next_level_resource = load("res://scenes/IntroScreen.tscn")
	var next_level = next_level_resource.instance()
	$GUI.call_deferred("add_child", next_level)
	set_physics_process(false)


func _on_SettingsButton_pressed():
	Settings.PopupSettings()
