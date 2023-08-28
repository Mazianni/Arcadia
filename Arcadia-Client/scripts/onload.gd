extends Node

@onready var background : ParallaxBackground = $ParallaxBackground
@onready var ItemPickup : AudioStreamPlayer = $Audio/ItemPickup
@onready var ItemDrop : AudioStreamPlayer = $Audio/ItemDrop
@onready var InventoryOpen : AudioStreamPlayer = $Audio/InventoryOpen
@onready var InventoryClose : AudioStreamPlayer = $Audio/InventoryClose

func _ready():
	Gui.ChangeGUIScene("LoginScreen")
	get_tree().get_root().set_multiplayer_authority(1, true)
	InventoryPredicate.item_picked_up.connect(Callable(ItemPickup, "play"))
	InventoryPredicate.item_dropped.connect(Callable(ItemDrop, "play"))
	InventoryPredicate.inventory_opened.connect(Callable(InventoryOpen, "play"))
	InventoryPredicate.inventory_closed.connect(Callable(InventoryClose, "play"))

func _on_SettingsButton_pressed():
	Settings.PopupSettings()
	
func ShowBackground(show:bool):
	if show:
		background.show()
	else:
		background.hide()
