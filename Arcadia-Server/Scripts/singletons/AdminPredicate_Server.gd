extends Node

@rpc("any_peer") func AdminPredicateServer_RequestPlayerTeleport(player:String, map:String, position:Vector2):
	var pid = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(pid)):
		if DataRepository.Admin.CheckPermissions(AdminManager.RANK_FLAGS.TELEPORT,DataRepository.PlayerMgmt.get_node(str(pid))):
			var tele_player : ActiveCharacter
			for I in get_tree().get_nodes_in_group("active_characters"):
				if I.PlayerData.Username == player:
					tele_player = I
					
			if not tele_player:
				return
					
			if tele_player.CurrentMap == map:
				tele_player.CurrentCollider.teleport_to == position
			elif tele_player.CurrentMap:
				DataRepository.mapmanager.MovePlayerToMap(tele_player.CurrentCollider, tele_player.CurrentMap, map, position)
			else:
				DataRepository.mapmanager.MovePlayerToMapStandalone(tele_player.CurrentCollider, map, position)
		else:
			Logging.log_warning("[ADMIN PREDICATE] PID "+str(pid)+" attempted to invoke teleport without proper permissions.")
