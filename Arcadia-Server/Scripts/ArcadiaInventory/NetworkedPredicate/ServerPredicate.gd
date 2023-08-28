class_name ServerInventoryPredicate extends PredicateBase

@rpc("any_peer") func ClientPredicate_RecieveInventoryResponse(request_id : String, response : bool): pass
@rpc("any_peer") func ClientPredicate_RecieveUUIDSync(dict: Dictionary): pass
@rpc("any_peer") func ClientPredicate_RecieveItemSkeletons(dict: Dictionary): pass
@rpc("any_peer") func ClientPredicate_RecieveInventoryContentsSync(uuid:String): pass
@rpc("any_peer") func ClientPredicate_RecieveSelfInventoryUUIDs(dict : Dictionary): pass
@rpc("any_peer") func ClientPredicate_CloseUI(inv_id : String): pass

signal inventory_altered(inventory_id)

var open_inventories : Dictionary = {}

var request_pids : Dictionary = {}

func ServerPredicate_ValidateClientInventoryRequest(request_id : String, request_type : int, aux_parameters, player_id : int):
	if not ServerPredicate_ValidateRequestSanity(request_type, aux_parameters):
		return false
		
	var requester_user : PlayerContainer = DataRepository.PlayerMgmt.get_node(str(request_pids[request_id]))
	var requester_character : ActiveCharacter = requester_user.CurrentActiveCharacter
	var item : Dictionary
	var inventory_one: InventoryBase
	var inventory_two : InventoryBase
	var owning_node_one : Node2D
	var owning_node_two : Node2D 
	var ground_item : GroundItem
		
	match request_type:
				
		REQUESTTYPE.INVENTORY_DELETE:
			inventory_one = InventoryDataRepository.GetInventoryByUUID(aux_parameters["inv_one"])
			item = InventoryDataRepository.GetItemByUUID(aux_parameters["item"])
			#IMPL adding effects here
			if not item["consumable"]:
				return false
			if not inventory_one.has_item(item):
				return false
			inventory_one.delete_from_inventory(item)
			
		REQUESTTYPE.INVENTORY_MOVE:
			inventory_one = InventoryDataRepository.GetInventoryByUUID(aux_parameters["inv_one"])
			item = InventoryDataRepository.GetItemByUUID(aux_parameters["item"])
			if not inventory_one.has_item(item):
				return false
			if inventory_one.can_place_in_slot(aux_parameters["new_pos"], item):
				inventory_one.move_in_inventory(aux_parameters["old_pos"],aux_parameters["new_pos"])
				return true
			else:
				var item_two : Dictionary = inventory_one.slots[aux_parameters["new_pos"]]
				if item_two == {}:
					inventory_one.move_in_inventory(aux_parameters["old_pos"],aux_parameters["new_pos"])
					return true
				if item["stacklike"] && item_two["stacklike"]:
					if item["amount"] == item["max_amount"] or item_two["amount"] == item_two["max_amount"]:
						print("dsadf3354")
						inventory_one.swap_item_slots(aux_parameters["old_pos"], aux_parameters["new_pos"])
						return true
					if item["type"] == item_two["type"]:
						inventory_one.merge_item_stack(aux_parameters["old_pos"], aux_parameters["new_pos"])
						return true
				else:
					inventory_one.swap_item_slots(aux_parameters["old_pos"], aux_parameters["new_pos"])
					return true
					
		REQUESTTYPE.INVENTORY_TRANSFER:
			inventory_one = InventoryDataRepository.GetInventoryByUUID(aux_parameters["inv_one"])
			inventory_two = InventoryDataRepository.GetInventoryByUUID(aux_parameters["inv_two"])
			owning_node_one = inventory_one.owner
			owning_node_two = inventory_two.owner
			item = InventoryDataRepository.GetItemByUUID(aux_parameters["item"])
			#if not inventory_one.ethereal or not inventory_two.ethereal:
				#if not CheckDistanceBetweenNodes(owning_node_one, owning_node_two):
					#return true
			if not inventory_one.can_remove_item():
				return false
			if not inventory_one.has_item(item):
				return false
			if not inventory_one.can_remove_item_from_slot(aux_parameters["old_pos"]):
				return false
			if inventory_two.can_place_in_slot(aux_parameters["new_pos"], item):
				inventory_two.add_to_inventory(inventory_one.remove_from_inventory(aux_parameters["old_pos"]),aux_parameters["new_pos"])
				return true
				
		REQUESTTYPE.INVENTORY_DROP:
			inventory_one = requester_character.CharacterData.MainInventory
			item = InventoryDataRepository.GetItemByUUID(aux_parameters["item"])
			if not inventory_one.has_item(item):
				return false
			
		REQUESTTYPE.INVENTORY_PICKUP:
			if is_instance_valid(InventoryDataRepository.GetGroundItemByUUID(aux_parameters["ground_item"])):
				ground_item = InventoryDataRepository.GetGroundItemByUUID(aux_parameters["ground_item"])
			else:
				return false
			inventory_one = requester_character.CharacterData.MainInventory
			if not inventory_one.ethereal:
				if not CheckDistanceBetweenNodes(ground_item, requester_character.CurrentCollider):
					return false
			if not inventory_one.get_free_slots() > 0:
				return false
			item = ground_item.held_item.duplicate(true)
			DataRepository.Server.SendLocalChat(ChatHandler.FormatSimpleMessage("+++You've picked up "+str(item["amount"])+"x "+item["item_name"]+".+++"), null, player_id)
			requester_character.CharacterData.MainInventory.add_to_inventory(item)
			ground_item.queue_free()
			return true
			
		REQUESTTYPE.INVENTORY_OPEN:
			inventory_one = InventoryDataRepository.GetInventoryByUUID(aux_parameters["inv_one"])
			owning_node_one = inventory_one.owner
			return true
			if CheckDistanceBetweenNodes(owning_node_one, requester_character.CurrentCollider):
				return true
			else:
				ServerPredicate_RequestClientUIClose(player_id, aux_parameters["inv_one"])
				return false
			
		REQUESTTYPE.INVENTORY_CLOSE:
			inventory_one = InventoryDataRepository.GetInventoryByUUID(aux_parameters["inv_one"])
			return true
	
