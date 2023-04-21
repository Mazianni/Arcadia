extends Node


var network = NetworkedMultiplayerENet.new()
var port = 5000
var max_players = 300

var player_state_collection = {}
var characters_awaiting_creation = {}

onready var uuid_generator = preload("res://uuid.gd")
onready var player_container_scene = preload("res://Scenes/Instances/PlayerContainer.tscn")

func _ready():
	StartServer()
	
func StartServer():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	Logging.log_notice("[SERVER] Network connection open on port "+str(port))
	if OS.has_feature("editor"):
		Logging.log_notice("[SERVER] Running in editor.")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")
	
func _Peer_Connected(player_id):
	Logging.log_notice("User "+str(player_id)+" Connected from IP "+str(network.get_peer_address(player_id)))

func _Peer_Disconnected(player_id):
	Logging.log_notice("User "+str(player_id)+" Disconnected")
	if has_node(str(player_id)):
		yield(get_tree().create_timer(0.2), "timeout")
		player_state_collection.erase(player_id)
		rpc_id(0, "DespawnPlayer", player_id)
		DataRepository.remove_pid_assoc(player_id)
		get_node(str(player_id)).queue_free()
#player state / synch start
		
func GeneratePlayerStates(uuid, state):
	player_state_collection[uuid] = state
			
func SendWorldState(world_state):
	rpc_unreliable_id(0, "RecieveWorldState", world_state)
	
remote func FetchServerTime(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)
	
remote func DetermineLatency(client_time):
	var player_id = get_tree().get_rpc_sender_id()	
	rpc_id(player_id, "ReturnLatency", client_time)
	
#player state / synch end

#character handling start
	
remote func SendPlayerCharacterList():
	var player_id = get_tree().get_rpc_sender_id()
	var CharacterList : Dictionary
	var retryload = true
	if has_node(str(player_id)):
		if get_node(str(player_id)).HasLoaded:
			retryload = false
			CharacterList = get_node(str(player_id)).PlayerData.character_dict.duplicate(true)
		else:
			CharacterList = {}
		rpc_id(player_id, "RecieveCharacterList", CharacterList, retryload)
		Logging.log_notice("Sending character list of "+str(player_id)+".")
		print(CharacterList)
			
remote func CreateExistingCharacter(cuuid):
	var player_id = get_tree().get_rpc_sender_id() 
	if has_node(str(player_id)):
			get_node(str(player_id)).CreateActiveCharacter(cuuid, player_id)
			ReturnCharacterLoaded(player_id, get_node(str(player_id)).ActiveCharacter.CurrentMap)
			
remote func RequestNewCharacter(species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height):
	var player_id = get_tree().get_rpc_sender_id()
	var cuuid = uuid_generator.v4()
	if has_node(str(player_id)):
			get_node(str(player_id)).CreateNewActiveCharacter(cuuid, species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height)
			
remote func DeleteCharacter(char_name):
	var player_id = get_tree().get_rpc_sender_id()	
	if has_node(str(player_id)):
		get_node(str(player_id)).DeleteCharacter(char_name)
		
func ReturnCharacterLoaded(pid, worldname):
	rpc_id(pid, "LoadWorld", worldname)
#character handling end

#character creation handling start

remote func BuildRaceList():
	var player_id = get_tree().get_rpc_sender_id()
	var racedict : Dictionary
	var racesubdict : Dictionary
	for i in DataRepository.races.keys():
		var racecheck : SpeciesBase = DataRepository.races[i]
		print(str(racecheck.race_name))
		if racecheck.requires_approval == true:
			if not CheckPlayerApprovedForRace(DataRepository.pid_to_username[str(player_id)]["username"], racecheck.race_name):
				continue
		racesubdict = {
		"Name" : racecheck.race_name,
		"Icon" : racecheck.race_icon,
		"Short Description" : racecheck.race_description_short,
		"Long Description" : racecheck.race_description_extended,
		"ValidSkin" : racecheck.default_skin_colors.duplicate(true),
		"ValidEars" : racecheck.default_ear_styles,
		"ValidTails" : racecheck.default_tail_styles,
		"ValidAccessoryOne" : racecheck.default_accessory_one_styles,
		"ValidSpawns" : racecheck.valid_spawns,
		"Heightminmax" : racecheck.heightminmax.duplicate(true),
		}
		racedict[i] = racesubdict
	rpc_id(player_id, "RecieveRaceList", racedict)
	Logging.log_notice("Sending race list to "+str(player_id))
	
