extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 5252
var max_players = 100

func _ready():
	StartServer()
		
func _process(delta):
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
	
func StartServer():
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	Logging.log_notice("Gateway server started.")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")
	
func _Peer_Connected(player_id):
	Logging.log_notice("User "+str(player_id)+" Connected")

func _Peer_Disconnected(player_id):
	Logging.log_notice("User "+str(player_id)+" Disconnected")
	
remote func LoginRequest(username, password):
	Logging.log_notice("Login request recieved.")
	var player_id = custom_multiplayer.get_rpc_sender_id()
	Authenticator.AuthenticatePlayer(username, password, player_id)

func ReturnLoginRequest(result, player_id, token):
	rpc_id(player_id, "ReturnLoginRequest", result, token)
	network.disconnect_peer(player_id)
