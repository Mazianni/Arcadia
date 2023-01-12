extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 5252

var username
var password

func _ready():
	pass
	
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func ConnectToServer(_username, _password):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	username = _username
	password = _password
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
	
func _OnConnectionFailed():
	print("Failed to connect to Login Server!")
	print("placeholder server offline")
	get_node("../RootNode/GUI/LoginScreen").login_button.disabled = false

func _OnConnectionSucceeded():
	print("Successfully connected to login server.")
	RequestLogin()
	
func RequestLogin():
	print("Connecting to gateway to request login...")
	rpc_id(1, "LoginRequest", username, password)
	username = ""
	password = ""
	
remote func ReturnLoginRequest(results, token):
	print("Login results recieved.")
	print("Token " + str(token))
	if results == true:
		Server.token = token
		Server.ConnectToServer()
	else:
		print("Username/Password Invalid!")
		get_node("../RootNode/GUI/LoginScreen").login_button.disabled = false
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
	
	
