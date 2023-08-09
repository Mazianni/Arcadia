class_name ActiveCharacter extends PlayerDataContainerBase

var BaseSpecies : SpeciesBase
var ActiveController : PlayerContainer
var CurrentPosition : Vector2
var CurrentMap : String
var CurrentCollider : PlayerCollider
var CharacterInventory : GridInventory
var EquippedInventory : RestrictedInventory
var CurrencyStorage : CurrencyInventory
var CharacterData : CharacterDataResource = CharacterDataResource.new()

signal load_success(pid, map)
signal load_failed(pid)
signal creation_successful
signal collider_created(pid, map)
signal inventories_created()

func _ready():
	connect("tree_exiting", Callable(self, "OnDeleted"))
	load_failed.connect(Callable(DataRepository.Server,"ReturnCharacterLoadFailed"))
	load_failed.connect(Callable(self,"OnLoadFailed"))
	collider_created.connect(Callable(DataRepository.Server, "ReturnCharacterLoaded"))
	load_success.connect(Callable(self, "OnLoadSuccessful"))
	if not CheckJSONExists(self.name): #check if JSON exists, if not, create and store defaults.
		WriteJSON(self.name)
	LoadJSON(self.name)


func OnDeleted():
	if DataRepository.CurrentState == DataRepository.SERVER_STATE.SERVER_SHUTTING_DOWN:
		return
	if CurrentCollider && is_instance_valid(CurrentCollider):
		CurrentCollider.queue_free()
	if ActiveController && is_instance_valid(ActiveController):
		ActiveController.CurrentActiveCharacter = null
		
func OnLoadFailed(pid):
	DataRepository.Server.SetClientState(DataRepository.CLIENT_STATE_LIST.CLIENT_PREGAME, ActiveController.associated_pid)
	queue_free()
	
func OnLoadSuccessful(pid, map):
	CreateCollider()
	load_failed.disconnect(Callable(self,"OnLoadFailed"))
	load_failed.disconnect(Callable(DataRepository.Server,"ReturnCharacterLoadFailed"))
	load_success.disconnect(Callable(self, "OnLoadSuccessful"))
	InstancePlayerInventories()
	InventoryInstanceCallback()
	EquippedInventory = CharacterData.EquippedInventory
	CharacterInventory = CharacterData.CharacterInventory
	CurrencyStorage = CharacterData.CurrencyStorage	
	
func InstancePlayerInventories():
	CharacterInventory = DataRepository.player_inventory_resource.duplicate(true)
	CurrencyStorage = DataRepository.player_currency_inv_resource.duplicate(true)
	EquippedInventory = DataRepository.player_restricted_inv_resource.duplicate(true)
	inventories_created.emit()
	
func InventoryInstanceCallback():
	await inventories_created
	return true
		
func CheckJSONExists(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData.Username)
	var save_file = save_dir+"/"+str(character_name)+".tres"
	return CharacterData.CheckSaveExists(save_file)
	
func LoadJSON(character_name): 
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData.Username)
	var save_file = save_dir+"/"+str(character_name)+".tres"
	CharacterData = ResourceLoader.load(save_file, "", ResourceLoader.CACHE_MODE_IGNORE)
	BaseSpecies = DataRepository.races[CharacterData.Species]
	load_success.emit(ActiveController.associated_pid, CurrentMap)
		
func WriteJSON(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData.Username)
	var save_file = save_dir+"/"+str(character_name)+".tres"
	CharacterData.LastPosition = CurrentPosition
	CharacterData.CharacterInventory = CharacterInventory
	CharacterData.EquippedInventory = EquippedInventory
	CharacterData.CurrencyStorage = CurrencyStorage
	CharacterData.WriteSave(save_file)
	
func CreateCollider():
	var new_collider = DataRepository.collider_resource.instantiate()
	var cached_position : Vector2 = CharacterData.LastPosition
	new_collider.name = CharacterData.uuid
	new_collider.ControllingCharacter = self
	CurrentCollider = new_collider
	if CharacterData.LastMap:
		DataRepository.mapmanager.MovePlayerToMapStandalone(new_collider, CharacterData.LastMap, cached_position)
		CurrentMap = CharacterData.LastMap
		CurrentCollider.position = cached_position
	collider_created.emit(ActiveController.associated_pid, CurrentMap)
	collider_created.disconnect(Callable(DataRepository.Server, "ReturnCharacterLoaded"))

