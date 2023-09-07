class_name ServerCombatHandlerSingleton extends Node

@rpc("any_peer") func ClientCombatHandler_RecieveResources(dict : Dictionary): pass
@rpc("any_peer") func ClientCombatHandler_RecieveSelfSpells(spells:Array): pass
@rpc("any_peer") func ClientCombatHandler_RecieveSpellTrees(trees:Dictionary): pass
@rpc("any_peer") func ClientCombatHandler_RecieveSpellPurchaseResult(spell:String, result:bool): pass
@rpc("any_peer") func ClientCombatHandler_RecieveAbilityActivateResult(spell, result): pass
@rpc("any_peer") func ClientCombatHandler_RecieveEffects(effects:Dictionary): pass
@rpc("any_peer") func ClientCombatHandler_CreateDmgPopup(player:String, type:String, amount:int): pass
@rpc("any_peer") func ClientCombatHandler_SendHotbar(): pass

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
		rpc_id(pid, "ClientCombatHandler_RecieveSelfSpells", character.CharacterData.unlocked_abilities.duplicate(true))
	
@rpc("any_peer") func ServerCombatHandler_RecieveTreesRequest():
	var pid : int = multiplayer.get_remote_sender_id()
	rpc_id(pid, "ClientCombatHandler_RecieveSpellTrees", AbilityHolder.ability_dictionary.duplicate(true))

@rpc("any_peer") func ServerCombatHandler_HandleSpellPurchaseRequest(spell:String):
	var pid : int = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(pid)):
		var playernode : PlayerContainer = DataRepository.PlayerMgmt.get_node(str(pid))
		var character : ActiveCharacter = playernode.CurrentActiveCharacter
		var result = true
		if not AbilityHolder.all_abilities.has(spell):
			return
		if character.CharacterData.ability_points < AbilityHolder.all_abilities[spell].point_cost:
			#todo change this to not use local chat. why did i do that?
			DataRepository.Server.SendLocalChat(ChatHandler.FormatSimpleMessage("+++You do not have the points to purchase this spell.+++"), null, pid)
			result = false
			
		if AbilityHolder.all_abilities[spell].requires_spells.size() > 0:
			var matching_spells : int = 0
			for i in AbilityHolder.all_abilities[spell].requires_spells:
				if character.CharacterData.unlocked_abilities.has(i):
					matching_spells += 1
			if matching_spells == AbilityHolder.all_abilities[spell].requires_spells.size():
				result = true
			else:
				DataRepository.Server.SendLocalChat(ChatHandler.FormatSimpleMessage("+++You do not have the prerequisite spells to purchase this.+++"), null, pid)
				result = false
				
		if spell in character.CharacterData.unlocked_abilities:
			DataRepository.Server.SendLocalChat(ChatHandler.FormatSimpleMessage("+++You already own "+spell+".+++"), null, pid)
			result = false
			
		if result == true:
			character.CharacterData.unlocked_abilities.append(spell)
			character.CharacterData.ability_points -= AbilityHolder.all_abilities[spell].point_cost
			DataRepository.Server.SendLocalChat(ChatHandler.FormatSimpleMessage("+++You've purchased "+spell+" for "+str(AbilityHolder.all_abilities[spell].point_cost)+" points.+++"), null, pid)
			
		rpc_id(pid, "ClientCombatHandler_RecieveSpellPurchaseResult", spell, result)
		
@rpc("any_peer") func ServerCombatHandler_HandleAbilityActivateRequest(slot:String, ability:String):
	var pid : int = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(pid)):
		var playernode : PlayerContainer = DataRepository.PlayerMgmt.get_node(str(pid))
		var character : ActiveCharacter = playernode.CurrentActiveCharacter
		var ability_res = AbilityHolder.all_abilities[ability]
		var result = true
		if not ability in character.CharacterData.unlocked_abilities:
			result = false
		if ability in character.cooldowns:
			result = false
		#todo mana cost here
		if result:
			var new_timer = get_tree().create_timer(AbilityHolder.all_abilities[ability].cooldown)
			new_timer.timeout.connect(Callable(character, "UnsetCooldown").bind(ability))
			character.cooldowns.append(ability)
			var target_collider
			for i in get_tree().get_nodes_in_group("PlayerCollider"):
				if i.name == character.selected_player:
					target_collider = i
			ability_res.UseAbility(character, character.CurrentCollider, target_collider)
		rpc_id(pid, "ClientCombatHandler_RecieveAbilityActivateResult", slot, result, AbilityHolder.all_abilities[ability].cooldown)
			
@rpc("any_peer") func ServerCombatHandler_RecieveSelectedPlayerUpdate(player:String):
	var pid : int = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(pid)):
		var playernode : PlayerContainer = DataRepository.PlayerMgmt.get_node(str(pid))
		var character : ActiveCharacter = playernode.CurrentActiveCharacter
		character.selected_player = player
		
@rpc("any_peer") func ServerCombatHandler_RecieveEffectRequest(array:Array):
	var return_dict : Dictionary = {}
	var pid : int = multiplayer.get_remote_sender_id()
	for i in array:
		var AC : ActiveCharacter
		for c in get_tree().get_nodes_in_group("active_characters"):
			if c.name == i:
				AC = c
		return_dict[i] = AC.CharacterData.active_effects.duplicate(true)
	rpc_id(pid, "ClientCombatHandler_RecieveEffects", return_dict)
	
@rpc("any_peer") func ServerCombatHandler_UpdateClientHotbar(hotbar:Dictionary):
	var pid : int = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(pid)):
		var playernode : PlayerContainer = DataRepository.PlayerMgmt.get_node(str(pid))
		var character : ActiveCharacter = playernode.CurrentActiveCharacter
		character.CharacterData.hotbar_bindings = hotbar.duplicate(true)
		
func ServerCombatHandler_SendCreateDmgPopup(source, dmg, type):
	for i in Helpers.GetPlayersInRange(source, 500):
		rpc_id(i.ControllingCharacter.ActiveController.associated_pid, "ClientCombatHandler_CreateDmgPopup", source.name, dmg, type)
