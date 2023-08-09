extends Node

func _on_close_requested():
	Settings.SaveSettingsToJSON()
	queue_free()
