class_name InventoryUI extends Control

var id : String
var inv_id : String
var width : int
var height : int
var held_contents : Dictionary
var slots_created : bool = false

@onready var PrimaryGrid : GridContainer = $GridContainer
@onready var RenderSlotResource = load("res://scripts/ArcadiaInventory/UI/Scenes/RenderSlot.tscn")

func _ready():
	InventoryPredicate.inventory_recieved.connect(Callable(self, "CheckInventoryUpdate"))
	InventoryPredicate.ClientPredicate_RequestInventoryContents(inv_id)
	InventoryPredicate.inventory_changed.connect(Callable(self, "UpdateInventory"))

func CheckInventoryUpdate(uuid : String, dict : Dictionary):
	if uuid == inv_id:
		held_contents = dict.duplicate(true)
		RenderInventory()
		
func UpdateInventory():
	InventoryPredicate.ClientPredicate_RequestInventoryContents(inv_id)	
		
func CreateSlots():
	if slots_created:
		return
	for i in held_contents[inv_id].keys():
		var new_node : UIRenderSlot = RenderSlotResource.instantiate()
		new_node.location = i
		new_node.name = str(i)
		new_node.holding_ui = self
		PrimaryGrid.add_child(new_node)
	slots_created = true
				
func RenderInventory():
	PrimaryGrid.columns = held_contents["x"]
	CreateSlots()
	for i in held_contents[inv_id].keys():
		var RenderNode : UIRenderSlot = PrimaryGrid.get_node(str(i))
		RenderNode.held_item = held_contents[inv_id][i].duplicate(true)
		RenderNode.UpdateAppearance()
	
	custom_minimum_size = Vector2(held_contents["x"]*40, held_contents["y"]*40)

func OpenInventory(inventory_uuid : String):
	pass
	
func Close():
	queue_free()
