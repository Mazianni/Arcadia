extends Node

#BOILERPLATE BEGIN NONE OF THESE DO ANYTHING BUT GODOT 4.X REQUIRES MATCHING RPCS BETWEEN CLIENT/SERVER.
@rpc("any_peer") func ServRPC_FetchServerTime(client_time): pass
@rpc("any_peer") func ServRPC_DetermineLatency(client_time): pass
@rpc("any_peer") func ServRPC_ReturnRequestedCharacterList(): pass
@rpc("any_peer") func ServRPC_CreateExistingCharacter(cuuid): pass
@rpc("any_peer") func ServRPC_RequestNewCharacter(species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height): pass
@rpc("any_peer") func ServRPC_DeleteCharacter(char_name): pass
@rpc("any_peer") func ServRPC_BuildRaceList(): pass
@rpc("any_peer") func ServRPC_Login(username, password, uuid, puuid): pass
@rpc("any_peer") func ServRPC_CreateAccount(username, password): pass
@rpc("any_peer") func ServRPC_RecievePersistentUUID(puuid): pass
@rpc("any_peer") func ServRPC_RequestColliderMovement(vector, direction): pass
@rpc("any_peer") func ServRPC_RecieveChat(msg:Dictionary): pass
@rpc("any_peer") func ServRPC_RecieveVersion(clientversion): pass
@rpc("any_peer") func ServRPC_SendPermissions(): pass
@rpc("any_peer") func ServRPC_UpdateSoloTicket(ticket_number:String): pass
@rpc("any_peer") func ServRPC_GetTickets(for_staff:bool = false): pass
@rpc("any_peer") func ServRPC_OpenTicket(title:String, details:String, with_user:String, critical:bool = false): pass
@rpc("any_peer") func ServRPC_CloseTicket(ticket_number:String): pass
@rpc("any_peer") func ServRPC_SendMessageToTicket(message:String, ticket_number:String): pass
@rpc("any_peer") func ServRPC_ClaimTicket(ticket_number:String): pass
@rpc("any_peer") func ServRPC_AddUserToTicket(username:String, ticket_number:String): pass
@rpc("any_peer") func ServRPC_AddPlayerNote(username:String, title:String, note:String): pass
@rpc("any_peer") func ServRPC_RemovePlayerNote(username:String, note_number:String): pass
@rpc("any_peer") func ServRPC_EditPlayerNote(username:String, note_number:String, new_note:String): pass
@rpc("any_peer") func ServRPC_GetPlayerNotes(): pass
@rpc("any_peer") func ServRPC_IsClientAdmin(): pass
@rpc("any_peer") func ServRPC_GetCurrentPlayers(): pass
@rpc("any_peer") func ServRPC_RecieveClientState(client_state): pass
@rpc("any_peer", "unreliable") func ServRPC_RequestWorldState(): pass

#BOILERPLATE END

var network : ENetMultiplayerPeer
var ip = "127.0.0.1"
var port = 5000
	
var main_instance = "res://scenes/CharacterSelect.tscn"

var latency_array = []
var decimal_collector : float = 0
var latency = 0
var delta_latency = 0
var client_clock = 0

@onready var maphandler = get_tree().get_root().get_node("RootNode/Maphandler")

signal character_list_recieved
signal permissions_recieved(permissions)
signal tickets_recieved(tickets)
signal ticket_update_recieved(ticket, ticket_number)
signal admin_tickets_recieved(tickets)
signal player_list_recieved(playerlist)
signal player_notes_recieved(player_notes)
signal admin_verified(verified)
signal world_update_recieved
 
func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency -= delta_latency
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1
	
func ConnectToServer():
	network = ENetMultiplayerPeer.new()
	network.create_client(ip, port)
	multiplayer.multiplayer_peer = network
	
	
	multiplayer.connection_failed.connect(_OnConnectionFailed)
	multiplayer.connected_to_server.connect(_OnConnectionSucceeded)
	multiplayer.server_disconnected.connect(_OnServerDisconnected)
	
#Connection signals
	
func _OnConnectionFailed():
	print("Failed to Connect.")
	
	multiplayer.connection_failed.disconnect(_OnConnectionFailed)
	multiplayer.connected_to_server.disconnect(_OnConnectionSucceeded)
	multiplayer.server_disconnected.disconnect(_OnServerDisconnected)
	await get_tree().create_timer(1).timeout
	#multiplayer.multiplayer_peer = null
	#network = null
		
func _OnConnectionSucceeded():
	print("Connection Succcessful.")
	rpc_id(1, "ServRPC_FetchServerTime", Time.get_unix_time_from_system()*1000)
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(DetermineLatency)
	self.add_child(timer)
	Globals.client_state = Globals.SERVER_CONNECTION_STATE.CONNECTED
	CombatHandler.ClientCombatHandler_RequestSpellTrees()
	
