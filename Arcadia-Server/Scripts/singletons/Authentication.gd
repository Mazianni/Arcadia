extends Node

# BOILERPLATE BEGIN NONE OF THESE DO ANYTHING BUT GODOT 4.X REQUIRES RPCS MATCH BETWEEN CLIENT/SERVER.
@rpc("authority") func RecieveRaceList(racelist : Dictionary): pass
@rpc("authority") func ClientRPC_ReturnNewCharacterCreated(status, message): pass
@rpc("authority") func RecieveCharacterList(characterlist): pass
@rpc("authority") func CreateAccountResults(result, message): pass
@rpc("authority") func ReturnLogin(status, message): pass
@rpc("authority") func SendVersion(): pass
@rpc("authority") func SendPersistentUUID(): pass
@rpc("authority") func ClientRPC_RecieveLoginToken(token): pass
@rpc("authority") func ClientRPC_PreloadWorld(world_name): pass
@rpc("authority") func ClientRPC_SendLoginToken(): pass

var auth_network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var auth_port = 5001
var multiplayer_api : MultiplayerAPI
var valid_tokens : Dictionary = {}

func InitAuth():
	multiplayer_api = MultiplayerAPI.create_default_interface()
	auth_network.create_server(auth_port, 100)
	multiplayer_api.multiplayer_peer = auth_network
	get_tree().set_multiplayer(multiplayer_api, self.get_path())
	Logging.log_notice("[SERVER] Auth Network connection open on port "+str(auth_port))
	auth_network.peer_connected.connect(Callable(self, "_PeerConnected"))
	auth_network.peer_disconnected.connect(Callable(self, "_PeerDisconnected"))

func _process(delta):
	auth_network.poll()
	for i in valid_tokens.keys():
		if valid_tokens[i]["expiration"] <= Time.get_unix_time_from_system():
			Logging.log_notice("[AUTH] Token for "+valid_tokens[i]["user"]+" expired.")
			valid_tokens.erase(i)

func _PeerConnected(player_id):
	Logging.log_notice("[AUTH] User "+str(player_id)+" Connected from IP "+str(auth_network.get_peer(player_id).get_remote_address()))
	rpc_id(player_id, "SendVersion")
	rpc_id(player_id, "ClientRPC_SendLoginToken")
	
func _PeerDisconnected(player_id):
	Logging.log_notice("[AUTH] User "+str(player_id)+" Disconnected")
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		if DataRepository.PlayerMgmt.get_node(str(player_id)).CurrentActiveCharacter == null:
			DataRepository.PlayerMgmt.get_node(str(player_id)).queue_free()
	
#character handling start

@rpc("any_peer") func ServRPC_ReturnRequestedCharacterList():
	SendPlayerCharacterList(multiplayer.get_remote_sender_id())
	
func SendPlayerCharacterList(player_id):
	var CharacterList : Dictionary
	var retryload = true
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		var check_node : PlayerContainer = DataRepository.PlayerMgmt.get_node(str(player_id))
		if check_node.HasLoaded:
			CharacterList = DataRepository.PlayerMgmt.get_node(str(player_id)).PlayerData.character_dict.duplicate(true)
			rpc_id(player_id, "RecieveCharacterList", CharacterList)
			Logging.log_notice("Sending character list of "+str(player_id)+".")
		else:
			DeferredSendCharacterListCallback(check_node)
			CharacterList = DataRepository.PlayerMgmt.get_node(str(player_id)).PlayerData.character_dict.duplicate(true)
			rpc_id(player_id, "RecieveCharacterList", CharacterList)
			Logging.log_notice("Deferred sending character list of "+str(player_id)+".")

func DeferredSendCharacterListCallback(node : PlayerContainer):
	await node.loaded
	return true
		
@rpc("any_peer") func ServRPC_CreateExistingCharacter(cuuid):
	var player_id = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(player_id)): #IMPLEMENT blocking code based on server state
			var playernode : PlayerContainer = DataRepository.PlayerMgmt.get_node(str(player_id))
			playernode.CreateActiveCharacter(cuuid, player_id)
			
@rpc("any_peer") func ServRPC_RequestNewCharacter(species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height):
	var player_id = multiplayer.get_remote_sender_id()
	var cuuid = DataRepository.Server.uuid_generator.v4()
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
			DataRepository.PlayerMgmt.CreateNewCharacter(cuuid, species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height, player_id)
			
func ReturnNewCharacterCreated(pid:int, result:bool, message:String):
	rpc_id(pid, "ClientRPC_ReturnNewCharacterCreated", result, message)
			
@rpc("any_peer") func ServRPC_DeleteCharacter(char_name):
	var player_id = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		DataRepository.PlayerMgmt.get_node(str(player_id)).DeleteCharacter(char_name)
		
