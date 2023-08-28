class_name ServerCombatHandlerSingleton extends Node

@rpc("any_peer") func ClientCombatHandler_RecieveResources(dict : Dictionary): pass
@rpc("any_peer") func ClientCombatHandler_RecieveSelfSpells(spells:Array): pass
@rpc("any_peer") func ClientCombatHandler_RecieveSpellTrees(trees:Dictionary): pass
@rpc("any_peer") func ClientCombatHandler_RecieveSpellPurchaseResult(result:bool): pass

var ActiveRPBs : Array = []
var ActiveParties : Dictionary = {}

#TODO consider making this a push only and not a request-push system
@rpc("any_peer") func ServerCombatHandler_RecieveResourceRequest(array : Array):
	var return_dict : Dictionary = {}
	var pid : int = multiplayer.get_remote_sender_id()
	for i in array:
		var AC : ActiveCharacter
		for c in get_tree().get_nodes_in_group("active_characters"):
			if c.name == i:
				AC = c
		return_dict[i] = {
			"HP": {
				"value":AC.health,
				"max_value":AC.max_health,
				"regen":AC.health_regen,
			},
			"MP":{
				"value":AC.mana,
				"max_value":AC.max_mana,
				"regen":AC.mana_regen
			}
		}
	rpc_id(pid, "ClientCombatHandler_RecieveResources", return_dict)

@rpc("any_peer") func ServerCombatHandler_RecieveSpellsRequest():
	var pid : int = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(pid)):
		var playernode : PlayerContainer = DataRepository.PlayerMgmt.get_node(str(pid))
		var character : ActiveCharacter = playernode.CurrentActiveCharacter
		rpc_id(pid, "ClientCombatHandler_RecieveSelfSpells", character.unlocked_abilities.duplicate(true))
	
@rpc("any_peer") func ServerCombatHandler_RecieveTreesRequest():
	var pid : int = multiplayer.get_remote_sender_id()
	rpc_id(pid, "ClientCombatHandler_RecieveSpellTrees", AbilityHolder.ability_dictionary.duplicate(true))

@rpc("any_peer") func ServerCombatHandler_HandleSpellPurchaseRequest(spell:String):
	pass
	
@rpc("any_peer") func ServerCombatHandler_HandleAbilityActivateRequest(ability:String):
	pass