func _OnServerDisconnected(): #todo make this return to the login screen.
	Globals.client_state = Globals.SERVER_CONNECTION_STATE.DISCONNECTED
	Globals.client_state = Globals.CLIENT_STATE_LIST.CLIENT_UNAUTHENTICATED	
	multiplayer.connection_failed.disconnect(_OnConnectionFailed)
	multiplayer.connected_to_server.disconnect(_OnConnectionSucceeded)
	multiplayer.server_disconnected.disconnect(_OnServerDisconnected)
	await get_tree().create_timer(1).timeout
	multiplayer.multiplayer_peer = null
	network = null
	if Gui.current_loaded_GUI_name != "LoginScreen":
		Gui.CreateFloatingMessage("Server disconnected! Please login again.", "bad")
		Globals.SetClientState(Globals.CLIENT_STATE_LIST.CLIENT_UNAUTHENTICATED)
		maphandler.ClearScenes()
	
#End connection signals

#Player state communication / latency
	
func SendPlayerState(state):
	pass
	
func DetermineLatency():
	if multiplayer.multiplayer_peer:
		rpc_id(1, "ServRPC_DetermineLatency", Time.get_unix_time_from_system()*1000)
	
@rpc("any_peer") func ReturnLatency(client_time):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	latency_array.append((Time.get_unix_time_from_system()*1000 - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range (latency_array.size()-1,-1,-1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.erase(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency/latency_array.size()
		latency_array.clear()
		
@rpc("any_peer", "unreliable") func RequestWorldState():
	rpc_id(1, "ServRPC_RequestWorldState")
	
@rpc("any_peer", "unreliable") func RecieveWorldState(state):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	maphandler.UpdateWorldState(state)
	world_update_recieved.emit()
	
@rpc("any_peer") func ReturnServerTime(server_time, client_time):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	latency = (Time.get_unix_time_from_system() - client_time) / 2
	client_clock = server_time + latency
	
	
#end state/latency
	
#player spawning
@rpc("any_peer") func SpawnNewPlayer(player_id, spawn_position):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		return
	get_node("../RootNode/MapHandler/SubViewportContainer/SubViewport/GameRender2D").SpawnNewPlayer(player_id, spawn_position)

@rpc("any_peer") func DespawnPlayer(player_id):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		return
	get_node("../RootNode/MapHandler/SubViewportContainer/SubViewport/GameRender2D").DespawnPlayer(player_id)
#end player spawning

#character creation handling start

func GetRaceList():
	rpc_id(1, "ServRPC_BuildRaceList")
	
@rpc("any_peer") func RecieveRaceList(racelist : Dictionary):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	Globals.RaceList = racelist.duplicate(true)
	
@rpc("any_peer") func ClientRPC_ReturnNewCharacterCreated(status, message):
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

@rpc("any_peer") func RecieveCharacterList(characterlist):
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
	
@rpc("any_peer") func LoadWorld(worldname):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	print("sdadas")
	maphandler.ChangeMap(worldname)

	
@rpc("any_peer") func ClientRPC_ReturnCharacterLoadFailed():
	Gui.CreateFloatingMessage("The server reported an error loading your character. \nPlease try again or inform a developer.", "bad")
	
	
@rpc("any_peer") func RecieveClientStateSync(client_state):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	Globals.SetClientState(client_state)

#client state reporting

@rpc("any_peer") func ReportClientState(client_state):
	rpc_id(1, "ServRPC_RecieveClientState", client_state)

#end client state reporting

#login

func Login(username, password, uuid, puuid):
	await get_tree().create_timer(1).timeout
	if multiplayer.multiplayer_peer:
		rpc_id(1,"ServRPC_Login", username, password, uuid, Globals.persistent_uuid)

func CreateAccount(username, password):
	Server.ConnectToServer()
	await get_tree().create_timer(0.1).timeout
	rpc_id(1,"ServRPC_CreateAccount", username, password)
	
@rpc("any_peer") func CreateAccountResults(result, message):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	if(result == false):
		Disconnect()
	if result == true:
		get_node("../RootNode/GUI/LoginScreen")._on_Back_pressed()
		Gui.CreateFloatingMessage("New account created. Please login.", "good")
	else:
		Gui.CreateFloatingMessage(str(message), "bad")
		get_node("../RootNode/GUI/LoginScreen").EnableInputs()
	network.disconnect("connection_failed", Callable(self, "_OnConnectionFailed"))
	network.disconnect("connection_succeeded", Callable(self, "_OnConnectionSucceeded"))

@rpc("any_peer") func ReturnLogin(status, message):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	if status == false:
		if message:
			Gui.CreateFloatingMessage(str(message), "bad")
		else:
			Gui.CreateFloatingMessage("Incorrect username or password.", "bad")
		get_node("../RootNode/GUI/LoginScreen").EnableInputs()
		network.disconnect("connection_failed", Callable(self, "_OnConnectionFailed"))
		network.disconnect("connection_succeeded", Callable(self, "_OnConnectionSucceeded"))
	else:
		Gui.CreateFloatingMessage("Login successful.", "good")
		Globals.SetClientState(Globals.CLIENT_STATE_LIST.CLIENT_PREGAME)
		
#end login

#movement request start

func RequestMovement(vector, direction):
	if not Globals.client_state == Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		return
	rpc_id(1, "ServRPC_RequestColliderMovement", vector, direction)

#movement request end

#chat functions start

func SendChat(msg):
	rpc_id(1, "ServRPC_RecieveChat", msg)
	
@rpc("any_peer") func RecieveChat(msg):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		return
	ChatManager.CreateNewChatMessage(msg)

#chat functions end

@rpc("any_peer") func Disconnect(reason : String = ""):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	Globals.SetClientState(Globals.CLIENT_STATE_LIST.CLIENT_UNAUTHENTICATED)
	if(reason):
		Gui.CreateFloatingMessage(reason, "bad")
		
#version checking start
@rpc("any_peer") func SendVersion():
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	rpc_id(1, "ServRPC_RecieveVersion", Globals.client_version)
	print(Globals.client_version)
	
@rpc("any_peer") func SendPersistentUUID():
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	rpc_id(1, "ServRPC_RecievePersistentUUID", Globals.persistent_uuid)
#version checking end

#permissions start
func GetClientPermissions():
	rpc_id(1, "ServRPC_SendPermissions")
	
func RecievePermissions(permissions_array:Array):
	emit_signal("permissions_recieved", permissions_array)

#permissions end

#tickets start
	
func GetTickets(for_staff:bool = false):
	rpc_id(1, "ServRPC_GetTickets", for_staff)
	
func GetUpdateOnTicket(ticket_number:String):
	rpc_id(1, "ServRPC_UpdateSoloTicket", ticket_number)
	
@rpc("any_peer") func RecieveTicketsAdmin(ticket_dict:Dictionary):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	emit_signal("admin_tickets_recieved", ticket_dict)
	
@rpc("any_peer") func RecieveTickets(ticket_dict:Dictionary, all_tickets:bool = false):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	emit_signal("tickets_recieved", ticket_dict)
	
@rpc("any_peer") func ClientRPC_UpdateTicket(ticket_number:String, ticket_dict:Dictionary):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	emit_signal("ticket_update_recieved",ticket_number, ticket_dict)
	
func OpenTicket(title:String, details:String, with_user:String, critical:bool = false):
	rpc_id(1, "ServRPC_OpenTicket", title, details, with_user, critical)
	
func CloseTicket(ticket_number:String):
	rpc_id(1, "ServRPC_CloseTicket", ticket_number)
	
func ClaimTicket(ticket_number:String):
	rpc_id(1, "ServRPC_ClaimTicket", ticket_number)
	
func SendMessageToTicket(message:String, ticket_number:String):
	rpc_id(1, "ServRPC_SendMessageToTicket", message, ticket_number)
	
func AddUserToTicket(username:String, ticket_number:String):
	rpc_id(1, "ServRPC_AddUserToTicket", username, ticket_number)
#tickets end

#player notes

func RequestNotes():
	rpc_id(1, "ServRPC_GetPlayerNotes")
	
func AddPlayerNote(username:String, title:String, note:String):
	rpc_id(1, "ServRPC_AddPlayerNote", username, title, note)
	
func RemovePlayerNote(username:String, note_number:String):
	rpc_id(1, "ServRPC_RemovePlayerNote", username, note_number)
	
func EditPlayerNote(username:String, note_number:String, new_note:String):
	rpc_id(1, "ServRPC_EditPlayerNote", username, note_number, new_note)

@rpc("any_peer") func RecievePlayerNotes(note_dict: Dictionary):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	emit_signal("player_notes_recieved", note_dict)

#player notes end

#misc

func GetPlayerList():
	rpc_id(1, "ServRPC_GetCurrentPlayers")
	
@rpc("any_peer") func RecieveCurrentPlayers(player_list):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	emit_signal("player_list_recieved", player_list)
	
func IsClientAdmin():
	rpc_id(1, "ServRPC_IsClientAdmin")
	
@rpc("any_peer") func VerifyClientIsAdmin(decision:bool):
	if not Helpers.IsServer(multiplayer.get_remote_sender_id()):
		return
	if decision:
		Globals.is_client_admin = true
		emit_signal("admin_verified", decision)

#misc end

#map sync start

@rpc("any_peer") func ClientRPC_RecieveMapSync(mapname:String):
	maphandler.ChangeMap(mapname)

#map sync end

#inventory sync / manipulation start

@rpc("any_peer") func ClientRPC_BindNetworkedInventories(inventory):
	InventoryManager.BindNetworkInventory(inventory)

#inventory sync / manipulation  end


