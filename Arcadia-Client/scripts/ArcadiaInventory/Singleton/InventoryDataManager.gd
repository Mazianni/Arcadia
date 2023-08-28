class_name InventoryDataManager extends Node

var registered_uuids : Array
var registered_item_uuids : Dictionary
var registered_inventory_uuids : Dictionary
var registered_inventory_ui_uuids : Dictionary
var registered_ground_item_uuids : Dictionary
		
func GetInventoryByUUID(uuid:String):
	if uuid in registered_inventory_uuids.keys():
		return registered_inventory_uuids[uuid]
	
func GetItemByUUID(uuid:String):
	if uuid in registered_item_uuids.keys():
		return registered_item_uuids[uuid]
		
func GetUIByUUID(uuid:String):
	if uuid in registered_inventory_ui_uuids.keys():
		return registered_inventory_ui_uuids[uuid]
		
func GetGroundItemByUUID(uuid:String):
	if uuid in registered_ground_item_uuids.keys():
		return registered_ground_item_uuids[uuid]
		
func LookupTypelessUUID(uuid:String):
	if uuid in registered_ground_item_uuids.keys():
		return registered_ground_item_uuids[uuid]
	if uuid in registered_inventory_ui_uuids.keys():
		return registered_inventory_ui_uuids[uuid]
	if uuid in registered_item_uuids.keys():
		return registered_item_uuids[uuid]
	if uuid in registered_inventory_uuids.keys():
		return registered_inventory_uuids[uuid]
		
func PackageUUIDDictionaries():
	var return_dict : Dictionary = {
	"item_uuids" = registered_item_uuids.duplicate(true),
	"inventory_uuids" = registered_inventory_ui_uuids.duplicate(true),
	"ui_uuids" = registered_inventory_ui_uuids.duplicate(true),
	"ground_item_uuids" = registered_ground_item_uuids.duplicate(true)
	}
	return return_dict
	
func SyncUUIDDictionaries(dict : Dictionary):
	registered_item_uuids = dict["item_uuids"].duplicate(true)
	registered_inventory_ui_uuids = dict["inventory_uuids"].duplicate(true)
	registered_inventory_ui_uuids = dict["ui_uuids"].duplicate(true)
	registered_ground_item_uuids = dict["ground_item_uuids"].duplicate(true)
	
