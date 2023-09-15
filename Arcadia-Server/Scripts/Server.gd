class_name MainServer extends Node

# BOILERPLATE BEGIN NONE OF THESE DO ANYTHING BUT GODOT 4.X REQUIRES RPCS MATCH BETWEEN CLIENT/SERVER.
@rpc("any_peer") func ReturnLatency(client_time): pass
@rpc("any_peer", "unreliable") func RecieveWorldState(state): pass
@rpc("any_peer") func ReturnServerTime(server_time, client_time): pass
@rpc("any_peer") func SpawnNewPlayer(player_id, spawn_position): pass
@rpc("any_peer") func DespawnPlayer(player_id): pass
@rpc("any_peer") func RecieveRaceList(racelist : Dictionary): pass
@rpc("any_peer") func RecieveCharacterList(characterlist): pass
@rpc("any_peer") func LoadWorld(worldname): pass
@rpc("any_peer") func CreateAccountResults(result, message): pass
@rpc("any_peer") func ReturnLogin(status, message): pass
@rpc("any_peer") func RecieveChat(msg): pass
@rpc("any_peer") func Disconnect(reason : String = ""): pass
@rpc("any_peer") func SendVersion(): pass
@rpc("any_peer") func SendPersistentUUID(): pass
@rpc("any_peer") func RecieveTicketsAdmin(ticket_dict:Dictionary): pass
@rpc("any_peer") func RecieveTickets(ticket_dict:Dictionary, all_tickets:bool = false): pass
@rpc("any_peer") func ClientRPC_UpdateTicket(ticket_number:String, ticket_dict:Dictionary): pass
@rpc("any_peer") func RecievePlayerNotes(note_dict: Dictionary): pass
@rpc("any_peer") func RecieveCurrentPlayers(player_list): pass
@rpc("any_peer") func VerifyClientIsAdmin(decision:bool): pass
@rpc("any_peer") func ReportClientState(client_state): pass
@rpc("any_peer") func RecieveClientStateSync(client_state): pass
@rpc("any_peer") func ClientRPC_ReturnCharacterLoadFailed(pid): pass
@rpc("any_peer", "unreliable") func RequestWorldState(): pass
@rpc("any_peer") func ClientRPC_ReturnNewCharacterCreated(): pass
@rpc("any_peer") func ClientRPC_RecieveMapSync(mapname:String): pass
@rpc("any_peer") func ClientRPC_BindNetworkedInventories(inventory): pass
@rpc("any_peer") func ClientRPC_SetWarpingTrue(): pass
@rpc("any_peer") func ClientRPC_NotifyPlayerAreaEntered(pid, text, subtext): pass
@rpc("authority") func ClientRPC_RecieveLoginToken(token): pass
@rpc("authority") func ClientRPC_SendLoginToken(): pass
@rpc("any_peer") func ServRPC_ReturnRequestedCharacterList(): pass
@rpc("any_peer") func ServRPC_CreateExistingCharacter(cuuid): pass
@rpc("any_peer") func ServRPC_RequestNewCharacter(species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height): pass
@rpc("any_peer") func ServRPC_DeleteCharacter(char_name): pass
@rpc("any_peer") func ServRPC_BuildRaceList(): pass
@rpc("any_peer") func ServRPC_Login(username, password, uuid, puuid): pass
@rpc("any_peer") func ServRPC_CreateAccount(username, password): pass
@rpc("any_peer") func ServRPC_RecievePersistentUUID(puuid): pass
@rpc("any_peer") func ServRPC_RecieveVersion(clientversion): pass
	
var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()

var port = 5000
var max_players = 300

var player_state_collection = {}
var characters_awaiting_creation = {}
var map_state_collection = {}

@onready var uuid_generator = preload("res://uuid.gd")

signal character_load_failed
signal shutdown_requested
signal all_peers_disconnected

