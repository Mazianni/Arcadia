class_name UIRenderSlot extends Control

@onready var InvTexture : TextureRect = $PanelContainer/TextureRect
@onready var amtlabel : Label = $MarginContainer/Label
@onready var previewresource = preload("res://scripts/ArcadiaInventory/UI/Scenes/GrabbedPreview.tscn")

var location : String
var held_item : Dictionary = {}
var holding_ui : InventoryUI

func _make_custom_tooltip(for_text):
	var tooltip_res = preload("res://scripts/ArcadiaInventory/UI/Scenes/ItemToolTip.tscn")
	var tooltip_scene = tooltip_res.instantiate()
	if held_item == {}:
		return
	tooltip_scene.item = held_item.duplicate(true)
	tooltip_scene.DrawTooltip()
	return tooltip_scene

func UpdateAppearance():
	if held_item == {}:
		InvTexture.texture = null
		amtlabel.hide()
		return
	InvTexture.texture = load(held_item["texture"])
	if held_item.has("stacklike"):
		if held_item["stacklike"]:
			amtlabel.show()
			amtlabel.text = "x"+str(held_item["amount"])
		else:
			amtlabel.hide()
			
func accept_item(item):
	held_item = item.duplicate(true)
	UpdateAppearance()
	
func clear_slot():
	held_item = {}
	UpdateAppearance()
	
func _can_drop_data(at_position, data):
	return typeof(data) == TYPE_DICTIONARY
	
func _drop_data(at_position, data):
	var releasing_slot : UIRenderSlot = self
	var slot_grabbed_from : UIRenderSlot = data["origin_slot"]
	var aux_dict : Dictionary = {}
	if not releasing_slot or releasing_slot == slot_grabbed_from:
		return
	else:
		slot_grabbed_from.clear_slot()
		if releasing_slot.holding_ui.inv_id != slot_grabbed_from.holding_ui.inv_id: #this is a transfer
			aux_dict = {
				"inv_one": slot_grabbed_from.holding_ui.inv_id,
				"old_pos": slot_grabbed_from.location,
				"inv_two": releasing_slot.holding_ui.inv_id,
				"new_pos": releasing_slot.location,
				"item": data["item"]["uuid"],
				"origin_ui": slot_grabbed_from.holding_ui.inv_id
			}		
			InventoryPredicate.ClientPredicate_GenerateInventoryRequest(PredicateBase.REQUESTTYPE.INVENTORY_TRANSFER, aux_dict)
		else: #this is a slot move, not a transfer.
			aux_dict = {
				"inv_one": releasing_slot.holding_ui.inv_id,
				"item": data["item"]["uuid"],
				"new_pos": releasing_slot.location,
				"old_pos": slot_grabbed_from.location,
				"origin_ui": slot_grabbed_from.holding_ui.inv_id
			}
			InventoryPredicate.ClientPredicate_GenerateInventoryRequest(PredicateBase.REQUESTTYPE.INVENTORY_MOVE, aux_dict)

func _get_drag_data(at_position):
	var node : Dictionary = {
		"origin_slot": self,
		"item": held_item.duplicate(true)
	}
	set_drag_preview(make_preview(held_item.duplicate(true)))
	held_item = {}
	UpdateAppearance()
	return node
	
func make_preview(item:Dictionary):
	var preview : TextureRect = previewresource.instantiate()
	if item.has("texture"):
		preview.texture = load(item["texture"])
	return preview
