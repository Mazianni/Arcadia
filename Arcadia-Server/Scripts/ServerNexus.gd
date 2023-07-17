extends Node

var network = ENetMultiplayerPeer.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 2400
@onready var gameserver = get_node("/root/Server")

func _ready():
	ConnectToServer()
	
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_multiplayer_peer():
		return
	custom_multiplayer.poll()
	
func ConnectToServer():
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_multiplayer_peer(network)
	
	Logging.log_notice("Connecting to Nexus Server...")
	
	network.connect("connection_failed", Callable(self, "_OnConnectionFailed"))
	network.connect("connection_succeeded", Callable(self, "_OnConnectionSucceeded"))
	
func _OnConnectionSucceeded():
	Logging.log_notice("Connected to Nexus Server.")

func _OnConnectionFailed():
	Logging.log_warn("Disconnected from Nexus Server.")
	
@rpc("any_peer") func RecieveLoginToken(token):
	gameserver.expected_tokens.append(token)
	Logging.log_notice("[AUTH] Token " + str(token) + "Recieved.")
	
@rpc("any_peer") func RecievePlayerPIDUsernameAssoc(player_id, username):
	Logging.log_notice("Recieving PID-Username Assoc for " + username + " PID" + str(player_id))