func _ready():
	Logging.log_notice("[SERVER INIT] Arcadia Server v"+DataRepository.serverversion+" starting...")
	get_tree().set_auto_accept_quit(false)
	DataRepository.SetServerState(DataRepository.SERVER_STATE.SERVER_LOADING)
	SubsystemManager.MasterSubsystemInit()
	SubsystemsStartCompleteCallback()
	StartServer()
	
func SubsystemsStartCompleteCallback():
	await SubsystemManager.subsystems_init_complete
	return true
	
func BeginShutdown():
	Logging.log_notice("[SERVER MGMT] Server shutdown requested...")
	DataRepository.SetServerState(DataRepository.SERVER_STATE.SERVER_SHUTTING_DOWN)
	shutdown_requested.emit()
	SubsystemManager.MasterSubsystemShutdown()
	
func _notification(notif):
	if notif == NOTIFICATION_WM_CLOSE_REQUEST:
		BeginShutdown()
	
func StartServer():
	network.create_server(port, max_players)
	Authentication.InitAuth()
	multiplayer.multiplayer_peer = network
	Logging.log_notice("[SERVER] Network connection open on port "+str(port))
	if OS.has_feature("editor"):
		Logging.log_notice("[SERVER] Running in editor.")
	
	network.connect("peer_connected", Callable(self, "_Peer_Connected"))
	network.connect("peer_disconnected", Callable(self, "_Peer_Disconnected"))
	
func _Peer_Connected(player_id):
	Logging.log_notice("[GAME] User "+str(player_id)+" Connected from IP "+str(network.get_peer(player_id).get_remote_address()))
	rpc_id(player_id, "ClientRPC_SendLoginToken")
	
func _Peer_Disconnected(player_id):
	Logging.log_notice("[GAME] User "+str(player_id)+" Disconnected")
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		var player_node : PlayerContainer = DataRepository.PlayerMgmt.get_node(str(player_id))
		if player_node.CurrentActiveCharacter:
			player_node.CurrentActiveCharacter.WriteJSON(player_node.CurrentActiveCharacter.CharacterData.uuid)
		await get_tree().create_timer(0.1).timeout
		#DataRepository.remove_pid_assoc(player_id)
		if DataRepository.CurrentState == DataRepository.SERVER_STATE.SERVER_SHUTTING_DOWN:
			return #server is shutting down, don't dispose of nodes until all saves are completed.
		else:
			DataRepository.PlayerMgmt.get_node(str(player_id)).queue_free()
			
func DisconnectAllPeers():
	Logging.log_notice("[SERVER] Total peer disconnect requested...")
	for i in get_tree().get_nodes_in_group("players"):
		rpc_id(i.associated_pid, "Disconnect", "Disconnected: \nThe server requested all peers be disconnected.")
		network.disconnect_peer(i.associated_pid)
	if DataRepository.PlayerMgmt.get_children().size() == 0:
		Logging.log_notice("[SERVER] All peers disconnected!")
		all_peers_disconnected.emit()

#player state / synch start
		
func GeneratePlayerStates(uuid, state):
	player_state_collection[uuid] = state
	
@rpc("any_peer", "unreliable") func ServRPC_RequestWorldState():
	var player_id = multiplayer.get_remote_sender_id()
	rpc_id(player_id, "RecieveWorldState", DataRepository.stateprocessing.GenerateWorldStateForUser(player_id))
	
@rpc("any_peer") func ServRPC_FetchServerTime(client_time):
	var player_id = multiplayer.get_remote_sender_id()
	rpc_id(player_id, "ReturnServerTime", Time.get_unix_time_from_system()*1000, client_time)
	
@rpc("any_peer") func ServRPC_DetermineLatency(client_time):
	var player_id = multiplayer.get_remote_sender_id()	
	rpc_id(player_id, "ReturnLatency", client_time)
	
#player state / synch end



#client state reporting

@rpc("any_peer") func ServRPC_RecieveClientState(client_state):
	var player_id = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		DataRepository.PlayerMgmt.get_node(str(player_id)).HandleStateUpdate(client_state)
		
