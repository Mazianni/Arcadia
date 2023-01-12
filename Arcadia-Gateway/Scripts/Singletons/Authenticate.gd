extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 2500

func _ready():
	ConnectToServer()
	
func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	Logging.log_notice("Connecting to Authentication Server...")
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionFailed():
	Logging.log_warning("Failed to connect to Authentication Server!")

func _OnConnectionSucceeded():
	Logging.log_notice("Successfully connected to Authentication server.")

func AuthenticatePlayer(username, password, player_id):
	Logging.log_notice("Authentication request sent.")
	rpc_id(1, "AuthenticatePlayer", username, password, player_id)
	
remote func AuthenticationResults(results, player_id, token):
	Logging.log_notice("[AUTH] Auth results recieved for PID " + str(player_id) +" replying to login request...")
	Gateway.ReturnLoginRequest(results, player_id, token)
	
