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
		"consumable":false,
		"holder":"",
		"item_flags":[],
		"description":"",
		"rarity":ITEM_RARITY_FLAGS.ITEM_NORMAL
	}

var item_skeletons : Dictionary = {
	"Base/Wood" :{
		"type": "Base/Wood",
		"stacklike": true,
		"item_name":"Wood",
		"texture": "res://sprites/items/wood.png",
		"description":"Wooden't you like to know.",
		"item_flags":[ITEM_CLASS_FLAGS.FLAG_RESOURCE, ITEM_CLASS_FLAGS.FLAG_FUEL]
	},
	"Base/Wood/Wood2" :{
		"abstract_type":"Base/Wood",
		"type": "Base/Wood/Wood2",
		"stacklike": true,
		"item_name":"Wood",
		"texture": "res://sprites/items/wood2.png"
	}
}

func GenerateItemFromSubtype(subtype : Dictionary): #uuidless - used for typing
	var return_dict : Dictionary = base_item_skeleton.duplicate(true)
	var abstract_types : Array = []
	
	if subtype.has("abstract_type"):
		var abstract_dict : Dictionary = item_skeletons[subtype["abstract_type"]]
		while abstract_dict != {}:
			abstract_types.append(item_skeletons[subtype["abstract_type"]])
			if item_skeletons.has(item_skeletons[subtype["abstract_type"]]):
				abstract_dict = item_skeletons[subtype["abstract_type"]]["abstract_type"]
			else:
				break
		
	for i in abstract_types:
		return_dict.merge(item_skeletons[i], true)
			
	if subtype.has("uuid"):
		subtype.erase("uuid")
		Logging.log_error("[ITEM SKELETON REP] UUID assigned in item prototype "+subtype["type"]+"!")
	
	return_dict.merge(subtype, true)
	return return_dict

func InstanceItemFromSubtype(subtype : Dictionary): #instantiate a new item structure.
	var return_dict : Dictionary = base_item_skeleton.duplicate(true)
	var abstract_types : Array = []
	
	if subtype.has("abstract_type"):
		var abstract_dict : Dictionary = item_skeletons[subtype["abstract_type"]]
		abstract_types.append(subtype["abstract_type"])
		while abstract_dict != {}:
			if item_skeletons.has(item_skeletons[subtype["abstract_type"]]):
				abstract_dict = item_skeletons[abstract_dict["abstract_type"]]
			else:
				break
		
	for i in abstract_types:
		return_dict.merge(item_skeletons[i], true)
			
	if subtype.has("uuid"):
		subtype.erase("uuid")
		Logging.log_error("[ITEM SKELETON REP] UUID assigned in item prototype "+subtype["type"]+"!")
	
	return_dict.merge(subtype, true)
	return_dict["uuid"] = InventoryDataRepository.GenerateUUID(return_dict)
	return return_dict
	
