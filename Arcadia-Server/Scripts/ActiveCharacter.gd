class_name ActiveCharacter extends PlayerDataContainerBase

var BaseSpecies : SpeciesBase
var ActiveController : PlayerContainer
var CurrentPosition : Vector2
var CurrentMap : String
var CurrentCollider : PlayerCollider
var CharacterData : CharacterDataResource = CharacterDataResource.new()
var current_stats : Dictionary = {
	"Vitality": 0,
	"Attunement": 0,
	"Dexterity":0,
	"Endurance":0
}

var unlocked_abilities : Array[AbilityBase]
var health : int = 0
var max_health : int = 0
var health_regen : int = 0

var mana : int = 0
var max_mana : int = 0
var mana_regen : int = 0

var shield : int = 0
var max_shield : int = 0
var shield_regen : int = 0

var next_tick : float = 0

signal load_success(pid, map)
signal load_failed(pid)
signal creation_successful
signal collider_created(pid, map)
signal inventories_created()

signal damage_applied(amount, type)
signal heal_applied(amount)
signal effect_applied(effect_flag)
signal knocked_out()

func _ready():
	connect("tree_exiting", Callable(self, "OnDeleted"))
	load_failed.connect(Callable(DataRepository.Server,"ReturnCharacterLoadFailed"))
	load_failed.connect(Callable(self,"OnLoadFailed"))
	collider_created.connect(Callable(DataRepository.Server, "ReturnCharacterLoaded"))
	load_success.connect(Callable(self, "OnLoadSuccessful"))
	LoadJSON(self.name)

func _process(delta):
	if Time.get_unix_time_from_system() <= next_tick:
		return
	TickResources()
	next_tick = Time.get_unix_time_from_system() + DataRepository.default_tick_rate
		

func OnDeleted():
	if DataRepository.CurrentState == DataRepository.SERVER_STATE.SERVER_SHUTTING_DOWN:
		return
	WriteJSON(CharacterData.uuid)
	if CurrentCollider && is_instance_valid(CurrentCollider):
		CurrentCollider.queue_free()
	if ActiveController && is_instance_valid(ActiveController):
		ActiveController.CurrentActiveCharacter = null
		
func OnLoadFailed(pid):
	DataRepository.Server.SetClientState(DataRepository.CLIENT_STATE_LIST.CLIENT_PREGAME, ActiveController.associated_pid)
	queue_free()
	
func OnLoadSuccessful(pid, map):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData.Username)
	var inventory_save_dir = save_dir+"/"+str(CharacterData.uuid)+"/InventorySaves/"
	CreateCollider()
	load_failed.disconnect(Callable(self,"OnLoadFailed"))
	load_failed.disconnect(Callable(DataRepository.Server,"ReturnCharacterLoadFailed"))
	load_success.disconnect(Callable(self, "OnLoadSuccessful"))
	CalculateStats()
	
func CheckJSONExists(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData.Username)
	var save_file = save_dir+"/"+str(character_name)+".tres"
	var new_dir = DirAccess.open(save_dir)
	var dir_check = new_dir.dir_exists(save_dir+"/"+str(character_name))
	if not dir_check:
		new_dir.make_dir(save_dir+"/"+str(character_name))
	new_dir.open(save_dir+"/"+str(character_name))
	dir_check = new_dir.dir_exists(save_dir+"/"+str(character_name)+"/InventorySaves")
	if not dir_check:
		new_dir.make_dir(save_dir+"/"+str(character_name)+"/InventorySaves")
	return CharacterData.CheckSaveExists(save_file)
	
