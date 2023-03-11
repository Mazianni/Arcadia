extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 5252
var cert = load("res://certificate/X509_certificiate.crt")

var username
var password
var new_account = false

func _ready():
	pass
	
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	
func ConnectToServer(_username, _password, _new_acc):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.use_dtls = true
	network.dtls_verify = false
	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	new_account = _new_acc
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
	get_node("../RootNode/GUI/LoginScreen").create_account_button.disabled = false
	
func _OnConnectionSucceeded():
	print("Successfully connected to login server.")
	if new_account == true:
		RequestCreateAccount()
	else:
		RequestLogin()
	
func RequestLogin():
	print("Connecting to gateway to request login...")
	rpc_id(1, "LoginRequest", username, password, new_account, Globals.uuid)
	username = ""
	password = ""
	new_account = 0
	
func RequestCreateAccount():
	print("Requesting new account...")
	rpc_id(1, "CreateAccountRequest", username, password)
	username = ""
	password = ""
	

	
	
