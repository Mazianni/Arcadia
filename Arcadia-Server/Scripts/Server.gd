extends Node


var network = NetworkedMultiplayerENet.new()
var port = 5000
var max_players = 300

var expected_tokens = []

onready var player_verification_process = get_node("PlayerVerification")

func _ready():
	StartServer()
	
func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	Logging.log_notice("GameServer Started...")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")
	
func _Peer_Connected(player_id):
	print("User "+str(player_id)+" Connected")
	player_verification_process.start(player_id)

func _Peer_Disconnected(player_id):
	print("User "+str(player_id)+" Disconnected")
	get_node(str(player_id)).queue_free()

func _on_TokenExpiration_timeout():
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1,-1,-1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)
		
func FetchToken(player_id):
	rpc_id(player_id, "FetchToken")

remote func ReturnToken(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.Verify(player_id, token)
	
func ReturnTokenVerificationResults(player_id, results):
	rpc_id(player_id, "ReturnTokenVerificationResults", results)
	

	