func ReturnCharacterLoaded(pid, worldname):
	rpc_id(pid, "ClientRPC_PreloadWorld", worldname)
	
func ReturnCharacterLoadFailed(pid):
	rpc_id(pid, "ClientRPC_ReturnCharacterLoadFailed")
#character handling end

#character creation handling start

@rpc("any_peer") func ServRPC_BuildRaceList():
	var player_id = multiplayer.get_remote_sender_id()
	var racedict : Dictionary = {}
	var racesubdict : Dictionary = {}
	for i in DataRepository.races.keys():
		var racecheck : SpeciesBase = DataRepository.races[i]
		print(str(racecheck.race_name))
		if racecheck.requires_approval == true:
			if not CheckPlayerApprovedForRace(DataRepository.pid_to_username[str(player_id)]["username"], racecheck.race_name):
				continue
		racesubdict = {
		"Name" : racecheck.race_name,
		"Icon" : racecheck.race_icon,
		"Short Description" : racecheck.race_description_short,
		"Long Description" : racecheck.race_description_extended,
		"ValidSkin" : racecheck.default_skin_colors.duplicate(true),
		"ValidEars" : racecheck.default_ear_styles,
		"ValidTails" : racecheck.default_tail_styles,
		"ValidAccessoryOne" : racecheck.default_accessory_one_styles,
		"ValidSpawns" : racecheck.valid_spawns,
		"Heightminmax" : racecheck.heightminmax.duplicate(true),
		}
		racedict[i] = racesubdict
	rpc_id(player_id, "RecieveRaceList", racedict)
	Logging.log_notice("Sending race list to "+str(player_id))
	
func CheckPlayerApprovedForRace(username, race):
	var approved = false
	if username in DataRepository.approved_users_for_races:
		if race in DataRepository.approved_users_for_races[username]["races"]:
			approved = true
	return approved
	
#character creation handling end

#login start

@rpc("any_peer") func ServRPC_Login(username, password, uuid, puuid):
	var player_id = multiplayer.get_remote_sender_id()
	var message
	Logging.log_notice("[AUTH] Login attempt from PID" + str(player_id) + " UUID " + str(uuid))
	var status = false
	match DataRepository.CurrentState:
		DataRepository.SERVER_STATE.SERVER_LOADING:
			message = "Server not yet ready. Connection refused."
			status = false
		DataRepository.SERVER_STATE.SERVER_SHUTTING_DOWN:
			message = "Server shutting down. Connection refused."
			status = false
	var bancheck = DataRepository.Admin.CheckBanned(username, puuid, str(auth_network.get_peer(player_id).get_remote_address()))
	if bancheck:
		match bancheck:
			FAILED:
				message = "Connection Rejected: \nBanned User/IP"
				Logging.log_notice("[AUTH] Connection from PID" + str(player_id) + " failed: Banned user.")
			ERR_PARSE_ERROR:
				Logging.log_error("[AUTH] Login attempt from PID" + str(player_id) + " failed: Malformed login information.")
				message = "Connection Rejected: \nMalformed Request!"
		status = false
		ReportLoginStatus(player_id, status, message)
		auth_network.disconnect_peer(player_id)
		return
	for i in get_tree().get_nodes_in_group("players"):
		if i.PlayerData.Username == username:
			status = false
			message = "Connection Rejected:\nUser already logged in!"
			ReportLoginStatus(player_id, status, message)
			return
	if AuthenticatePlayer(username, password, player_id, uuid):
		status = true
	ReportLoginStatus(player_id, status, message)
	
func AuthenticateWithToken(pid, token):
	return
				
func ReportLoginStatus(player_id, status, message):
	rpc_id(player_id, "ReturnLogin", status, message)
	if(status == false):
		rpc_id(player_id, "Disconnect", message)
		auth_network.disconnect_peer(player_id)

