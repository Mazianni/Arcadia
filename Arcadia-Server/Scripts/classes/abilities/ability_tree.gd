class_name AbilityTreeBase extends Resource

enum MASTER_CLASSES{CLASS_VOLITION, CLASS_COGNITION, CLASS_ERUDITION}

@export var name : String
@export var master_class : String
@export var texture : String
@export var position_in_tree : Vector2
@export var description_short : String
@export var description_long : String
@export var shadow_color : Color
@export var hidden : bool = false
@export var abilities : Array[Resource]
