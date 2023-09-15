extends Node

@onready var background : Node = $BackgroundHolder
@onready var ItemPickup : AudioStreamPlayer = $Audio/ItemPickup
@onready var ItemDrop : AudioStreamPlayer = $Audio/ItemDrop
@onready var InventoryOpen : AudioStreamPlayer = $Audio/InventoryOpen
@onready var InventoryClose : AudioStreamPlayer = $Audio/InventoryClose

var menus : Dictionary = {
	"SkyAndStars":preload("res://scenes/MenuBackgrounds/skyandstars.tscn"),
	"Nebula":preload("res://scenes/MenuBackgrounds/nebula.tscn"),
	"Wintercamp":preload("res://scenes/MenuBackgrounds/wintercamp.tscn")
}

func _ready():
	Gui.ChangeGUIScene("LoginScreen")
	get_tree().get_root().set_multiplayer_authority(1, true)
	var maphandler = preload("res://scenes/Maphandler/Maphandler.tscn").instantiate()
	get_tree().get_root().get_node("Server").add_child(maphandler)
	get_tree().get_root().get_node("Server").maphandler = maphandler
	Globals.maphandler = maphandler
	InventoryPredicate.item_picked_up.connect(Callable(ItemPickup, "play"))
	InventoryPredicate.item_dropped.connect(Callable(ItemDrop, "play"))
	InventoryPredicate.inventory_opened.connect(Callable(InventoryOpen, "play"))
	InventoryPredicate.inventory_closed.connect(Callable(InventoryClose, "play"))
	var new_menu = menus[menus.keys()[randi() % menus.keys().size()]].instantiate()
	$BackgroundHolder.add_child(new_menu)

func _on_SettingsButton_pressed():
	Settings.PopupSettings()
	
func ShowBackground(show:bool):
	if show:
		background.show()
	else:
		background.hide()
