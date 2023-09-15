class_name PlayerManager extends SubsystemBase

var PlayerContainers : Dictionary = {}
var ActiveCharacters : Dictionary = {}

var PlayerContainersToSave : int = 0
var ActiveCharactersToSave : int = 0

var PlayerContainersSaved : int = 0
var ActiveCharactersSaved : int = 0

@onready var player_container_scene = preload("res://Scenes/Instances/PlayerContainer.tscn")
@onready var inventory_resource = preload("res://Resources/Inventory/player_inv_base.tres")
@onready var equip_inv_resource = preload("res://Resources/Inventory/player_equip_base.tres")

signal playercontainers_save_complete()
signal activecharacters_save_complete()
signal all_saves_completed()
signal all_peers_disconnected_callback_recieved()

func SubsystemInit(node_name:String):
	subsystem_start_success.emit(name, self)
	
func SubsystemShutdown(node_name:String):
	SaveAllPlayerData(true)
	
func CreatePlayerContainer(player_id, uuid):
	if DataRepository.Server.has_node(str(player_id)):
		return
	var new_player_container = player_container_scene.instantiate()
	new_player_container.name = str(player_id)
	new_player_container.associated_uuid = uuid
	new_player_container.associated_pid = player_id
	self.add_child(new_player_container, true)
	FillPlayerContainer(new_player_container, player_id, uuid)
	
func FillPlayerContainer(player_container, player_id, uuid):
	player_container.PlayerData.Username = DataRepository.pid_to_username[str(player_id)]["username"]
	Authentication.RequestPersistentUUID(player_id)
	
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
		containernode.WriteJSON(containernode.CharacterData.uuid)
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
	
# inventory serialization/sync
			
func CreateNewCharacter(uuid, species_name, character_name, age, hair_color, skin_color, hair_style, ear_style, tail_style, accessory_one_style, gender, height, pid):
	var result : bool = true
	var message : String = "New character "+character_name+" \ncreated successfully"
	var CharacterData : CharacterDataResource = CharacterDataResource.new()
	var BaseSpecies = DataRepository.races[species_name]
	CharacterData.uuid = uuid
	CharacterData.Species = species_name
	CharacterData.Name = character_name
	CharacterData.Age = age
	CharacterData.Gender = gender
	CharacterData.hair_style = hair_style
	CharacterData.hair_color = hair_color
	CharacterData.skin_color = skin_color
	CharacterData.ear_style = ear_style
	CharacterData.tail_style = tail_style
	CharacterData.accessory_one_style = accessory_one_style
	CharacterData.height = height
	CharacterData.LastMap = DataRepository.spawns[BaseSpecies.valid_spawns[0]]["MapName"]
	CharacterData.LastPosition = DataRepository.spawns[BaseSpecies.valid_spawns[0]]["pos"]
	CharacterData.MainInventory = inventory_resource.duplicate(true)
	CharacterData.MainInventory._init()
	CharacterData.MainInventory.GenerateUnique()
	CharacterData.EquipmentInventory = equip_inv_resource.duplicate(true)
	CharacterData.EquipmentInventory._init()
	CharacterData.EquipmentInventory.GenerateUnique()
	CharacterData.CoinInventory = inventory_resource.duplicate(true)
	CharacterData.CoinInventory._init()
	CharacterData.CoinInventory.GenerateUnique()
	var save_dir = DataRepository.saves_directory + "/" + str(Helpers.PID2Username((pid)))
	var save_file = save_dir+"/"+str(uuid)+"/"+str(uuid)+".tres"
	var dir_check = DirAccess.open(save_dir)
	if not dir_check or not dir_check.dir_exists(str(uuid)):
		var new_dir = DirAccess.open(DataRepository.saves_directory)
		new_dir.make_dir(str(Helpers.PID2Username((pid))))
		dir_check = DirAccess.open(save_dir)
		dir_check.make_dir(str(uuid))
	CharacterData.WriteSave(save_file)
	Logging.log_notice("New character by name of "+str(character_name)+" created successfully.")
	DataRepository.Server.ReturnNewCharacterCreated(pid, result, message)
	get_node(str(pid)).PlayerData.character_dict[uuid] = character_name
	get_node(str(pid)).WriteSaveData()
