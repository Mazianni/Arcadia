class_name EquipmentInventory extends InventoryBase

var slot_requirements_dict : Dictionary = {
	"Hat":[ItemSkeletonRepository.ITEM_EQUIPMENT_FLAGS.FLAG_HAT],
	"Shirt":[ItemSkeletonRepository.ITEM_EQUIPMENT_FLAGS.FLAG_SHIRT],
	"Left Ring":[ItemSkeletonRepository.ITEM_EQUIPMENT_FLAGS.FLAG_RING],
	"Right Ring":[ItemSkeletonRepository.ITEM_EQUIPMENT_FLAGS.FLAG_RING],
	"Pants":[ItemSkeletonRepository.ITEM_EQUIPMENT_FLAGS.FLAG_PANTS],
	"Shoes":[ItemSkeletonRepository.ITEM_EQUIPMENT_FLAGS.FLAG_SHOES],
	"Helmet":[ItemSkeletonRepository.ITEM_EQUIPMENT_FLAGS.FLAG_HELMET],
	"Chestpiece":[ItemSkeletonRepository.ITEM_EQUIPMENT_FLAGS.FLAG_CHESTPIECE],
	"Greaves":[ItemSkeletonRepository.ITEM_EQUIPMENT_FLAGS.FLAG_GREAVES],
	"Boots":[ItemSkeletonRepository.ITEM_EQUIPMENT_FLAGS.FLAG_SHOES]
}

func _init():
	
	if slots.size() == 0:
		slots = {
			"Hat":{},
			"Shirt":{},
			"Left Ring":{},
			"Right Ring":{},
			"Pants":{},
			"Shoes":{},
			"Helmet":{},
			"Chestpiece":{},
			"Greaves":{},
			"Boots":{}
		}
		
	call_deferred("generate_uuid")
	
func can_place_in_slot(position:String, item:Dictionary):
	if item.has("equip_flag"):
		if item["equip_flag"] == slot_requirements_dict[position]:
			if slots[position].size() == 0:
				return true
	else:
		return false
