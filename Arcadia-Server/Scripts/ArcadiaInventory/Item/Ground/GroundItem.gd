class_name GroundItem extends Node2D

var uuid : String
var held_item : Dictionary
var CurrentMap : String
var CurrentMapRef : MapBase

@onready var click_catcher : Control = $ClickCatcher

func _ready():
	uuid = InventoryDataRepository.GenerateUUID(self)
	name = uuid
	$Sprite2D.texture = load(held_item["texture"])
	
func pick_up():
	InventoryDataRepository.FreeUUID(uuid)
	CurrentMapRef.ground_items.erase(self)
	CurrentMapRef = null
	return held_item.duplicate(true)
