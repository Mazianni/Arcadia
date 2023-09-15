class_name PlayerContainer extends PlayerDataContainerBase

var ActiveCharacterPath = preload("res://Scenes/Instances/ActiveCharacter.tscn")

var PlayerStats 
var HasLoaded = false
var PlayerData : PlayerDataResource = PlayerDataResource.new()
var associated_uuid
var associated_pid # godot node names are a special type in 4.0, not strings.
var CurrentActiveCharacter : ActiveCharacter
var ClientState

signal loaded(pid)
signal load_failed(pid)

func _ready():
	connect("tree_exiting", Callable(self, "OnDeleted"))
	await get_tree().create_timer(0.1).timeout # wait for a little while for username to populate.
	LoadSaveData()
	loaded.connect(Callable(Authentication, "SendPlayerCharacterList"))
	
func _process(delta):
	DataPopulatedCallback()
	
func MigrateSaveData(): #IMPL whatever the fuck this was
	return true

func HandleStateUpdate(client_state):
	if not client_state:
		Logging.log_error("[PLAYER CONTAINER] HandleStateUpdate called with a null arg on "+name+" "+PlayerData.Username)
		return
		
	match client_state:
		DataRepository.CLIENT_STATE_LIST.CLIENT_PREGAME:
			ClientState = DataRepository.CLIENT_STATE_LIST.CLIENT_PREGAME
			if CurrentActiveCharacter:
				Logging.log_notice("[PLAYER CONTAINER] ClientState for "+name+" "+PlayerData.Username+" going from INGAME to PREGAME.")
				if CurrentActiveCharacter.CurrentCollider:
					CurrentActiveCharacter.CurrentCollider.queue_free()
				CurrentActiveCharacter.queue_free()
				
		DataRepository.CLIENT_STATE_LIST.CLIENT_INGAME:
			Logging.log_notice("[PLAYER CONTAINER] ClientState for "+name+" "+PlayerData.Username+" going from PREGAME to INGAME.")
			ClientState = DataRepository.CLIENT_STATE_LIST.CLIENT_INGAME
			
func OnDeleted():
	if DataRepository.CurrentState == DataRepository.SERVER_STATE.SERVER_SHUTTING_DOWN:
		return
	WriteSaveData()

func CheckSaveDataExists(): #Verify that the directory and JSON file for this player exists; if not, create it with defaults.
	return
#	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData.Username)
#	if not PlayerData.CheckSaveExists(save_dir+"/"+str(PlayerData.Username)+".tres"):
#		WriteSaveData()
		
func LoadSaveData():
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData.Username)
	var save_file = save_dir+"/"+str(PlayerData.Username)+".tres"
	var dir_check = DirAccess.open(save_dir)
	if not dir_check or not dir_check.file_exists(save_file):
		return
	ResourceLoader.load_threaded_request(save_file, "", ResourceLoader.CACHE_MODE_IGNORE)
	PlayerData = ResourceLoader.load_threaded_get(save_file)

func DataPopulatedCallback():
	if HasLoaded == true:
		set_process(false)
	if PlayerData.character_dict != {}:
		HasLoaded = true
		loaded.emit(associated_pid)
		
func WriteSaveData():
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData.Username)
	var save_file = save_dir+"/"+str(PlayerData.Username)+".tres"
	PlayerData.WriteSave(save_file)
	save_callback.emit(name, "PlayerContainer", PlayerData.Username)
	
func DeleteSaveData(charname):
	Logging.log_notice("Deleting character "+charname+" for "+PlayerData.Username)
	var save_dir = DataRepository.saves_directory + "/" + str(PlayerData.Username)
	var save_file = save_dir+"/"+str(charname)+".json"
	var dir : DirAccess = DirAccess.open(save_dir)
	dir.remove(save_file)
	var err = DirAccess.get_open_error()
	if !err:
		Logging.log_notice("Data for " + str(PlayerData.Username)+" character "+charname + " deleted.")
	else:
		Logging.log_error("[FILE] Error encountered during save deletion for "+str(PlayerData.Username)+" with code "+str(err))	
	
func DeleteCharacter(char_name):
	PlayerData.character_dict.erase(char_name)
	DeleteSaveData(char_name)
	WriteSaveData()
	
func CreateActiveCharacter(character_name, player_id):
	Logging.log_notice("Attempting to load existing character for "+str(player_id)+": "+character_name)
	CurrentActiveCharacter = ActiveCharacterPath.instantiate()
	CurrentActiveCharacter.name = character_name
	CurrentActiveCharacter.ActiveController = self
	self.add_child(CurrentActiveCharacter)
	CurrentActiveCharacter.CharacterData.LastPlayed = Time.get_unix_time_from_system()

	
	
	
