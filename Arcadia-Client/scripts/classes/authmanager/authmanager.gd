class_name ClientAuthManager extends Node

@rpc("any_peer") func AuthTest(): pass

func _process(delta):
	if Authentication.multiplayer_api.has_multiplayer_peer():
		rpc_id(1, "AuthTest")
