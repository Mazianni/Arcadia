extends MapBase

# DO NOT USE THIS SCRIPT DIRECTLY. MAKE A COPY AND PUT IT IN THE DIRECTORY FOR YOUR MAP, THEN ATTACH THAT COPY.

func _ready():
	map_name = "Test"
	await get_tree().create_timer(5).timeout
	AddGroundItem(ItemSkeletonRepository.InstanceItemFromSubtype(ItemSkeletonRepository.item_skeletons["Base/Wood"]), Vector2(200,200))
	AddGroundItem(ItemSkeletonRepository.InstanceItemFromSubtype(ItemSkeletonRepository.item_skeletons["Base/Wood/Wood2"]), Vector2(300,200))
