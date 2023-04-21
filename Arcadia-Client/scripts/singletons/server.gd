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
	Gui.CreateFloatingMessage("Server disconnected! Please login again.", "bad")
	Gui.ChangeGUIScene("LoginScreen")
	maphandler.ClearScenes()
	
#End connection signals

#Player state communication / latency
	
func SendPlayerState(state):
	pass
	
func DetermineLatency():
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

func GetCharacterList():
	rpc_id(1, "SendPlayerCharacterList")
	
remote func RecieveCharacterList(characterlist, retryload):
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	if retryload:
		call_deferred("GetCharacterList", 1)
	else:
		Globals.CharacterList = characterlist
		
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

func Login(username, password, uuid):
	Server.ConnectToServer()
	yield(get_tree().create_timer(1), "timeout")
	rpc_id(1,"Login", username, password, uuid)

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

remote func Disconnect():
	if not Helpers.IsServer(get_tree().get_rpc_sender_id()):
		return
	get_tree().network_peer = null