func SetClientState(client_state, player_id): #forcefully sets a client's state.
	rpc_id(player_id, "RecieveClientStateSync", client_state)

#end client state reporting



#movement request start

@rpc("any_peer") func ServRPC_RequestColliderMovement(vector, direction):
	var playerid = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(playerid)):
		if DataRepository.PlayerMgmt.get_node(str(playerid)).CurrentActiveCharacter:
			var pid_collider = DataRepository.PlayerMgmt.get_node(str(playerid)).CurrentActiveCharacter.CurrentCollider
			pid_collider.UpdateVector(vector, direction)
			
@rpc("any_peer") func ServRPC_RequestDash():
	var playerid = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(playerid)):
		if DataRepository.PlayerMgmt.get_node(str(playerid)).CurrentActiveCharacter:
			DataRepository.PlayerMgmt.get_node(str(playerid)).CurrentActiveCharacter.SetDash()

#movement request end

#chat start

@rpc("any_peer") func ServRPC_RecieveChat(msg:Dictionary):
	var playerid = multiplayer.get_remote_sender_id()
	if msg.size() != 3: #malformed - will cause errors. someone's doing something fucky.
		Logging.log_error("[CHAT] Malformed chat message from "+str(playerid)+DataRepository.PlayerMgmt.get_node(str(playerid)).PlayerData.Username + "contents "+str(msg))
		return
	var NewMsg : Dictionary
	var originator : String
	var is_global : bool

	if DataRepository.PlayerMgmt.has_node(str(playerid)):
		if Helpers.HandleCommands(msg, playerid): #command handling - the helpers singleton will do everything else from here if there's a command.
			return
			
		is_global = ChatHandler.IsMsgGlobal(msg)
		
		if is_global != true:
			originator = Helpers.GetMessageOriginator(false, playerid)
		else:
			originator = Helpers.GetMessageOriginator(true, playerid)
			
		NewMsg = ChatHandler.ParseChat(msg, originator, is_global, DataRepository.PlayerMgmt.get_node(str(playerid)))
		
		if NewMsg["is_global"] != true:
			SendLocalChat(NewMsg, originator, playerid)
		else:
			SendGlobalChat(NewMsg, originator, playerid)
					
func SendGlobalChat(msg:Dictionary, originator, playerid): #used server-side for announcements and such.
	var global_players : Array = get_tree().get_nodes_in_group("players")
	for i in global_players:
		var sending_pid : int = int(Helpers.Username2PID(i.PlayerData.Username))
		if DataRepository.PlayerMgmt.has_node(str(sending_pid)):
			rpc_id(sending_pid, "RecieveChat", msg["output"])
	
func SendLocalChat(msg:Dictionary, originator, playerid):
	var pid_collider = DataRepository.PlayerMgmt.get_node(str(playerid)).CurrentActiveCharacter.CurrentCollider
	var colliders_in_range : Array = get_tree().get_nodes_in_group("active_characters")
	for I in colliders_in_range:
		var sender_pos : Vector2 = DataRepository.PlayerMgmt.get_node(str(playerid)).CurrentActiveCharacter.CurrentCollider.get_global_position()
		var character = DataRepository.PlayerMgmt.get_node(str(playerid)).CurrentActiveCharacter
		var distance : float = sender_pos.distance_to(I.CurrentCollider.get_global_position())
		var reciever_id = Helpers.Username2PID(I.ActiveController.PlayerData.Username)
		if I.CurrentMap != character.CurrentMap:
			continue
		if distance < msg["distance"]:
			rpc_id(int(reciever_id), "RecieveChat", msg["output"])
			
func SendSingleChat(msg:Dictionary, playerid):
	rpc_id(int(playerid), "RecieveChat", msg)
#chat end

#permissions

@rpc("any_peer") func ServRPC_SendPermissions():
	var player_id = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		rpc_id(player_id, "RecievePermissions", DataRepository.Admin.RetrievePermissions(get_node(str(player_id))))

