class_name ItemGrabber extends Sprite2D

var grabbed_item : Dictionary
var slot_grabbed_from : UIRenderSlot

signal item_released(item)
signal item_released_no_slot()

func _process(delta):
	position = get_global_mouse_position()
	if Input.is_action_just_released("click") && grabbed_item != {}:
		release_item()
	
func grab_item(item:Dictionary, slot : UIRenderSlot):
	if grabbed_item == {}:
		texture = load(item["texture"])
		grabbed_item = item.duplicate(true)
		slot_grabbed_from = slot
	
func release_item():
	var releasing_slot : UIRenderSlot = InventoryPredicate.last_slot_entered
	var aux_dict : Dictionary
	if not releasing_slot or releasing_slot == slot_grabbed_from:
		slot_grabbed_from.accept_item(grabbed_item)
	else:
		if releasing_slot.holding_ui.inv_id != slot_grabbed_from.holding_ui.inv_id: #this is a transfer
			aux_dict = {
				"inv_one": slot_grabbed_from.holding_ui.inv_id,
				"old_pos": slot_grabbed_from.location,
				"inv_two": releasing_slot.holding_ui.inv_id,
				"new_pos": releasing_slot.location,
				"item": grabbed_item["uuid"],
				"origin_ui": slot_grabbed_from.holding_ui.inv_id
			}		
			InventoryPredicate.ClientPredicate_GenerateInventoryRequest(PredicateBase.REQUESTTYPE.INVENTORY_TRANSFER, aux_dict)
		else: #this is a slot move, not a transfer.

			aux_dict = {
				"inv_one": releasing_slot.holding_ui.inv_id,
				"item": grabbed_item["uuid"],
				"new_pos": releasing_slot.location,
				"old_pos": slot_grabbed_from.location,
				"origin_ui": slot_grabbed_from.holding_ui.inv_id
			}
			InventoryPredicate.ClientPredicate_GenerateInventoryRequest(PredicateBase.REQUESTTYPE.INVENTORY_MOVE, aux_dict)
	texture = null
	grabbed_item = {}