func ServerPredicate_ValidateRequestSanity(request_type : int, aux_parameters := {}):
	match request_type:
				
		REQUESTTYPE.INVENTORY_DELETE:
			if not aux_parameters.has("inv_one"):
				Logging.log_error("[SERVER INV PREDICATE] ServerPredicate failed to validate INVENTORYADD - Missing inv_one.")
				return false
			if not aux_parameters.has("item"):
				Logging.log_error("[SERVER INV PREDICATE] ServerPredicate failed to validate INVENTORYADD - Missing item.")
				return false
				
		REQUESTTYPE.INVENTORY_MOVE:
			if not aux_parameters.has("inv_one"):
				Logging.log_error("[SERVER INV PREDICATE] ServerPredicate failed to validate INVENTORYADD - Missing inv_one.")
				return false
			if not aux_parameters.has("old_pos"):
				Logging.log_error("[SERVER INV PREDICATE] ServerPredicate failed to validate INVENTORYADD - Missing old_pos.")
				return false
			if not aux_parameters.has("new_pos"):
				Logging.log_error("[SERVER INV PREDICATE] ServerPredicate failed to validate INVENTORYADD - Missing new_pos.")
				return false

		REQUESTTYPE.INVENTORY_TRANSFER:
			if not aux_parameters.has("inv_one"):
				Logging.log_error("[SERVER INV PREDICATE] ServerPredicate failed to validate INVENTORYADD - Missing inv_one.")
				return false
			if not aux_parameters.has("inv_two"):
				Logging.log_error("[SERVER INV PREDICATE] ServerPredicate failed to validate INVENTORYADD - Missing inv_two.")
				return false
			if not aux_parameters.has("item"):
				Logging.log_error("[SERVER INV PREDICATE] ServerPredicate failed to validate INVENTORYADD - Missing item.")
				return false

		REQUESTTYPE.INVENTORY_DROP:
			if not aux_parameters.has("item"):
				Logging.log_error("[SERVER INV PREDICATE] ServerPredicate failed to validate INVENTORYDROP - Missing item.")
				return false
			
		REQUESTTYPE.INVENTORY_PICKUP:
			if not aux_parameters.has("ground_item"):
				Logging.log_error("[SERVER INV PREDICATE] ServerPredicate to validate INVENTORYDROP - Missing ground_item.")
				return false
			
		REQUESTTYPE.INVENTORY_OPEN:
			if not aux_parameters.has("inv_one"):
				Logging.log_error("[SERVER INV PREDICATE] ServerPredicate failed to validate INVENTORYOPEN - Missing inv_one.")
				return false
			
		REQUESTTYPE.INVENTORY_CLOSE:
			if not aux_parameters.has("inv_one"):
				Logging.log_error("[SERVER INV PREDICATE] ServerPredicate failed to validate INVENTORYCLOSE - Missing inv_one.")
				return false
				
	return true
	
