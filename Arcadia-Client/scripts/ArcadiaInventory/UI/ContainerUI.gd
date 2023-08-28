extends Window

@onready var inv_anchor = $ColorRect
var current_inv_panel : InventoryUI
var inv_id : String

func _on_close_requested():
	var dict : Dictionary = {
		"inv_one" : current_inv_panel.inv_id
	}
	InventoryPredicate.ClientPredicate_GenerateInventoryRequest(InventoryPredicate.REQUESTTYPE.INVENTORY_CLOSE)
	gui_release_focus()
	
func CreateUI():
	if not current_inv_panel:
		var inv_panel_res = load("res://scripts/ArcadiaInventory/UI/Scenes/InventoryBox.tscn")
		current_inv_panel = inv_panel_res.instantiate()
		current_inv_panel.inv_id = inv_id
		$ColorRect.add_child(current_inv_panel)
