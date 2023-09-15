class_name ClientCombatHandlerSingleton extends Node

@onready var dmgpopupres = load("res://scenes/DmgPopup/DmgPopup.tscn")

@rpc("any_peer") func ServerCombatHandler_RecieveResourceRequest(array : Array): pass
@rpc("any_peer") func ServerCombatHandler_RecieveSpellsRequest(): pass
@rpc("any_peer") func ServerCombatHandler_RecieveTreesRequest(): pass
@rpc("any_peer") func ServerCombatHandler_HandleSpellPurchaseRequest(spell:String): pass
@rpc("any_peer") func ServerCombatHandler_HandleAbilityActivateRequest(ability:String): pass
@rpc("any_peer") func ServerCombatHandler_RecieveSelectedPlayerUpdate(player:String): pass
@rpc("any_peer") func ServerCombatHandler_RecieveEffectRequest(array:Array): pass
@rpc("any_peer") func ServerCombatHandler_UpdateClientHotbar(hotbar:Dictionary): pass
	
signal resources_recieved(resource_dict)
signal spells_recieved(array)
signal trees_recieved(dict)

var current_effects : Dictionary = {}
var hotbar : Node

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
	
func ClientCombatHandler_RequestAbilityActivate(slot:String, ability:String):
	rpc_id(1, "ServerCombatHandler_HandleAbilityActivateRequest", slot, ability)
	
func ClientCombatHandler_UpdateSelectedPlayer(player):
	rpc_id(1, "ServerCombatHandler_RecieveSelectedPlayerUpdate", player)
	
func ClientCombatHandler_RequestEffects(array : Array):
	rpc_id(1, "ServerCombatHandler_RecieveEffectRequest", array)
	
@rpc("authority") func ClientCombatHandler_RecieveSpellPurchaseResult(spell:String, result:bool):
	if result == false:
		return
	for i in get_tree().get_nodes_in_group("spells"):
		if i.name == spell:
			i.unlocked = true
			i.UpdateUnlocked()
	
@rpc("authority") func ClientCombatHandler_RecieveSelfSpells(spells:Array):
	spells_recieved.emit(spells)
	Globals.known_spells = spells.duplicate(true)
	
@rpc("authority") func ClientCombatHandler_RecieveSpellTrees(trees:Dictionary):
	trees_recieved.emit(trees)
	Globals.ability_trees = trees.duplicate(true)
	
@rpc("authority") func ClientCombatHandler_RecieveResources(dict : Dictionary):
	resources_recieved.emit(dict)
	
@rpc("authority") func ClientCombatHandler_RecieveAbilityActivateResult(slot, result, time):
	if result:
		var slots = get_tree().get_nodes_in_group("hotbar_slots")
		for i in slots:
			if i.bound_action == slot:
				i.SetTimer(time)
				
@rpc("authority") func ClientCombatHandler_RecieveEffects(effects:Dictionary):
	for p in effects.keys():
		var player
		for i in get_tree().get_nodes_in_group("players"):
			if i.name == p:
				player = p
		player.effects = effects[p].duplicate(true)
		player.UpdateEffects()
		
@rpc("authority") func ClientCombatHandler_CreateDmgPopup(player:String, amount:int, type:String):
	var dmg_node
	for i in get_tree().get_nodes_in_group("players"):
		if i.name == player:
			dmg_node = i
	var popup = dmgpopupres.instantiate()
	popup.position = dmg_node.get_global_position()
	popup.position.x -= popup.size.x/2
	Server.maphandler.current_map_reference.add_child(popup)

	popup.RenderPopup(amount, type)
	
@rpc("authority") func ClientCombatHandler_SendHotbar():
	rpc_id(1, "ServerCombatHandler_UpdateClientHotbar", hotbar.CreateHotbarDict())
