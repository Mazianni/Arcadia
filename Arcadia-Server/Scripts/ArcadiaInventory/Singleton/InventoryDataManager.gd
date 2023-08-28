class_name InventoryDataManager extends Node

var registered_uuids : Array
var registered_item_uuids : Dictionary
var registered_inventory_uuids : Dictionary
var registered_inventory_ui_uuids : Dictionary
var registered_ground_item_uuids : Dictionary

func GenerateUUID(resource):
	var gen_uuid = DataRepository.uuid_generator.v4()
	while not VerifyUUIDIsUnique(gen_uuid):
		gen_uuid = DataRepository.uuid_generator.v4()
	if resource is Dictionary:
		registered_item_uuids[gen_uuid] = resource
	if resource is InventoryBase:
		registered_inventory_uuids[gen_uuid] = resource
	if resource is InventoryUI:
		registered_inventory_ui_uuids[gen_uuid] = resource
	if resource is GroundItem:
		registered_ground_item_uuids[gen_uuid] = resource
	registered_uuids.append(gen_uuid)
	return gen_uuid
	
func RegisterExistingUUID(uuid:String, resource):
	if resource is Dictionary:
		registered_item_uuids[uuid] = resource
	if resource is InventoryBase:
		registered_inventory_uuids[uuid] = resource
	if resource is InventoryUI:
		registered_inventory_ui_uuids[uuid] = resource
	if resource is GroundItem:
		registered_ground_item_uuids[uuid] = resource
	registered_uuids.append(uuid)
	
func VerifyUUIDIsUnique(uuid:String):
	if uuid in registered_uuids:
		return false
	return true
	
func FreeUUID(uuid:String):
	registered_uuids.erase(uuid)
	if uuid in registered_item_uuids.keys():
		registered_item_uuids.erase(uuid)
	if uuid in registered_inventory_uuids.keys():
		registered_inventory_uuids.erase(uuid)
	if uuid in registered_ground_item_uuids.keys():
		registered_ground_item_uuids.erase(uuid)
	if uuid in registered_inventory_ui_uuids.keys():
		registered_inventory_ui_uuids.erase(uuid)
		
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
	
