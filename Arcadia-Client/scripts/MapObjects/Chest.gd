extends MapObject

var associated_id : String

func _on_label_gui_input(event):
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var aux_dict : Dictionary = {
				"inv_one":associated_id,
			}
			InventoryPredicate.ClientPredicate_GenerateInventoryRequest(PredicateBase.REQUESTTYPE.INVENTORY_OPEN, aux_dict)
			print("dsadgh")

func ApplyProperties(dict:Dictionary):
	if dict.has("chest_id"):
		associated_id = dict["chest_id"]
