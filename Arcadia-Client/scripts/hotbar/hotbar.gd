class_name HotBar extends Node

@onready var hotbarslotres = preload("res://scenes/Hotbar/HotbarSlot.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var input_array : Array
	var it = 0
	for i in range(0,9):
		input_array += InputMap.action_get_events("spell"+str(it))
		var new_slot = hotbarslotres.instantiate()
		new_slot.SetLabel(OS.get_keycode_string(input_array[it].physical_keycode))
		new_slot.bound_action = "spell"+str(it)
		new_slot.name = str(it)
		$Panel/Normal.add_child(new_slot)
		new_slot.slot_changed.connect(Callable(CombatHandler, "ClientCombatHandler_SendHotbar"))
		it += 1
	CombatHandler.hotbar = self
		
func CreateHotbarDict():
	var return_dict : Dictionary = {}
	for i in $Panel/Normal.get_children():
		if i.bound_item:
			return_dict[i.name] = i.bound_item["name"]
		elif i.bound_spell:
			return_dict[i.name] = i.bound_spell["name"]
	return return_dict
		
		