func CheckPlayerApprovedForRace(username, race):
	var approved = false
	if username in DataRepository.approved_users_for_races:
		if race in DataRepository.approved_users_for_races[username]["races"]:
			approved = true
	return approved
	
#character creation handling end

#login start

remote func Login(username, password, uuid):
	var player_id = get_tree().get_rpc_sender_id()
	var message
	Logging.log_notice("[AUTH] Login attempt from PID" + str(player_id) + " UUID " + str(uuid))
	var status = false
	match DataRepository.CurrentState:
		DataRepository.SERVER_STATE.SERVER_LOADING:
			message = "Server not yet ready. Connection refused."
			status = false
		DataRepository.SERVER_STATE.SERVER_SHUTTING_DOWN:
			message = "Server shutting down. Connection refused."
			status = false
	if AuthenticatePlayer(username, password, player_id, uuid):
		status = true
	ReportLoginStatus(player_id, status, message)
				
func ReportLoginStatus(player_id, status, message):
	rpc_id(player_id, "ReturnLogin", status, message)
	if(status == false):
		rpc_id(player_id, "Disconnect", message)

func AuthenticatePlayer(username, password, player_id, player_uuid):
	var token
	Logging.log_notice("[AUTH] Authentication request recieved from "+str(player_id))
	var gateway_id = get_tree().get_rpc_sender_id()
	var result = false
	Logging.log_notice("[AUTH] Starting authentication for "+str(player_id))
	var dbcheckuser = "'"+username+"'"
	if not OS.has_feature("editor"):
		if not DataRepository.GetDataFromDB("playerdata", "username="+dbcheckuser, ["hash", "salt"]):
			Logging.log_warning("[AUTH] Invalid username from " +str(player_id))
			result = false
		elif not VerifyPassword(username, password):
			Logging.log_warning("[AUTH] Incorrect password from "+str(player_id))
			result = false
		else:
			Logging.log_notice("[AUTH] Authentication successful for "+str(player_id))
			result = true
			DataRepository.pid_to_username[str(player_id)] = {"username": str(username), "uuid": str(player_uuid)}
			CreatePlayerContainer(player_id, player_uuid)
			get_node(str(player_id)).PlayerData["lastlogin"] = OS.get_system_time_secs()
	else:
		Logging.log_notice("[AUTH] Running in editor. Authentication not done for "+str(player_id))
		result = true
		DataRepository.pid_to_username[str(player_id)] = {"username": str(username), "uuid": str(player_uuid)}
		CreatePlayerContainer(player_id, player_uuid)
		get_node(str(player_id)).PlayerData["lastlogin"] = OS.get_system_time_secs()	
	Logging.log_notice("[AUTH] Sending authentication results to user " + str(player_id))
	return result
	
remote func CreateAccount(username, password):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var message
	var dbcheckuser = "'"+username+"'"
	var can_create = true
	match DataRepository.CurrentState:
		DataRepository.SERVER_STATE.SERVER_LOADING:
			message = "Server not yet ready. Connection refused."
			result = false
			can_create = false
		DataRepository.SERVER_STATE.SERVER_SHUTTING_DOWN:
			message = "Server shutting down. Connection refused."
			result = false
			can_create = false
	if can_create:
		if DataRepository.GetDataFromDB("playerdata", "username="+dbcheckuser, ["username"]):
			Logging.log_warning("[AUTH] Username already in use.")
			result = false
			message = "Username already in use."
		else:
			result = true
			message = "Account created successfully."
			randomize()
			var salt = str(randi())
			var pepper = password+salt
			var hashed = pepper.sha256_text()
			if DataRepository.WriteNewUserToDB(username, hashed, salt):
				Logging.log_notice("[AUTH] New user "+str(username)+" written to database!")
			else:
				Logging.log_error("[AUTH] Failed to write new user to database!")		
	rpc_id(gateway_id, "CreateAccountResults", result, message)
	
