class_name ResourceBar extends Control

@onready var ChangeBarGood : TextureProgressBar = $ChangeBarGood
@onready var ChangeBarBad : TextureProgressBar = $ChangeBarBad
@onready var BaseBar : TextureProgressBar = $BaseBar
var last_value : int = 0
var current_value : int = 0
var target_value : int = 0

func _process(delta):
	if current_value == target_value:
		return
	if current_value <= target_value:
		current_value += 1
		$HBoxContainer/Current.text = str(current_value)
	elif current_value >= target_value:
		current_value -= 1
		$HBoxContainer/Current.text = str(current_value)
		
func UpdateBar(dict : Dictionary):
	var tween : Tween
	last_value = target_value
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
	target_value = dict["value"]
	$HBoxContainer/Max.text = str(dict["max_value"])