func LoadJSON(character_name): 
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData.Username)
	var save_file = save_dir+"/"+str(character_name)+"/"+str(character_name)+".tres"
	var inventory_save_dir = save_dir+"/"+str(character_name)+"/InventorySaves/"
	var prev_registered_uuids : Array = []
	CharacterData = ResourceLoader.load(save_file, "", ResourceLoader.CACHE_MODE_IGNORE)
	BaseSpecies = DataRepository.races[CharacterData.Species]
	CharacterData.MainInventory.owner = CurrentCollider
	CharacterData.EquipmentInventory.owner = CurrentCollider
	CharacterData.CoinInventory.owner = CurrentCollider
	
	for i in CharacterData.MainInventory.slots:
		if CharacterData.MainInventory.slots[i].has("uuid"):
			if CharacterData.MainInventory.slots[i]["uuid"] in prev_registered_uuids:
				Logging.log_error("[INVENTORY] Duplicate UUID in MainInv of "+CharacterData.Name+". Forcing re-registration and deleting!")
				CharacterData.MainInventory.slots[i]["uuid"] = InventoryDataRepository.GenerateUUID(CharacterData.MainInventory.slots[i])
				CharacterData.MainInventory.delete_from_inventory(CharacterData.MainInventory.slots[i])
				continue
			prev_registered_uuids.append(CharacterData.MainInventory.slots[i]["uuid"])
			InventoryDataRepository.RegisterExistingUUID(CharacterData.MainInventory.slots[i]["uuid"],CharacterData.MainInventory.slots[i])
	
	for i in CharacterData.EquipmentInventory.slots:
		if CharacterData.EquipmentInventory.slots[i].has("uuid"):
			if CharacterData.EquipmentInventory.slots[i]["uuid"] in prev_registered_uuids:
				Logging.log_error("[INVENTORY] Duplicate UUID in EquipInv of "+CharacterData.Name+". Forcing re-registration and deleting!")
				CharacterData.EquipmentInventory.slots[i]["uuid"] = InventoryDataRepository.GenerateUUID(CharacterData.EquipmentInventory.slots[i])
				CharacterData.EquipmentInventory.delete_from_inventory(CharacterData.EquipmentInventory.slots[i])
				continue
			prev_registered_uuids.append(CharacterData.EquipmentInventory.slots[i]["uuid"])
			InventoryDataRepository.RegisterExistingUUID(CharacterData.EquipmentInventory.slots[i]["uuid"],CharacterData.EquipmentInventory.slots[i])
	
	for i in CharacterData.CoinInventory.slots:
		if CharacterData.CoinInventory.slots[i].has("uuid"):
			InventoryDataRepository.RegisterExistingUUID(CharacterData.CoinInventory.slots[i]["uuid"],CharacterData.CoinInventory.slots[i])
	load_success.emit(ActiveController.associated_pid, CurrentMap)
	
func WriteJSON(character_name):
	var save_dir = DataRepository.saves_directory + "/" + str(ActiveController.PlayerData.Username)
	var save_file = save_dir+"/"+str(character_name)+"/"+str(character_name)+".tres"
	var inventory_save_dir = save_dir+"/"+str(character_name)+"/InventorySaves/"
	CharacterData.LastPosition = CurrentPosition
	CharacterData.MainInventory.owner = null
	CharacterData.EquipmentInventory.owner = null
	CharacterData.CoinInventory.owner = null
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

func CalculateStats():
	for i in current_stats.keys(): 
		current_stats[i] += BaseSpecies.base_stats[i]
		current_stats[i] += CharacterData.level * 2
		current_stats[i] += CharacterData.spent_stats[i]
		#IMPL add equipment handling here
	max_health = current_stats["Vitality"] * 100
	max_mana = current_stats["Endurance"] * 50
	health_regen = max_health/200
	mana_regen = max_mana/200
	
func LoadAbilities():
	pass
#	for i in CharacterData.unlocked_abilities:
#		if AbilityHolder.all_abilities.has(i):
#			unlocked_abilities.append(AbilityHolder.all_abilities[i])
	
func TickResources():
	var next_hp = health + health_regen
	var next_mana = mana + mana_regen
	health = clamp(next_hp, 0, max_health)
	mana = clamp(next_mana, 0, max_mana)