func AuthenticatePlayer(username, password, player_id, player_uuid):
	var token
	Logging.log_notice("[AUTH] Authentication request recieved from "+str(player_id))
	var gateway_id = multiplayer.get_remote_sender_id()
	var result = false
	Logging.log_notice("[AUTH] Starting authentication for "+str(player_id))
	var dbcheckuser = "'"+username+"'"
	if not OS.has_feature("editor"):
		if not DataRepository.GetDataFromDB("playerdata", "username="+dbcheckuser, ["hash", "salt"]):
			Logging.log_warning("[AUTH] Invalid username from " +str(player_id))
			result = false
		elif not VerifyPassword(username, password):
			Logging.log_warning("[AUTH] Incorrect password from "+str(player_id))
			result = false
		else:
			Logging.log_notice("[AUTH] Authentication successful for "+str(player_id))
			result = true
			DataRepository.pid_to_username[str(player_id)] = {"username": str(username), "uuid": str(player_uuid)}
			DataRepository.PlayerMgmt.CreatePlayerContainer(player_id, player_uuid)
			DataRepository.PlayerMgmt.get_node(str(player_id)).PlayerData.last_login = Time.get_unix_time_from_system()
			GenerateLoginTokenForClient(player_id, username, player_uuid)
	else:
		Logging.log_notice("[AUTH] Running in editor. Authentication not done for "+str(player_id))
		result = true
		DataRepository.pid_to_username[str(player_id)] = {"username": str(username), "uuid": str(player_uuid)}
		DataRepository.PlayerMgmt.CreatePlayerContainer(player_id, player_uuid)
		DataRepository.PlayerMgmt.get_node(str(player_id)).PlayerData.last_login = Time.get_unix_time_from_system()	
		GenerateLoginTokenForClient(player_id, username, player_uuid)
	Logging.log_notice("[AUTH] Sending authentication results to user " + str(player_id))
	return result
	
@rpc("any_peer") func ServRPC_CreateAccount(username, password):
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	var message
	var dbcheckuser = "'"+username+"'"
	var can_create = true
	match DataRepository.CurrentState:
		DataRepository.SERVER_STATE.SERVER_LOADING:
			message = "Server not yet ready. Connection refused."
			result = false
			can_create = false
		DataRepository.SERVER_STATE.SERVER_SHUTTING_DOWN:
			message = "Server shutting down. Connection refused."
			result = false
			can_create = false
	if can_create:
		if DataRepository.GetDataFromDB("playerdata", "username="+dbcheckuser, ["username"]):
			Logging.log_warning("[AUTH] Username already in use.")
			result = false
			message = "Username already in use."
		else:
			result = true
			message = "Account created successfully."
			randomize()
			var salt = str(randi())
			var pepper = password+salt
			var hashed = pepper.sha256_text()
			if DataRepository.WriteNewUserToDB(username, hashed, salt):
				Logging.log_notice("[AUTH] New user "+str(username)+" written to database!")
			else:
				Logging.log_error("[AUTH] Failed to write new user to database!")		
	rpc_id(gateway_id, "CreateAccountResults", result, message)
	
func VerifyPassword(username, password):
	var dbusername = "'"+username+"'"
	var selectedpw : Array = DataRepository.GetDataFromDB("playerdata", "username = "+dbusername, ["hash","salt"])
	var hashed = selectedpw[0]["hash"]
	var salt = selectedpw[0]["salt"]
	var testingpw = password+salt
	if testingpw.sha256_text() == hashed:
		return true
	else:
		return false
	
func RequestPersistentUUID(player_id):
	rpc_id(player_id, "SendPersistentUUID")

@rpc("any_peer") func ServRPC_RecievePersistentUUID(puuid):
	if DataRepository.PlayerMgmt.has_node(str(multiplayer.get_remote_sender_id())):
		DataRepository.PlayerMgmt.get_node(str(multiplayer.get_remote_sender_id())).PlayerData.persistent_uuid = puuid

#login end

#version checking
@rpc("any_peer") func ServRPC_RecieveVersion(clientversion):
	var playerid = multiplayer.get_remote_sender_id()
	CheckClientVersion(playerid, clientversion)

func CheckClientVersion(player_id, clientversion):
	if clientversion != DataRepository.serverversion:
		Logging.log_warning("[CLIENT] Client version for PID "+ str(player_id)+ " does not match server version. Recieved:" + str(clientversion) + " Required:"+ str(DataRepository.serverversion))
		rpc_id(player_id, "Disconnect", "Connection Rejected: Client Version Invalid! \n Current: "+str(clientversion)+"\n Required: "+ str(DataRepository.serverversion))
		auth_network.disconnect_peer(player_id)
		
#version checking end

#token handling start

func GenerateLoginTokenForClient(pid, user, puuid):
	var token = DataRepository.uuid_generator.v4()
	valid_tokens[token] = {
		"user":user,
		"uuid":puuid,
		"expiration":Time.get_unix_time_from_system()+3600 #1 hour
	}
	SendLoginToken(pid, token)
	Logging.log_notice("[AUTH] Token for "+user+" generated.")

func SendLoginToken(pid, token):
	rpc_id(pid, "ClientRPC_RecieveLoginToken", token)
	
@rpc("any_peer") func ServRPC_RecieveLoginToken(token):
	DataRepository.Server.HandleLoginToken(multiplayer_api.get_remote_sender_id(), token)
	
@rpc("any_peer") func ServRPC_EraseTokenClientExit(token):
	if valid_tokens.has(token):
		Logging.log_notice("[AUTH] Token for "+valid_tokens[token]["user"]+"erased.")
		valid_tokens.erase(token)

#token handling end
