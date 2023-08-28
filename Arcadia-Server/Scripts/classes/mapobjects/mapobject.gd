class_name MapObject extends Node

var type : String
var uuid : String

func _ready():
	if not uuid:
		uuid = DataRepository.uuid_generator.v4()

func GetMapObjectData():
	var dict : Dictionary = {
		"type": type,
		"subdata": GetMapObjectSubData()
	}
	return dict
	
func GetMapObjectSubData():
	return {}
