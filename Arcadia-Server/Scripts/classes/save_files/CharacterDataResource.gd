class_name CharacterDataResource extends Resource

@export var version : int
@export var uuid : String
@export var Name : String
@export var Species : String
@export var Age : int
@export var Gender : String
@export var Stats : Resource
@export var CharacterInventory : GridInventory
@export var EquippedInventory : RestrictedInventory
@export var CurrencyStorage : CurrencyInventory
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

func WriteSave(path):
	ResourceSaver.save(self, path)
	
func CheckSaveExists(path):
	return ResourceLoader.exists(path)

