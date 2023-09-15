class_name Authenticator extends Node

#BOILERPLATE BEGIN NONE OF THESE DO ANYTHING BUT GODOT 4.X REQUIRES MATCHING RPCS BETWEEN CLIENT/SERVER.
@rpc("any_peer") func ServRPC_ReturnRequestedCharacterList(): pass
@rpc("any_peer") func ServRPC_CreateExistingCharacter(cuuid): pass
@rpc("any_peer") func ServRPC_RequestNewCharacter(species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height): pass
@rpc("any_peer") func ServRPC_DeleteCharacter(char_name): pass
@rpc("any_peer") func ServRPC_BuildRaceList(): pass
@rpc("any_peer") func ServRPC_Login(username, password, uuid, puuid): pass
@rpc("any_peer") func ServRPC_CreateAccount(username, password): pass
@rpc("any_peer") func ServRPC_RecievePersistentUUID(puuid): pass
@rpc("any_peer") func ServRPC_RecieveVersion(clientversion): pass
@rpc("any_peer") func ServRPC_RecieveLoginToken(token): pass
@rpc("any_peer") func ServRPC_EraseTokenClientExit(token): pass

signal character_list_recieved

var auth_network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var auth_port = 5001
var multiplayer_api : MultiplayerAPI
var auth_connected = false

func _ready():
	multiplayer_api = MultiplayerAPI.create_default_interface()

func InitAuth():
	auth_network.create_client("127.0.0.1", auth_port)
	multiplayer_api.multiplayer_peer = auth_network
	get_tree().set_multiplayer(multiplayer_api, self.get_path())
	multiplayer_api.server_disconnected.connect(Callable(self, "_OnDisconnected"))
	auth_connected = true

func _process(delta):
	if auth_connected:
		auth_network.poll()
		
func _OnDisconnected(player_id):
	if Globals.client_state == Globals.CLIENT_STATE_LIST.CLIENT_PREGAME:
		Globals.SetClientState(Globals.CLIENT_STATE_LIST.CLIENT_UNAUTHENTICATED)
	auth_connected = false
	
#character creation handling start

func GetRaceList():
	rpc_id(1, "ServRPC_BuildRaceList")
	
@rpc("authority") func RecieveRaceList(racelist : Dictionary):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	Globals.RaceList = racelist.duplicate(true)
	
@rpc("authority") func ClientRPC_ReturnNewCharacterCreated(status, message):
	if(status):
		Globals.SetClientState(Globals.CLIENT_STATE_LIST.CLIENT_PREGAME) #dump them to the character selection menu
	var msgcolor : String = "neutral"
	match status:
		true:
			msgcolor = "good"
		false:
			msgcolor = "bad"
	Gui.CreateFloatingMessage(message, msgcolor)

#character creation handling end

#character selection

func RequestCharacterList():
	rpc_id(1, "ServRPC_ReturnRequestedCharacterList")

@rpc("authority") func RecieveCharacterList(characterlist):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	Globals.CharacterList = characterlist
	emit_signal("character_list_recieved")
		
func SelectCharacter(charname):
	rpc_id(1, "ServRPC_CreateExistingCharacter", charname)
	
func RequestNewCharacter(species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height):
	rpc_id(1, "ServRPC_RequestNewCharacter", species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height)
	
func DeleteCharacter(char_name):
	rpc_id(1, "ServRPC_DeleteCharacter", char_name)
	
#end character selection

#login

func Login(username, password, uuid, puuid):
	await get_tree().create_timer(1).timeout
	if multiplayer.multiplayer_peer:
		rpc_id(1,"ServRPC_Login", username, password, uuid, Globals.persistent_uuid)

func CreateAccount(username, password):
	Server.ConnectToServer()
	await get_tree().create_timer(0.1).timeout
	rpc_id(1,"ServRPC_CreateAccount", username, password)
	
@rpc("authority") func CreateAccountResults(result, message):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	if(result == false):
		auth_network.disconnect_peer(1, true)
	if result == true:
		get_node("../RootNode/GUI/LoginScreen")._on_Back_pressed()
		Gui.CreateFloatingMessage("New account created. Please login.", "good")
	else:
		Gui.CreateFloatingMessage(str(message), "bad")
		get_node("../RootNode/GUI/LoginScreen").EnableInputs()
	auth_network.disconnect("connection_failed", Callable(self, "_OnConnectionFailed"))
	auth_network.disconnect("connection_succeeded", Callable(self, "_OnConnectionSucceeded"))

@rpc("authority") func ReturnLogin(status, message):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	if status == false:
		if message:
			Gui.CreateFloatingMessage(str(message), "bad")
		else:
			Gui.CreateFloatingMessage("Incorrect username or password.", "bad")
		get_node("../RootNode/GUI/LoginScreen").EnableInputs()
		auth_network.disconnect("connection_failed", Callable(self, "_OnConnectionFailed"))
		auth_network.disconnect("connection_succeeded", Callable(self, "_OnConnectionSucceeded"))
	else:
		Gui.CreateFloatingMessage("Login successful.", "good")
		Globals.SetClientState(Globals.CLIENT_STATE_LIST.CLIENT_PREGAME)
		
#end login

#version checking start
@rpc("authority") func SendVersion():
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	rpc_id(1, "ServRPC_RecieveVersion", Globals.client_version)
	print(Globals.client_version)
	
@rpc("authority") func SendPersistentUUID():
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	rpc_id(1, "ServRPC_RecievePersistentUUID", Globals.persistent_uuid)
#version checking end

#login token handling

@rpc("authority") func ClientRPC_RecieveLoginToken(token):
	Globals.authorized_token = token
	
@rpc("authority") func ClientRPC_SendLoginToken():
	rpc_id(1, "ServRPC_RecieveLoginToken", Globals.authorized_token)
	
func EraseTokenOnExit():
	rpc_id(1, "ServRPC_EraseTokenClientExit", Globals.authorized_token)

#login token handling end

@rpc("authority") func ClientRPC_PreloadWorld(world_name):
	Globals.SetClientState(Globals.CLIENT_STATE_LIST.CLIENT_INGAME)
	Server.maphandler.ChangeMap(world_name)
	await get_tree().create_timer(5).timeout
	Server.ConnectToServer()
	auth_network.disconnect_peer(1)
	auth_connected = false
