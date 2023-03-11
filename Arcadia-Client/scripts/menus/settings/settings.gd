extends Node

onready var UnitSelectionOptions = $NinePatchRect/ScrollContainer/GeneralSettings/GridContainer/UnitSelection/OptionButton

func _ready():
	PopulateSettings()
		
func PopulateSettings():
	for i in Settings.MeasurementUnitOptions:
		UnitSelectionOptions.add_item(str(i))
		
func _on_OptionButton_item_selected(index):
	Settings.CurrentSettingsDict["Measurement Units"] = UnitSelectionOptions.get_item_text(index)
	print(UnitSelectionOptions.get_item_text(index))

func _on_CloseButton_pressed():
	Settings.SaveSettingsToJSON()
	queue_free()
