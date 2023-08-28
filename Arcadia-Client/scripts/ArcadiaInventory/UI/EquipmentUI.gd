class_name EquipmentUI extends InventoryUI

@onready var clothes_inv = $TabContainer/Clothes/ClothingGrid
@onready var armor_inv = $TabContainer/Armor/ArmorGrid

func _ready():
	inv_id = Globals.inventory_uuids["equip"]
	InventoryPredicate.inventory_recieved.connect(Callable(self, "CheckInventoryUpdate"))
	InventoryPredicate.ClientPredicate_RequestInventoryContents(inv_id)
	InventoryPredicate.inventory_changed.connect(Callable(self, "UpdateInventory"))
	for i in GetCombinedNodes():
		if not i.get_class() == "MarginContainer":
			continue
		var RenderNode : UIRenderSlot = i
		if not RenderNode:
			continue
		RenderNode.location = RenderNode.name
		RenderNode.holding_ui = self
	
func RenderInventory():
	for i in held_contents[inv_id].keys():
		var RenderNode : UIRenderSlot
		if clothes_inv.has_node(i):
			RenderNode = clothes_inv.get_node(i)
		if armor_inv.has_node(i):
			RenderNode = armor_inv.get_node(i)
		if not RenderNode:
			return
		RenderNode.held_item = held_contents[inv_id][i].duplicate(true)
		RenderNode.UpdateAppearance()
		
func GetCombinedNodes():
	var combined_nodes : Array
	for i in clothes_inv.get_children():
		combined_nodes.append(i)
	for i in armor_inv.get_children():
		combined_nodes.append(i)
	return combined_nodes
