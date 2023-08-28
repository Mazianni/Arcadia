class_name ClientInventoryPredicate extends PredicateBase

@rpc("any_peer") func ServerPredicate_RecieveInventoryRequest(request_id : String, request_type : int, aux_parameters): pass
@rpc("any_peer") func ServerPredicate_RecieveUUIDSyncRequest(uuid : String): pass
@rpc("any_peer") func ServerPredicate_SyncItemSkeletons(): pass
@rpc("any_peer") func ServerPredicate_SyncInventoryContents(uuid:String): pass
@rpc("any_peer") func ServerPredicate_RequestSelfInventoryUUIDs(): pass

signal item_picked_up
signal item_dropped
signal inventory_opened
signal inventory_closed
signal inventory_recieved(inventory_uuid, inventory_dict)
signal self_inventory_recieved(inventory_dict)
signal inventory_changed

var requests_awaiting_response : Dictionary = {} 

var open_uis : Dictionary = {}

func ClientPredicate_GenerateInventoryRequest(request_type : int, aux_parameters := {}):
	var request_uuid = Globals.uuid_generator.v4()
	if ClientPredicate_ValidateRequest(request_type, aux_parameters):
		requests_awaiting_response[request_uuid] = {"type":request_type,"aux":aux_parameters}
		ClientPredicate_SendInventoryRequest(request_uuid,request_type, aux_parameters)
	else:
		push_error("ClientPredicate failed to validate request!")
	
func ClientPredicate_ValidateRequest(request_type : int, aux_parameters := {}):
	match request_type:
				
		REQUESTTYPE.INVENTORY_DELETE:
			if not aux_parameters.has("inv_one"):
				push_error("ClientPredicate failed to validate INVENTORYADD - Missing inv_one.")
				return false
			if not aux_parameters.has("item"):
				push_error("ClientPredicate failed to validate INVENTORYADD - Missing item.")
				return false
				
		REQUESTTYPE.INVENTORY_MOVE:
			if not aux_parameters.has("inv_one"):
				push_error("ClientPredicate failed to validate INVENTORYADD - Missing inv_one.")
				return false
			if not aux_parameters.has("old_pos"):
				push_error("ClientPredicate failed to validate INVENTORYADD - Missing old_pos.")
				return false
			if not aux_parameters.has("new_pos"):
				push_error("ClientPredicate failed to validate INVENTORYADD - Missing new_pos.")
				return false

		REQUESTTYPE.INVENTORY_TRANSFER:
			if not aux_parameters.has("inv_one"):
				push_error("ClientPredicate failed to validate INVENTORYADD - Missing inv_one.")
				return false
			if not aux_parameters.has("inv_two"):
				push_error("ClientPredicate failed to validate INVENTORYADD - Missing inv_two.")
				return false
			if not aux_parameters.has("item"):
				push_error("ClientPredicate failed to validate INVENTORYADD - Missing item.")
				return false

		REQUESTTYPE.INVENTORY_DROP:
			if not aux_parameters.has("item"):
				push_error("ClientPredicate failed to validate INVENTORYDROP - Missing item.")
				return false
			
		REQUESTTYPE.INVENTORY_PICKUP:
			if not aux_parameters.has("ground_item"):
				push_error("ClientPredicate failed to validate INVENTORYDROP - Missing item.")
				return false
			
		REQUESTTYPE.INVENTORY_OPEN:
			if not aux_parameters.has("inv_one"):
				push_error("ClientPredicate failed to validate INVENTORYOPEN - Missing inv_one.")
				return false
			
		REQUESTTYPE.INVENTORY_CLOSE:
			if not aux_parameters.has("inv_one"):
				push_error("ClientPredicate failed to validate INVENTORYCLOSE - Missing inv_one.")
				return false
				
	return true

func ClientPredicate_ResolveInventoryRequest(request_id : String, response: bool):
	var inventory_one : InventoryBase
	var inventory_two : InventoryBase
	var item : Dictionary
	var ground_item : GroundItem
	
	if response == false:
		match requests_awaiting_response[request_id]["type"]:
			REQUESTTYPE.INVENTORY_TRANSFER:
				
				ClientPredicate_RequestInventoryContents(requests_awaiting_response[request_id]["aux"]["origin_ui"])
		requests_awaiting_response.erase(request_id)
		return

	match requests_awaiting_response[request_id]["type"]:			
		REQUESTTYPE.INVENTORY_DELETE:
			pass
			
		REQUESTTYPE.INVENTORY_MOVE:
			pass
			
		REQUESTTYPE.INVENTORY_TRANSFER:
			pass
			
		REQUESTTYPE.INVENTORY_DROP:
			pass
			
		REQUESTTYPE.INVENTORY_PICKUP:
			ground_item = Server.maphandler.current_map_reference.GetGroundItem(requests_awaiting_response[request_id]["aux"]["ground_item"])
			if ground_item && is_instance_valid(ground_item):
				ground_item.queue_free()
			item_picked_up.emit()
			
		REQUESTTYPE.INVENTORY_OPEN:
			inventory_opened.emit()
			if Globals.client_state == Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
				Gui.current_loaded_GUI.CreateOtherInventoryWindow(requests_awaiting_response[request_id]["aux"]["inv_one"])
			
		REQUESTTYPE.INVENTORY_CLOSE:
			inventory_closed.emit()
			
	requests_awaiting_response.erase(request_id)
	inventory_changed.emit()

func ClientPredicate_SendInventoryRequest(request_id : String, request_type : int, aux_parameters):
	rpc_id(1, "ServerPredicate_RecieveInventoryRequest", request_id, request_type, aux_parameters)
	
func ClientPredicate_GenerateUUIDSyncRequest():
	rpc_id(1, "ServerPredicate_RecieveUUIDSyncRequest")
	
func ClientPredicate_RequestItemSkeletons():
	rpc_id(1, "ServerPredicate_SyncItemSkeletons")
	
func ClientPredicate_RequestInventoryContents(uuid:String):
	rpc_id(1, "ServerPredicate_SyncInventoryContents", uuid)
	
func ClientPredicate_RequestSelfInventoryUUIDs():
	rpc_id(1, "ServerPredicate_RequestSelfInventoryUUIDs")

@rpc("any_peer") func ClientPredicate_RecieveInventoryResponse(request_id : String, response : bool):
	ClientPredicate_ResolveInventoryRequest(request_id, response)

@rpc("any_peer") func ClientPredicate_RecieveUUIDSync(dict: Dictionary):
	InventoryDataRepository.SyncUUIDDictionaries(dict)
	
@rpc("any_peer") func ClientPredicate_RecieveItemSkeletons(dict: Dictionary):
	ItemSkeletonRepository.item_skeletons.merge(dict, true)
	
@rpc("any_peer") func ClientPredicate_RecieveInventoryContentsSync(uuid:String, dict : Dictionary):
	var inv : InventoryBase = InventoryDataRepository.GetInventoryByUUID(uuid)
	inventory_recieved.emit(uuid, dict)
	
@rpc("any_peer") func ClientPredicate_RecieveSelfInventoryUUIDs(dict : Dictionary):
	Globals.inventory_uuids = dict.duplicate(true)
	
@rpc("any_peer") func ClientPredicate_CloseUI(inv_id : String):
	var inv_uis = get_tree().get_nodes_in_group("inv_uis")
	for i in inv_uis:
		var node : InventoryUI = i
		if node.inv_id == inv_id:
			node.close()
	
	
