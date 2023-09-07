extends Window

@onready var inv_anchor = $ColorRect/CenterContainer/VBoxContainer
var current_inv_panel : InventoryUI

func _on_close_requested():
	var dict : Dictionary = {
		"inv_one" : current_inv_panel.inv_id
	}
	InventoryPredicate.ClientPredicate_GenerateInventoryRequest(InventoryPredicate.REQUESTTYPE.INVENTORY_CLOSE)
	gui_release_focus()
	
func AdjustSize(newsize):
	self.size.y += newsize.y / 2
	
func _ready():
	if not current_inv_panel:
		var inv_panel_res = load("res://scripts/ArcadiaInventory/UI/Scenes/InventoryBox.tscn")
		current_inv_panel = inv_panel_res.instantiate()
		current_inv_panel.emit_size.connect(Callable(self, "AdjustSize"))
		current_inv_panel.inv_id = Globals.inventory_uuids["main"]
		inv_anchor.add_child(current_inv_panel)

func _on_visibility_changed():
	if current_inv_panel:
		current_inv_panel.UpdateInventory()
