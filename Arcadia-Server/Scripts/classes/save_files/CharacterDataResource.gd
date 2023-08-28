class_name CharacterDataResource extends Resource

@export var version : int
@export var uuid : String
@export var Name : String
@export var Species : String
@export var Age : int
@export var Gender : String
@export var hair_style : String
@export var hair_color : String
@export var ear_style : String
@export var tail_style : String
@export var accessory_one_style : String
@export var skin_color : Color
@export var height : float
@export var LastMap : String
@export var LastPosition : Vector2
@export var LastPlayed : float
@export var MainInventory : InventoryBase
@export var EquipmentInventory : InventoryBase
@export var CoinInventory : InventoryBase
@export var spent_stats : Dictionary = {
	"Vitality": 0,
	"Attunement": 0,
	"Dexterity":0,
	"Endurance":0
}
@export var level : int = 0
@export var exp : float = 0
@export var next_level_exp : int = 0
@export var ability_points : int = 0
@export var skill_points : int = 0
@export var unlocked_abilities : Array[String] = []

func WriteSave(path):
	ResourceSaver.save(self, path)
	
func CheckSaveExists(path):
	return ResourceLoader.exists(path)

