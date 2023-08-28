class_name EquipmentInventory extends InventoryBase

func _init():
	
	if slots.size() == 0:
		slots = {
			"Head":{},
			"Torso":{},
			"Left Ring":{},
			"Right Ring":{},
			"Lower Body":{},
			"Shoes":{}
		}
		
	call_deferred("generate_uuid")