#end permissions

#tickets
	
func PushTicketsToClient(pid:int, tickets):
	rpc_id(pid, "RecieveTickets", tickets, false)

func UpdateTicket(pid:int, ticket_number:String, ticket:Dictionary):
	rpc_id(pid, "ClientRPC_UpdateTicket", ticket_number, ticket)
	
@rpc("any_peer") func ServRPC_UpdateSoloTicket(ticket_number:String):
	var player_id = multiplayer.get_remote_sender_id()
	DataRepository.Admin.UpdateTicketMessages(ticket_number)

@rpc("any_peer") func ServRPC_GetTickets(for_staff:bool = false):
	var player_id = multiplayer.get_remote_sender_id()
	var return_dict
	var all_tickets = false
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		if for_staff:
				if DataRepository.Admin.CheckPermissions(DataRepository.Admin.RANK_FLAGS.PLAYER_NOTES, DataRepository.PlayerMgmt.get_node(str(player_id))):
					return_dict = DataRepository.Admin.GetAllTickets()
					all_tickets = true
					rpc_id(player_id, "RecieveTicketsAdmin", return_dict)
				else:
					Logging.log_warning("[ADMIN] User "+Helpers.PID2Username(player_id)+" attempted to retrieve all tickets without being staff.")
		else:
			return_dict = DataRepository.Admin.GetTicketsWithUser(Helpers.PID2Username(player_id))
			rpc_id(player_id, "RecieveTickets", return_dict, all_tickets)
	
@rpc("any_peer") func ServRPC_OpenTicket(title:String, details:String, with_user:String, critical:bool = false):
	var player_id = multiplayer.get_remote_sender_id()
	if with_user:
		if DataRepository.Admin.CheckPermissions(DataRepository.Admin.RANK_FLAGS.PLAYER_NOTES, DataRepository.PlayerMgmt.get_node(str(player_id))):
			DataRepository.Admin.CreateTicket(Helpers.PID2Username(player_id), with_user, title, details, critical, true)
	else:
		DataRepository.Admin.CreateTicket(Helpers.PID2Username(player_id), "", title, details, critical, false)
		
@rpc("any_peer") func ServRPC_CloseTicket(ticket_number:String):
	var player_id = multiplayer.get_remote_sender_id()
	DataRepository.Admin.CloseTicket(ticket_number, player_id)
		
@rpc("any_peer") func ServRPC_SendMessageToTicket(message:String, ticket_number:String):
	DataRepository.Admin.AddMessageToTicket(message, ticket_number, str(multiplayer.get_remote_sender_id()))
	
@rpc("any_peer") func ServRPC_ClaimTicket(ticket_number:String):
	var player_id = multiplayer.get_remote_sender_id()
	DataRepository.Admin.ClaimTicket(Helpers.PID2Username(player_id), ticket_number)
	
@rpc("any_peer") func ServRPC_AddUserToTicket(username:String, ticket_number:String):
	var player_id = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		if DataRepository.Admin.CheckPermissions(DataRepository.Admin.RANK_FLAGS.PLAYER_NOTES, DataRepository.PlayerMgmt.get_node(str(player_id))):
			DataRepository.Admin.AddUserToTicket(username, ticket_number)
		else:
			Logging.log_warning(Helpers.PID2Username(player_id)+" attempted to access admin functions while not authenticated.")
#tickets end

#notes begin

@rpc("any_peer") func ServRPC_AddPlayerNote(username:String, title:String, note:String):
	var player_id = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		if DataRepository.Admin.CheckPermissions(DataRepository.Admin.RANK_FLAGS.PLAYER_NOTES, DataRepository.PlayerMgmt.get_node(str(player_id))):
			DataRepository.Admin.AddPlayerNote(username, title, note, player_id)
		else:
			Logging.log_notice("User "+Helpers.PID2Username(player_id)+" tried to edit a player's notes without permissions.")
			
