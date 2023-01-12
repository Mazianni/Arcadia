extends Node

var network = NetworkedMultiplayerENet.new()
var port = 2500
var max_servers = 5

func _ready():
	StartServer()
	
func StartServer():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	Logging.log_notice("Authentication Server Started...")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")
	
func _Peer_Connected(gateway_id):
	Logging.log_notice("Gateway "+str(gateway_id)+" Connected")

func _Peer_Disconnected(gateway_id):
	Logging.log_notice("Gateway "+str(gateway_id)+" Disconnected")
	
remote func AuthenticatePlayer(username, password, player_id):
	var token
	Logging.log_notice("Authentication request recieved.")
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	Logging.log_notice("Starting authentication!")
	if not PlayerData.PlayerIDs.has(username):
		Logging.log_warning("User name invalid.")
		result = false
	elif not PlayerData.PlayerIDs[username].Password == password:
		Logging.log_warning("Incorrect password.")
		result = false
	else:
		Logging.log_notice("Authentication successful.")
		result = true
	
		randomize()
		var random_number = randi()
		var hashed = str(random_number).sha256_text()
		var timestamp = str(OS.get_unix_time())
		var gameserver = "GameServer1"
		token = hashed+timestamp
		Logging.log_notice("Token generated for PID: " + str(player_id) + " Token: " + str(token))
		GameServers.DistributeLoginToken(token, gameserver)
		
	Logging.log_notice("Sending authentication results to gateway...")
	rpc_id(gateway_id, "AuthenticationResults", result, player_id, token)
	
