class_name ResourceBar extends Control

@onready var ChangeBarGood : TextureProgressBar = $ChangeBarGood
@onready var ChangeBarBad : TextureProgressBar = $ChangeBarBad
@onready var BaseBar : TextureProgressBar = $BaseBar
@onready var BaseLabel : Label = $Label

func UpdateBar(dict : Dictionary):
	var tween : Tween
	if dict["max_value"] != ChangeBarGood.max_value:
		ChangeBarGood.max_value = dict["max_value"]
	if dict["max_value"] != ChangeBarBad.max_value:
		ChangeBarBad.max_value = dict["max_value"]
	if dict["max_value"] != BaseBar.max_value:
		BaseBar.max_value = dict["max_value"]
	if dict["value"] > BaseBar.value:
		tween = create_tween()
		ChangeBarBad.value = 0
		ChangeBarGood.value = dict["value"]
		tween.tween_property(BaseBar, "value", dict["value"], 0.25)
	else:
		tween = create_tween()
		ChangeBarGood.value = 0
		ChangeBarBad.value = BaseBar.value
		tween.tween_property(BaseBar, "value", dict["value"], 0.25)
		tween.tween_property(ChangeBarBad, "value",dict["value"], 1)
	BaseLabel.text = str(dict["value"])+"/"+str(dict["max_value"])
