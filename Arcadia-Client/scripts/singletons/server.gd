extends Node

var network : NetworkedMultiplayerENet
var ip = "127.0.0.1"
var port = 5000
	
var main_instance = "res://scenes/CharacterSelect.tscn"

var latency_array = []
var decimal_collector : float = 0
var latency = 0
var delta_latency = 0
var client_clock = 0

onready var maphandler = get_tree().get_root().get_node("RootNode/Maphandler")

signal character_list_recieved
signal permissions_recieved(permissions)
signal tickets_recieved(tickets)
signal ticket_update_recieved(ticket, ticket_number)
signal admin_tickets_recieved(tickets)
signal player_list_recieved(playerlist)
signal player_notes_recieved(player_notes)
signal admin_verified(verified)

func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency -= delta_latency
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1
	
func ConnectToServer():
	network = NetworkedMultiplayerENet.new()
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	network.connect("server_disconnected", self, "_OnServerDisconnected")
	
#Connection signals
	
func _OnConnectionFailed():
	print("Failed to Connect.")
	
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
	network.disconnect("server_disconnected", self, "_OnServerDisconnected")
	yield(get_tree().create_timer(1),"timeout")
	get_tree().set_network_peer(null)
	network = null
		
func _OnConnectionSucceeded():
	print("Connection Succcessful.")
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "DetermineLatency")
	self.add_child(timer)
	Globals.client_state = Globals.SERVER_CONNECTION_STATE.CONNECTED
	
func _OnServerDisconnected(): #todo make this return to the login screen.
	Globals.client_state = Globals.SERVER_CONNECTION_STATE.DISCONNECTED
	Globals.client_state = Globals.CLIENT_STATE_LIST.CLIENT_UNAUTHENTICATED	
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
	network.disconnect("server_disconnected", self, "_OnServerDisconnected")
	yield(get_tree().create_timer(1),"timeout")
	get_tree().set_network_peer(null)
	network = null
	if Gui.current_loaded_GUI_name != "LoginScreen":
		Gui.CreateFloatingMessage("Server disconnected! Please login again.", "bad")
		Gui.ChangeGUIScene("LoginScreen")
		maphandler.ClearScenes()
	
#End connection signals

#Player state communication / latency
	
func SendPlayerState(state):
	pass
	
func DetermineLatency():
	if network:
		rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())
	
