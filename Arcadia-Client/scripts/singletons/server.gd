extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 5000
var token
	
func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionFailed():
	print("Failed to Connect.")
		
func _OnConnectionSucceeded():
	print("Connection Succcessful.")
	
remote func FetchToken():
	rpc_id(1, "ReturnToken", token)
	print("Sending token " + str(token))

remote func ReturnTokenVerificationResults(result):
	if result == true:
		get_node("../RootNode/GUI/LoginScreen").queue_free()
	else:
		get_node("../RootNode/GUI/LoginScreen").login_button.disabled = false
	