func CheckDistanceBetweenNodes(nodeone : Node2D, nodetwo: Node2D):
	var node_one_pos : Vector2 = nodeone.get_global_position()
	var node_two_pos : Vector2 = nodetwo.get_global_position()
	var distance : float = node_one_pos.distance_to(node_two_pos)
	if distance >= DataRepository.max_distance_inv_interact:
		return false
	if nodeone.CurrentMap and nodetwo.CurrentMap:
		if nodeone.CurrentMap != nodetwo.CurrentMap:
			return false
	return true
	
func ServerPredicate_RequestClientUIClose(pid : int, inv_id: String):
	rpc_id(pid, "ClientPredicate_CloseUI", inv_id)
	
@rpc("any_peer") func ServerPredicate_RecieveInventoryRequest(request_id : String, request_type : int, aux_parameters):
	request_pids[request_id] = multiplayer.get_remote_sender_id()
	if ServerPredicate_ValidateClientInventoryRequest(request_id, request_type, aux_parameters, multiplayer.get_remote_sender_id()):
		rpc_id(request_pids[request_id], "ClientPredicate_RecieveInventoryResponse", request_id, true)
		return
	rpc_id(request_pids[request_id], "ClientPredicate_RecieveInventoryResponse", request_id, false)

@rpc("any_peer") func ServerPredicate_RecieveUUIDSyncRequest():
	var pid : int = multiplayer.get_remote_sender_id()
	rpc_id(pid, "ClientPredicate_RecieveUUIDSync", InventoryDataRepository.PackageUUIDDictionaries())

@rpc("any_peer") func ServerPredicate_SyncItemSkeletons():
	var pid : int  = multiplayer.get_remote_sender_id()
	rpc_id(pid, "ClientPredicate_RecieveItemSkeletons", ItemSkeletonRepository.item_skeletons.duplicate(true))

@rpc("any_peer") func ServerPredicate_SyncInventoryContents(uuid:String):
	var pid : int  = multiplayer.get_remote_sender_id()
	var return_inv : InventoryBase = InventoryDataRepository.GetInventoryByUUID(uuid)
	print(uuid)
	rpc_id(pid, "ClientPredicate_RecieveInventoryContentsSync", uuid, return_inv.package_inventory())

@rpc("any_peer") func ServerPredicate_RequestSelfInventoryUUIDs():
	var pid : int  = multiplayer.get_remote_sender_id()
	var Player : PlayerContainer = DataRepository.PlayerMgmt.get_node(str(pid))
	var PCharacter : ActiveCharacter = Player.CurrentActiveCharacter
	var return_dict : Dictionary = {
		"main": PCharacter.CharacterData.MainInventory.uuid,
		"equip": PCharacter.CharacterData.EquipmentInventory.uuid,
		"coin": PCharacter.CharacterData.CoinInventory.uuid
	}
	rpc_id(pid, "ClientPredicate_RecieveSelfInventoryUUIDs", return_dict)
	
