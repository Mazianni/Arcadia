class_name InventoryUI extends Control

var rendered_inventory : InventoryBase
var id : String

func _ready():
	id = InventoryDataRepository.GenerateUUID(self)

func OpenInventory(inventory_uuid : String):
	rendered_inventory = InventoryDataRepository.GetInventoryByUUID(inventory_uuid)
	rendered_inventory.register_ui(id)
	pass
	
func Close():
	rendered_inventory.unregister_ui(id)
	rendered_inventory = null
	queue_free()
