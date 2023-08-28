class_name ClientCombatHandlerSingleton extends Node

@rpc("any_peer") func ServerCombatHandler_RecieveResourceRequest(array : Array): pass
@rpc("any_peer") func ServerCombatHandler_RecieveSpellsRequest(): pass
@rpc("any_peer") func ServerCombatHandler_RecieveTreesRequest(): pass
@rpc("any_peer") func ServerCombatHandler_HandleSpellPurchaseRequest(spell:String): pass
@rpc("any_peer") func ServerCombatHandler_HandleAbilityActivateRequest(ability:String): pass

signal resources_recieved(resource_dict)
signal spells_recieved(array)
signal trees_recieved(dict)

func _process(delta):
	if Globals.client_state == Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		ClientCombatHandler_RequestResources([Globals.character_uuid])

func ClientCombatHandler_RequestResources(array : Array): #accepts an array of uuids to get resources for
	rpc_id(1, "ServerCombatHandler_RecieveResourceRequest", array)
	
func ClientCombatHandler_RequestSelfSpells():
	rpc_id(1, "ServerCombatHandler_RecieveSpellsRequest")
	
func ClientCombatHandler_RequestSpellTrees():
	rpc_id(1, "ServerCombatHandler_RecieveTreesRequest")
	
func ClientCombatHandler_RequestSpellPurchase(spell_name:String):
	rpc_id(1, "ServerCombatHandler_HandleSpellPurchaseRequest", spell_name)
	
func ClientCombatHandler_RequestAbilityActivate(ability:String):
	rpc_id(1, "ServerCombatHandler_HandleAbilityActivateRequest", ability)
	
@rpc("any_peer") func ClientCombatHandler_RecieveSpellPurchaseResult(result:bool):
	pass
	
@rpc("any_peer") func ClientCombatHandler_RecieveSelfSpells(spells:Array):
	spells_recieved.emit(spells)
	Globals.known_spells = spells.duplicate(true)
	
@rpc("any_peer") func ClientCombatHandler_RecieveSpellTrees(trees:Dictionary):
	trees_recieved.emit(trees)
	Globals.ability_trees = trees.duplicate(true)
	
@rpc("any_peer") func ClientCombatHandler_RecieveResources(dict : Dictionary):
	resources_recieved.emit(dict)
