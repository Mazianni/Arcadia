class_name InventoryBase extends Resource

@export var max_slots : int
@export var uuid : String
@export var attached_object : Node
@export var slots : Dictionary 
@export var width : int
@export var height : int
@export var owner : Node
@export var ethereal : bool
@export var locked : bool


var linked_uis : Array = []

signal contents_synced

func _init(owning_node):
	if slots.size() == 0:
		var x_inc : int = 0
		var y_inc : int = 0
		var inc : int = 0
		for i in width*height:
			slots[str(inc)] = {}
			x_inc += 1
			inc +=1
			if x_inc == width:
				x_inc == 0
				y_inc += 1
	if uuid:
		InventoryDataRepository.RegisterExistingUUID(uuid, self)
		
	owner = owning_node
	
func update_contents(dict : Dictionary):
	slots.clear()
	slots = dict.duplicate(true)
	contents_synced.emit()
			
func can_place_in_slot(position:String):
	if slots[position].size() == 0:
		return false
	return true

func get_next_avaliable_slot():
	for i in slots.keys():
		if slots[i] == {}:
			return i
			
func is_inventory_full():
	for i in slots.keys():
		if slots[i] == {}:
			return false
	return true
	
func get_free_slots():
	var free_slots : int = 0
	for i in slots.keys():
		if slots[i] == {}:
			free_slots += 1
	return free_slots
	
func get_amount_of_item_in_self(item : Dictionary):
	var returning_amt : int = 0
	for i in slots.keys():
		if slots[i]["type"] == item["type"]:
			returning_amt += slots[i]["amount"]
	return returning_amt
	
func can_remove_item_from_slot(slot_pos:String):
	if slots[slot_pos]:
		return true
	return false
	
func can_remove_item():
	if locked:
		return false
	return true
	
func has_item(item:Dictionary):
	for i in slots.keys():
		if slots[i]["uuid"] == item:
			return true

func get_item_slot(item:Dictionary):
	for i in slots.keys():
		if slots[i]["uuid"] == item:
			return slots[i]

#top level procs - general handling

func add_to_inventory(item : Dictionary, position :="(0,0)"):
	if is_inventory_full():
		return false
	if position:
		if not can_place_in_slot(position):
			position = get_next_avaliable_slot()
			if not position:
				return false
	else:
		position = get_next_avaliable_slot()
	if item["stacklike"] && !item["unique"]:
		if get_free_slots() >= 2:
			try_merge_stackables(item)
			return true
	slots[position] = item
	return true
	
func try_merge_stackables(item):
	var found_stack : Dictionary
	for i in slots.keys():
		var slot_item : Dictionary = slots[i]
		if slot_item["type"] == item["type"]: #like item found!
			if slot_item["amount"] + item["amount"] <= slot_item["max_amount"]:
				slot_item["amount"] += item["amount"]
				item.clear()
				break
			else:
				slot_item["amount"] += slot_item["max_amount"] - item["amount"]
				item["amount"] -= slot_item["max_amount"] - item["amount"]
				slots[get_next_avaliable_slot()] = item
				break
		else:
			slots[get_next_avaliable_slot()] = item
			break
			
func remove_from_inventory(position:String):
	if slots[position] != {}:
		var returning = slots[position].duplicate(true)
		slots[position].clear()
		return returning
		
func delete_from_inventory(item:Dictionary):
	for i in slots.keys():
		if slots[i][uuid] == item["uuid"]:
			slots[i].clear()
			break

func delete_from_inventory_position(position:String):
	if slots[position]:
		slots[position].clear()
	
func remove_from_inventory_amount(item : Dictionary, amount : int, position:String):
	var found_stack : Dictionary
	var remaining : int = amount
	for i in slots.keys():
		var slot_item : Dictionary = slots[i]
		if slot_item["type"] == item["type"]: #like item found!
			if slot_item["amount"] - remaining <= 0:
				remaining -= slot_item["amount"]
				slot_item.clear()
			else:
				slot_item["amount"] -= remaining
		if remaining == 0:
			return true
	
func move_in_inventory(old_position : String, new_position: String):
	var old_slot = slots[old_position]
	var new_slot = slots[old_position]
	if can_place_in_slot(new_position):
		new_slot.add_held_item(old_slot.remove_held_item())
		return true
	return false
	
func transfer_to_other_inventory(item : Dictionary, other_inv : InventoryBase):
	if other_inv.is_inventory_full():
		return false
	other_inv.add_to_inventory(remove_from_inventory(item.current_slot.position))
		
# UI stuff

func close_all_uis():
	for i in linked_uis:
		var ui : InventoryUI = InventoryDataRepository.GetUIByUUID(i)
		ui.Close()

func register_ui(ui_uuid : String):
	linked_uis.append(ui_uuid)
	
func unregister_ui(ui_uuid : String):
	linked_uis.erase(ui_uuid)
