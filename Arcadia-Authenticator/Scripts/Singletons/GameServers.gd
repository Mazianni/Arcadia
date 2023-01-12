extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 2400
var max_players = 100
var gameserverlist = {}

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
	Logging.log_notice("Nexus server started...")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(gameserver_id):
	Logging.log_notice("Game Server "+str(gameserver_id)+" Connected.")
	gameserverlist["GameServer1"] = gameserver_id
	Logging.log_notice("Game Server Dict is now:" + str(gameserverlist["GameServer1"]))

func _Peer_Disconnected(gameserver_id):
	Logging.log_warning("Game Server "+str(gameserver_id)+" Disconnected!")
	
func DistributeLoginToken(token, gameserver):
	var gameserver_peer_id = gameserverlist["GameServer1"]
	rpc_id(gameserver_peer_id, "RecieveLoginToken", token)