@rpc("any_peer") func ServRPC_RemovePlayerNote(username:String, note_number:String):
	var player_id = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		if DataRepository.Admin.CheckPermissions(DataRepository.Admin.RANK_FLAGS.PLAYER_NOTES, DataRepository.PlayerMgmt.get_node(str(player_id))):
			DataRepository.Admin.RemovePlayerNote(username, note_number, player_id)
		else:
			Logging.log_notice("User "+Helpers.PID2Username(player_id)+" tried to edit a player's notes without permissions.")
	
@rpc("any_peer") func ServRPC_EditPlayerNote(username:String, note_number:String, new_note:String):
	var player_id = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		if DataRepository.Admin.CheckPermissions(DataRepository.Admin.RANK_FLAGS.PLAYER_NOTES, DataRepository.PlayerMgmt.get_node(str(player_id))):
			DataRepository.Admin.EditPlayerNote(username, note_number, new_note, player_id)
		else:
			Logging.log_notice("User "+Helpers.PID2Username(player_id)+" tried to edit a player's notes without permissions.")
			
@rpc("any_peer") func ServRPC_GetPlayerNotes():
	var player_id = multiplayer.get_remote_sender_id()
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		if DataRepository.Admin.CheckPermissions(DataRepository.Admin.RANK_FLAGS.PLAYER_NOTES, DataRepository.PlayerMgmt.get_node(str(player_id))):
			rpc_id(player_id, "RecievePlayerNotes", DataRepository.Admin.GetPlayerNotes())
		else:
			Logging.log_notice("User "+Helpers.PID2Username(player_id)+" tried to view player notes without permissions.")

#notes end

#misc start

@rpc("any_peer") func ServRPC_IsClientAdmin():
	var player_id = multiplayer.get_remote_sender_id()
	var decision = false
	if DataRepository.PlayerMgmt.has_node(str(player_id)):
		if DataRepository.Admin.CheckPermissions(DataRepository.Admin.RANK_FLAGS.IS_STAFF, DataRepository.PlayerMgmt.get_node(str(player_id))):
			decision = true
	rpc_id(player_id, "VerifyClientIsAdmin", decision)

@rpc("any_peer") func ServRPC_GetCurrentPlayers():
	var player_id = multiplayer.get_remote_sender_id()
	rpc_id(player_id, "RecieveCurrentPlayers", Helpers.GetCurrentPlayerList())

#misc end

#map sync start

func SyncClientMap(pid:int, mapname:String):
	if DataRepository.PlayerMgmt.has_node(str(pid)):
		var playernode : PlayerContainer = DataRepository.PlayerMgmt.get_node(str(pid))
		if playernode.ClientState != DataRepository.CLIENT_STATE_LIST.CLIENT_INGAME:
			return
	rpc_id(pid, "ClientRPC_RecieveMapSync", mapname)
	
func SetClientWarping(client:int):
	rpc_id(client, "ClientRPC_SetWarpingTrue")

#map sync end

#inventory handling and sync begin

func BindClientInventory(pid, inventory):
	rpc_id(pid, "ClientRPC_BindNetworkedInventories", inventory)

#inventory handling and sync end

#area entered handling

func NotifyPlayerAreaEntered(pid, text, subtext):
	rpc_id(pid, "ClientRPC_NotifyPlayerAreaEntered", text, subtext)

#end area entered handling

@rpc("any_peer") func ServRPC_RecieveLoginToken(token):
	HandleLoginToken(multiplayer.get_remote_sender_id(), token)
	
func HandleLoginToken(pid, token):
	
	if Authentication.valid_tokens.has(token) && token != "":
		for i in get_tree().get_nodes_in_group("players"):
			if i.PlayerData.Username == Authentication.valid_tokens[token]["user"]:
				DataRepository.pid_to_username[str(pid)] = {"username":Authentication.valid_tokens[token]["user"]}
				DataRepository.remove_pid_assoc(i.name)
				i.set_name(StringName(str(pid)))
