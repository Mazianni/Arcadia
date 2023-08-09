extends MapBase

# DO NOT USE THIS SCRIPT DIRECTLY. MAKE A COPY AND PUT IT IN THE DIRECTORY FOR YOUR MAP, THEN ATTACH THAT COPY.
@export var loot_table : ItemInstantiator

func _ready():
	if loot_table == null:
		loot_table = ItemInstantiator.new()
	loot_table.populate_ground(self, GroundItems)