func VerifyPassword(username, password):
	var dbusername = "'"+username+"'"
	var selectedpw : Array = DataRepository.GetDataFromDB("playerdata", "username = "+dbusername, ["hash","salt"])
	var hashed = selectedpw[0]["hash"]
	var salt = selectedpw[0]["salt"]
	var testingpw = password+salt
	if testingpw.sha256_text() == hashed:
		return true
	else:
		return false
		
func CreatePlayerContainer(player_id, uuid):
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(player_id)
	new_player_container.associated_uuid = uuid
	self.add_child(new_player_container, true)
	var player_container = get_node("../Server/"+ str(player_id))
	FillPlayerContainer(player_container, player_id, uuid)
	
func FillPlayerContainer(player_container, player_id, uuid):
	player_container.PlayerData["username"] = DataRepository.pid_to_username[str(player_id)]["username"]

#login end

#movement request start

remote func RequestColliderMovement(vector, direction):
	var playerid = get_tree().get_rpc_sender_id()
	if has_node(str(playerid)):
		var pid_collider = get_node(str(playerid)).ActiveCharacter.CurrentCollider
		pid_collider.UpdateVector(vector, direction)

#movement request end

#chat start

remote func RecieveChat(msg:Dictionary):
	var playerid = get_tree().get_rpc_sender_id()
	if msg.size() != 3: #malformed - will cause errors. someone's doing something fucky.
		Logging.log_error("[CHAT] Malformed chat message from "+str(playerid)+get_node(str(playerid)).PlayerData["Username"] + "contents "+str(msg))
		return
	var NewMsg : Dictionary
	var originator : String
	var is_global : bool

	if has_node(str(playerid)):
		if Helpers.HandleCommands(msg, playerid): #command handling - the helpers singleton will do everything else from here if there's a command.
			return
			
		is_global = ChatHandler.IsMsgGlobal(msg)
		
		if is_global != true:
			originator = Helpers.GetMessageOriginator(false, playerid)
		else:
			originator = Helpers.GetMessageOriginator(true, playerid)
			
		NewMsg = ChatHandler.ParseChat(msg, originator, is_global)
		
		if NewMsg["is_global"] != true:
			SendLocalChat(NewMsg, originator, playerid)
		else:
			SendGlobalChat(NewMsg, originator, playerid)
					
func SendGlobalChat(msg:Dictionary, originator, playerid): #used server-side for announcements and such.
	var global_players : Array = get_tree().get_nodes_in_group("players")
	for i in global_players:
		var sending_pid : int = int(Helpers.Username2PID(i.PlayerData["username"]))
		if has_node(str(sending_pid)):
			rpc_id(sending_pid, "RecieveChat", msg["output"])
	
func SendLocalChat(msg:Dictionary, originator, playerid):
	var pid_collider = get_node(str(playerid)).ActiveCharacter.CurrentCollider
	var colliders_in_range : Array = get_tree().get_nodes_in_group("active_characters")
	for I in colliders_in_range:
		var sender_pos : Vector2 = get_node(str(playerid)).ActiveCharacter.CurrentCollider.get_global_position()
		var character = get_node(str(playerid)).ActiveCharacter
		var distance : float = sender_pos.distance_to(I.CurrentCollider.get_global_position())
		var reciever_id = Helpers.Username2PID(I.ActiveController.PlayerData["username"])
		if I.CurrentMap != character.CurrentMap:
			continue
		if distance < msg["distance"]:
			rpc_id(int(reciever_id), "RecieveChat", msg["output"])
			
func SendSingleChat(msg:Dictionary, playerid):
	rpc_id(playerid, "RecieveChat", msg)
#chat end
