class_name AbilityBase extends Resource

# "name":String,
# "desc":String,
# "position_in_tree":Vector2,
# "texture":String,
# "point_cost":int,
# "requires_spells":Array[String],
# "flags":Array[enum],
# "mastery:bool

@export var ability_name : String 
@export var endurance_cost : int
@export var point_cost : int = 10
@export var texture : String
@export var requires_spells : Array[String]
@export var flags : Array
@export var mastery : bool
@export var position_in_tree : Vector2
@export var gcd_exempt : bool
@export var cooldown : int = 10

func UnlockAbility(player:ActiveCharacter):
	return

func UseAbility(casting_character:ActiveCharacter, origin_node:Node2D, target:Node2D):
	return
