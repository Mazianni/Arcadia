extends AbilityBase

var projectile_res = load("res://Scenes/Instances/projectiles/projectile.tscn")

func UnlockAbility(player:ActiveCharacter):
	return

func UseAbility(casting_character:ActiveCharacter, origin_node:Node2D, target:Node2D):
	var new_projectile = projectile_res.instantiate()
	var map = DataRepository.mapmanager.GetMap(origin_node.CurrentMap)
	map.get_node("PrimarySort/ObjectSortContainer/Projectiles").add_child(new_projectile)
	new_projectile.position = origin_node.get_global_position()
	new_projectile.Cast(origin_node, target)
	new_projectile.ability_name = ability_name
