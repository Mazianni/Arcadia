class_name PlayerManager extends SubsystemBase

var PlayerContainers : Dictionary = {}
var ActiveCharacters : Dictionary = {}

var PlayerContainersToSave : int = 0
var ActiveCharactersToSave : int = 0

var PlayerContainersSaved : int = 0
var ActiveCharactersSaved : int = 0

@onready var player_container_scene = preload("res://Scenes/Instances/PlayerContainer.tscn")

signal playercontainers_save_complete()
signal activecharacters_save_complete()
signal all_saves_completed()
signal all_peers_disconnected_callback_recieved()

func SubsystemInit(node_name:String):
	subsystem_start_success.emit(name, self)
	
func SubsystemShutdown(node_name:String):
	SaveAllPlayerData(true)
	
func CreatePlayerContainer(player_id, uuid):
	var new_player_container = player_container_scene.instantiate()
	new_player_container.name = str(player_id)
	new_player_container.associated_uuid = uuid
	new_player_container.associated_pid = player_id
	self.add_child(new_player_container, true)
	FillPlayerContainer(new_player_container, player_id, uuid)
	
func FillPlayerContainer(player_container, player_id, uuid):
	player_container.PlayerData["username"] = DataRepository.pid_to_username[str(player_id)]["username"]
	DataRepository.Server.RequestPersistentUUID(player_id)
	
func SaveAllPlayerData(request_disconnect : bool):
	Logging.log_notice("[PLAYER MANAGER] Saving all player data...")
	await get_tree().create_timer(0.01).timeout
	if request_disconnect:
		DataRepository.Server.DisconnectAllPeers()

	AllPeersDisconnectedCallback()

	if not PlayerContainers.size() and not ActiveCharacters.size():
		Logging.log_notice("[PLAYER MANAGER] No connected players.")
		subsystem_shutdown.emit(name, self)
		return
	var tempPlayerContainers = get_tree().get_nodes_in_group("players")
	var tempActiveCharacters = get_tree().get_nodes_in_group("active_characters")
	for c in tempPlayerContainers:
		PlayerContainers[c] = {"saved":false}
	for a in tempActiveCharacters:
		ActiveCharacters[a] = {"saved":false}
	PlayerContainersToSave = PlayerContainers.size()
	ActiveCharactersToSave = ActiveCharacters.size()
	Logging.log_notice("[PLAYER MANAGER] PlayerContainers to save: "+str(PlayerContainers.size()))
	Logging.log_notice("[PLAYER MANAGER] ActiveCharacters to save: "+str(ActiveCharacters.size()))
	for c in ActiveCharacters:
		var containernode : ActiveCharacter = c
		containernode.WriteJSON(containernode.CharacterData["uuid"])
	await AllPlayerCharactersSavedCallback()
	Logging.log_notice("[PLAYER MANAGER] All ActiveCharacters saved.")
	for c in PlayerContainers:
		var containernode : PlayerContainer = c
		containernode.WriteSaveData()
	await AllPlayerContainersSavedCallback()
	Logging.log_notice("[PLAYER MANAGER] All PlayerContainers saved.")
	subsystem_shutdown.emit(name, self)

func ContainerSavedDataCallback(node_name:String, type:String, aux_name:String):
	match type:
		"PlayerContainer":
			PlayerContainers[node_name]["saved"] = true
			PlayerContainersSaved += 1
			Logging.log_notice("[PLAYER MANAGER] Player "+aux_name+" saved. "+str(PlayerContainersSaved)+"/"+str(PlayerContainersToSave)+" PlayerContainers saved.")
		"ActiveCharacter":
			ActiveCharacters[node_name]["saved"] = true
			ActiveCharactersSaved += 1
			Logging.log_notice("[PLAYER MANAGER] Character "+aux_name+" saved. "+str(ActiveCharactersSaved)+"/"+str(ActiveCharactersToSave)+" ActiveCharacters saved.")
	if PlayerContainersSaved == PlayerContainersToSave:
		playercontainers_save_complete.emit()
	if ActiveCharactersSaved == ActiveCharactersToSave:
		activecharacters_save_complete.emit()
		
func AllPeersDisconnectedCallback():
	await DataRepository.Server.all_peers_disconnected
	return true
	
func AllPlayerContainersSavedCallback():
	await playercontainers_save_complete
	return true
	
func AllPlayerCharactersSavedCallback():
	await activecharacters_save_complete
	return true
