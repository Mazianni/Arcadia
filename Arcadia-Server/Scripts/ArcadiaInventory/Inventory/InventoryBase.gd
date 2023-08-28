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

func _init():
	if slots.size() == 0:
		var x_inc : int = 0
		var y_inc : int = 0
		var s_inc : int = 0
		for i in width*height:
			slots[str(s_inc)] = {}
			x_inc += 1
			s_inc +=1
			if x_inc == width:
				x_inc = 0
				y_inc += 1
	call_deferred("generate_uuid")

func generate_uuid():
	if uuid:
		InventoryDataRepository.RegisterExistingUUID(uuid, self)
	else:
		uuid = InventoryDataRepository.GenerateUUID(self)
		
func GenerateUnique():
	uuid = InventoryDataRepository.GenerateUUID(self)
		
func can_place_in_slot(position:String, item:Dictionary):
	if slots[position].size() == 0:
		return true
	return false

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
		if slots[i] != {}:
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
		if slots[i] != {}:
			if slots[i].has("uuid") and item.has("uuid"):
				if slots[i]["uuid"] == item["uuid"]:
					return true
			
func has_item_type(item:String):
	for i in slots.keys():
		if slots[i] != {}:
			if slots[i]["type"] == item:
				return true

func get_item_slot(item:Dictionary):
	for i in slots.keys():
		if slots[i] != {}:
			if slots[i]["uuid"] == item["uuid"]:
				return slots[i]
			
func package_inventory():
	var dict : Dictionary = {
		self.uuid : slots.duplicate(true),
		"x" : self.width,
		"y" : self.height
		}
	return dict

#top level procs - general handling

func add_to_inventory(item : Dictionary, position :=""):
	if is_inventory_full():
		return false
	if position:
		if not can_place_in_slot(position, item):
			position = get_next_avaliable_slot()
			if not position:
				return false
	else:
		position = get_next_avaliable_slot()
	if item["stacklike"] && !item["unique"]:
		if get_free_slots() >= 2:
			pass
			#try_merge_stackables(item)
	slots[position] = item
	return true
	
func try_merge_stackables(item):
	var found_stack : Dictionary
	for i in slots.keys():
		if slots[i] == {}:
			continue
		var slot_item : Dictionary = slots[i]
		if slot_item["type"] == item["type"]: #like item found!
			found_stack = slot_item.duplicate(true)
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
	if not found_stack:
		slots[get_next_avaliable_slot()] = item
			
func merge_item_stack(item_one_pos, item_two_pos):
	var item_one : Dictionary = slots[item_one_pos]
	var item_two : Dictionary = slots[item_two_pos]
	if item_one == {}:
		return
	if item_two == {}:
		return
	if not item_one["type"] == item_two["type"]:
		return
	if item_two["amount"] == item_two["max_amount"]: #moving into item stack two
		return
	var merging : int = item_two["amount"] + item_one["amount"]
	if merging > item_two["max_amount"]:
		var can_accept : int = item_two["max_amount"] - item_two["amount"]
		item_one["amount"] -= can_accept
		item_two["amount"] += can_accept
	else:
		item_two["amount"] += item_one["amount"]
		delete_from_position_in_inv(item_one_pos)
			
func remove_from_inventory(position:String):
	if slots[position] != {}:
		var returning = slots[position].duplicate(true)
		slots[position].clear()
		return returning
		
func delete_from_position_in_inv(position:String):
	if slots[position] != {}:
		var returning = slots[position].duplicate(true)
		InventoryDataRepository.FreeUUID(slots[position]["uuid"])
		slots[position].clear()
		
func delete_from_inventory(item:Dictionary):
	for i in slots.keys():
		if slots[i]["uuid"] == item["uuid"]:
			InventoryDataRepository.FreeUUID(slots[i]["uuid"])
			slots[i].clear()
			break
	
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
	var new_slot = slots[new_position]
	if can_place_in_slot(new_position, slots[old_position]):
		slots[new_position] = slots[old_position].duplicate(true)
		slots[old_position] = {}
		return true
	return false
	
func swap_item_slots(pos_one:String, pos_two:String):
	var item_one : Dictionary = slots[pos_one].duplicate(true)
	var item_two : Dictionary = slots[pos_two].duplicate(true)
	slots[pos_two] = item_one.duplicate(true)
	slots[pos_one] = item_two.duplicate(true)
	
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
