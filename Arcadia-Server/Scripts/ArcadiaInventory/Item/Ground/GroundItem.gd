class_name GroundItem extends Node2D

var uuid : String
var held_item : Dictionary
@export var sync_item : PackedByteArray
var CurrentMap : String
var CurrentMapRef : MapBase

@onready var click_catcher : Control = $ClickCatcher

func _ready():
	uuid = InventoryDataRepository.GenerateUUID(self)
	name = uuid
	$Sprite2D.texture = load(held_item["texture"])
	UpdateSyncItem()
	
func UpdateSyncItem():
	sync_item = var_to_bytes(held_item)
	
func pick_up():
	InventoryDataRepository.FreeUUID(uuid)
	CurrentMapRef.ground_items.erase(self)
	CurrentMapRef = null
	return held_item.duplicate(true)