remote func ReturnLatency(client_time):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range (latency_array.size()-1,-1,-1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency/latency_array.size()
		latency_array.clear()
	
remote func RecieveWorldState(state):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	maphandler.UpdateWorldState(state)
	
remote func ReturnServerTime(server_time, client_time):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency
	
	
#end state/latency
	
#player spawning
remote func SpawnNewPlayer(player_id, spawn_position):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		return
	get_node("../RootNode/MapHandler/ViewportContainer/Viewport/GameRender2D").SpawnNewPlayer(player_id, spawn_position)

remote func DespawnPlayer(player_id):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		return
	get_node("../RootNode/MapHandler/ViewportContainer/Viewport/GameRender2D").DespawnPlayer(player_id)
#end player spawning

#character creation handling start

func GetRaceList():
	rpc_id(1, "BuildRaceList")
	
remote func RecieveRaceList(racelist : Dictionary):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	Globals.RaceList = racelist.duplicate(true)

#character creation handling end

#character selection

func RequestCharacterList():
	rpc_id(1, "ReturnRequestedCharacterList")

remote func RecieveCharacterList(characterlist):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	Globals.CharacterList = characterlist
	emit_signal("character_list_recieved")
		
func SelectCharacter(charname):
	rpc_id(1, "CreateExistingCharacter", charname)
	
func RequestNewCharacter(species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height):
	rpc_id(1, "RequestNewCharacter", species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height)
	
func DeleteCharacter(char_name):
	rpc_id(1, "DeleteCharacter", char_name)
	
remote func LoadWorld(worldname):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	get_tree().get_root().get_node("RootNode/Maphandler").ChangeMap(worldname)
	Globals.client_state = Globals.CLIENT_STATE_LIST.CLIENT_INGAME
	Gui.ChangeGUIScene("MainGameUI")
#end character selection

#login

func Login(username, password, uuid, puuid):
	Server.ConnectToServer()
	yield(get_tree().create_timer(1), "timeout")
	if network:
		rpc_id(1,"Login", username, password, uuid, Globals.persistent_uuid)

func CreateAccount(username, password):
	Server.ConnectToServer()
	yield(get_tree().create_timer(0.1), "timeout")
	rpc_id(1,"CreateAccount", username, password)
	
remote func CreateAccountResults(result, message):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	if(result == false):
		Disconnect()
	if result == true:
		get_node("../RootNode/GUI/LoginScreen")._on_Back_pressed()
		Gui.CreateFloatingMessage("New account created. Please login.", "good")
	else:
		Gui.CreateFloatingMessage(str(message), "bad")
		get_node("../RootNode/GUI/LoginScreen").EnableInputs()
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")

remote func ReturnLogin(status, message):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	if status == false:
		if message:
			Gui.CreateFloatingMessage(str(message), "bad")
		else:
			Gui.CreateFloatingMessage("Incorrect username or password.", "bad")
		get_node("../RootNode/GUI/LoginScreen").EnableInputs()
		network.disconnect("connection_failed", self, "_OnConnectionFailed")
		network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
	else:
		Gui.CreateFloatingMessage("Login successful.", "good")
		Globals.client_state = Globals.CLIENT_STATE_LIST.CLIENT_PREGAME
		Gui.ChangeGUIScene("CharacterSelect")
		
#end login

#movement request start

func RequestMovement(vector, direction):
	rpc_id(1, "RequestColliderMovement", vector, direction)

#movement request end

#chat functions start

func SendChat(msg):
	rpc_id(1, "RecieveChat", msg)
	
remote func RecieveChat(msg):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	if Globals.client_state != Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		return
	ChatManager.CreateNewChatMessage(msg)

#chat functions end

remote func Disconnect(reason : String = ""):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	Globals.client_state = Globals.CLIENT_STATE_LIST.CLIENT_UNAUTHENTICATED
	if(reason):
		Gui.CreateFloatingMessage(reason, "bad")
		
#version checking start
remote func SendVersion():
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	rpc_id(1, "RecieveVersion", Globals.client_version)
	print(Globals.client_version)
	
remote func SendPersistentUUID():
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	rpc_id(1, "RecievePersistentUUID", Globals.persistent_uuid)
#version checking end

#permissions start
func GetClientPermissions():
	rpc_id(1, "SendPermissions")
	
func RecievePermissions(permissions_array:Array):
	emit_signal("permissions_recieved", permissions_array)

#permissions end

#tickets start
	
func GetTickets(for_staff:bool = false):
	rpc_id(1, "GetTickets", for_staff)
	
func GetUpdateOnTicket(ticket_number:String):
	rpc_id(1, "UpdateSoloTicket", ticket_number)
	
remote func RecieveTicketsAdmin(ticket_dict:Dictionary):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	emit_signal("admin_tickets_recieved", ticket_dict)
	
remote func RecieveTickets(ticket_dict:Dictionary, all_tickets:bool = false):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	emit_signal("tickets_recieved", ticket_dict)
	
remote func UpdateTicket(ticket_number:String, ticket_dict:Dictionary):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	emit_signal("ticket_update_recieved",ticket_number, ticket_dict)
	
func OpenTicket(title:String, details:String, with_user:String, critical:bool = false):
	rpc_id(1, "OpenTicket", title, details, with_user, critical)
	
func CloseTicket(ticket_number:String):
	rpc_id(1, "CloseTicket", ticket_number)
	
func ClaimTicket(ticket_number:String):
	rpc_id(1, "ClaimTicket", ticket_number)
	
func SendMessageToTicket(message:String, ticket_number:String):
	rpc_id(1, "SendMessageToTicket", message, ticket_number)
	
func AddUserToTicket(username:String, ticket_number:String):
	rpc_id(1, "AddUserToTicket", username, ticket_number)
#tickets end

#player notes

func RequestNotes():
	rpc_id(1, "GetPlayerNotes")
	
func AddPlayerNote(username:String, title:String, note:String):
	rpc_id(1, "AddPlayerNote", username, title, note)
	
func RemovePlayerNote(username:String, note_number:String):
	rpc_id(1, "RemovePlayerNote", username, note_number)
	
func EditPlayerNote(username:String, note_number:String, new_note:String):
	rpc_id(1, "EditPlayerNote", username, note_number, new_note)

remote func RecievePlayerNotes(note_dict: Dictionary):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	emit_signal("player_notes_recieved", note_dict)

#player notes end

#misc

func GetPlayerList():
	rpc_id(1, "GetCurrentPlayers")
	
remote func RecieveCurrentPlayers(player_list):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	emit_signal("player_list_recieved", player_list)
	
func IsClientAdmin():
	rpc_id(1, "IsClientAdmin")
	
remote func VerifyClientIsAdmin(decision:bool):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	if decision:
		Globals.is_client_admin = true
		emit_signal("admin_verified", decision)

#misc end
