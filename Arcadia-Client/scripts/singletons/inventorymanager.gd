extends Node

var CharacterInventory : GridInventory
var EquippedInventory : RestrictedInventory
var CurrencyStorage : CurrencyInventory

var inventories_instanced : bool = false

@onready var player_inventory_resource = load("res://resources/inventories/player_inventory.tres")
@onready var player_restricted_inv_resource = load("res://resources/inventories/player_equipment_inv.tres")
@onready var player_currency_inv_resource = load("res://resources/inventories/player_currency_inv.tres")

signal inventories_instantiated
signal inventories_cleared

func _ready():
	Globals.scene_changed.connect(Callable(self, "SceneChangeRecieved"))
	
func SceneChangeRecieved(scene_enum):
	if scene_enum == Globals.CLIENT_STATE_LIST.CLIENT_INGAME:
		InstantiatePlayerInventories()
	else:
		ClearPlayerInventories()
		
func InventoriesInstancedCallback():
	await inventories_instantiated
	return true

func InstantiatePlayerInventories():
	CharacterInventory = player_inventory_resource.duplicate(true)
	EquippedInventory = player_restricted_inv_resource.duplicate(true)
	CurrencyStorage = player_currency_inv_resource.duplicate(true)
	inventories_instantiated.emit()
	inventories_instanced = true

func ClearPlayerInventories():
	CharacterInventory = null
	EquippedInventory = null
	CurrencyStorage = null
	inventories_cleared.emit()
	inventories_instanced = false

func DeserializePlayerInventories(bundle_dict:Dictionary):
	if not inventories_instanced:
		InstantiatePlayerInventories()
		InventoriesInstancedCallback()
	print(bundle_dict)
	if bundle_dict.size():
		if bundle_dict["Inventory"].size():
			CharacterInventory.load_from_array(bundle_dict["Inventory"])
		if bundle_dict["Equipped"].size():
			EquippedInventory.load_from_array(bundle_dict["Equipped"])
		if bundle_dict["Currency"].size():
			CurrencyStorage.load_from_array(bundle_dict["Currency"])
