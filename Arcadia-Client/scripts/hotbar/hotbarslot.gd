class_name HotBarSlot extends Control

@onready var SlotTimer : Timer = $Timer

var bound_action
var bound_item : Dictionary
var bound_spell : Dictionary

signal slot_changed

func SetLabel(text):
	$Hotkey.text = text
	
func ResetSlot(item = false):
	if item:
		bound_item.clear()
	else:
		bound_spell.clear()
	$TextureRect.texture = null
	slot_changed.emit()
	
func _process(delta):
	if SlotTimer and SlotTimer.time_left != 0:
		$TimerLabel.text = str(snapped(SlotTimer.time_left, 0.1))
	if Input.is_action_just_pressed(bound_action) && SlotTimer.time_left == 0:
		if bound_item.size() > 0 or bound_spell.size() > 0:
			AttemptAction()
			
func AttemptAction():
	if bound_item.size() > 0:
		return
	if bound_spell.size() > 0:
		CombatHandler.ClientCombatHandler_RequestAbilityActivate(bound_action, bound_spell["name"])

func SetTimer(time):
	SlotTimer.start(time)
	$TextureRect.modulate = Color(0.5,0.5,0.5,1)
	$TimerLabel.show()

func _on_timer_timeout():
	$TimerLabel.hide()
	$TextureRect.modulate = Color(1,1,1,1)
	
func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_DICTIONARY
	
func _drop_data(at_position, data):
	if data.has("consumable"):
		for i in get_tree().get_nodes_in_group("hotbar_slots"):
			if i.bound_item == data:
				i.ResetSlot(true)
		bound_item = data.duplicate(true)
		$TextureRect.texture = load(data["texture"])
	if data.has("point_cost"):
		for i in get_tree().get_nodes_in_group("hotbar_slots"):
			if i.bound_spell == data:
				i.ResetSlot(false)
		bound_spell = data.duplicate(true)
		$TextureRect.texture = load("res://sprites/spell_trees/"+data["texture"])
	slot_changed.emit()
