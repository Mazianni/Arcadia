extends Window

@onready var MainInventoryView : InventoryView = $MainInventory

func _ready():
	if InventoryManager.inventories_instanced:
		MainInventoryView.inventory = InventoryManager.CharacterInventory
		Server.RequestInventorySync()
	else:
		InventoryManager.InstantiatePlayerInventories()
		MainInventoryView.inventory = InventoryManager.CharacterInventory
		Server.RequestInventorySync()

func _on_close_requested():
	hide()

