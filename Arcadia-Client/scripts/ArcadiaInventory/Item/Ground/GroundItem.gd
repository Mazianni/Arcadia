
class_name GroundItem extends Node2D
var uuid : String
var held_item : Dictionary
var CurrentMap : String
var CurrentMapRef : MapBase

@onready var click_catcher : Control = $ClickCatcher

func _ready():
	$Sprite2D.texture = load(held_item["texture"])
	#click_catcher.size = $Sprite2D.texture.size
	
func pick_up():
	CurrentMapRef.ground_items.erase(self)
	CurrentMapRef = null
	call_deferred("queue_free")
	return held_item.duplicate(true)

func _on_click_catcher_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var aux_dict : Dictionary = {
				"ground_item":uuid,
				"map":CurrentMap
			}
			InventoryPredicate.ClientPredicate_GenerateInventoryRequest(PredicateBase.REQUESTTYPE.INVENTORY_PICKUP, aux_dict)
