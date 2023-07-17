extends Node

@onready var UnitSelectionOptions = $NinePatchRect/ScrollContainer/General/GridContainer/UnitSelection/OptionButton
@onready var MusicVolSlider = $NinePatchRect/ScrollContainer/Sound/GridContainer/MusicVolume/VolumeSlider

func _ready():
	PopulateSettings()

		
func PopulateSettings():
	for i in Settings.MeasurementUnitOptions:
		UnitSelectionOptions.add_item(str(i))
	MusicVolSlider.value = Settings.CurrentSettingsDict["Music Volume"]
	
func _on_OptionButton_item_selected(index):
	Settings.CurrentSettingsDict["Measurement Units"] = UnitSelectionOptions.get_item_text(index)
	print(UnitSelectionOptions.get_item_text(index))

func _on_CloseButton_pressed():
	Settings.SaveSettingsToJSON()
	queue_free()

func _on_VolumeSlider_drag_ended(value_changed):
	Musicmanager.music_player.volume_db = linear_to_db(MusicVolSlider.value)
	Settings.CurrentSettingsDict["Music Volume"] = MusicVolSlider.value
