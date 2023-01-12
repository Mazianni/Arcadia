extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 2400
onready var gameserver = get_node("/root/Server")

func _ready():
	ConnectToServer()
	
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func ConnectToServer():
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	Logging.log_notice("Connecting to Nexus Server...")
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionSucceeded():
	Logging.log_notice("Connected to Nexus Server.")

func _OnConnectionFailed():
	Logging.log_warn("Disconnected from Nexus Server.")
	
remote func RecieveLoginToken(token):
	gameserver.expected_tokens.append(token)
	Logging.log_notice("[AUTH] Token " + str(token) + "Recieved.")
