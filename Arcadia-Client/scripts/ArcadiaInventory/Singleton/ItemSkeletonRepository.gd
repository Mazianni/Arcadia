extends Node

enum ITEM_RARITY_FLAGS{
	ITEM_NORMAL,
	ITEM_ATYPICAL,
	ITEM_RARE,
	ITEM_DIVINE,
	ITEM_PRIMORDIAL
}

enum ITEM_CLASS_FLAGS{
	FLAG_RESOURCE,
	FLAG_FUEL,
	FLAG_EQUIPMENT
}

enum ITEM_EQUIPMENT_FLAGS{
	FLAG_HELMET,
	FLAG_CHESTPIECE,
	FLAG_GREAVES,
	FLAG_RING,
	FLAG_WEAPON,
	FLAG_OFFHAND_WEAPON,
	FLAG_HAT,
	FLAG_SHIRT,
	FLAG_PANTS,
	FLAG_SHOES,
	FLAG_CHARM
}

var base_item_skeleton : Dictionary = {
		"uuid": "", #Do not fill.
		"abstract_type":"",
		"type":"Base",
		"texture": "",
		"item_name": "",
		"categories": "",
		"stacklike":false,
		"amount":1,
		"max_amount":60,
		"unique":false,
		"consumable":false
	}

var item_skeletons : Dictionary = {

}
	
