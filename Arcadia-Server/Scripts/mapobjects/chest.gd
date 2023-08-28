extends MapObject

var inventory : InventoryBase
var associated_id : String

func _ready():
	super()
	type = "Chest"
	if not inventory:
		inventory = InventoryBase.new()
		inventory.width = 5
		inventory.height = 4
		inventory._init()
	await get_tree().create_timer(1).timeout
	associated_id = inventory.uuid
	inventory.owner = self
	
func GetMapObjectSubData():
	var dict : Dictionary = {
		"chest_id": associated_id
	}
	return dict
