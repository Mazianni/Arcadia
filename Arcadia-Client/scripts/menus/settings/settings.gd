extends Node

@onready var UnitSelectionOptions = $NinePatchRect/MarginContainer/ScrollContainer/General/MarginContainer/GridContainer/UnitSelection/OptionButton
@onready var MusicVolSlider = $NinePatchRect/MarginContainer/ScrollContainer/Sound/MarginContainer/GridContainer/MusicVolume/VolumeSlider

func _ready():
	PopulateSettings()

		
func PopulateSettings():
	for i in Settings.MeasurementUnitOptions:
		UnitSelectionOptions.add_item(str(i))
	MusicVolSlider.value = Settings.CurrentSettingsDict["Music Volume"]
	
func _on_OptionButton_item_selected(index):
	Settings.CurrentSettingsDict["Measurement Units"] = UnitSelectionOptions.get_item_text(index)
	print(UnitSelectionOptions.get_item_text(index))

func _on_VolumeSlider_drag_ended(value_changed):
	Musicmanager.music_player.volume_db = linear_to_db(MusicVolSlider.value)
	Settings.CurrentSettingsDict["Music Volume"] = MusicVolSlider.value

func _on_close_requested():
	Settings.SaveSettingsToJSON()
	queue_free()
