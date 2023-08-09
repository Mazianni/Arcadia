class_name PlayerDataResource extends Resource

@export var PlayerStats : Dictionary
@export var Username : String
@export var Displayname : String
@export var Rank : String
@export var OOC_Color : Color
@export var character_dict : Dictionary
@export var last_login : int
@export var persistent_uuid : String

func WriteSave(path):
	ResourceSaver.save(self, path)
	
func CheckSaveExists(path):
	return ResourceLoader.exists(path)
