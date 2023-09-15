extends AbilityBase


func UseAbility(casting_character:ActiveCharacter, origin_node:Node2D, target:Node2D):
	casting_character.ApplyDamage(100, "normal")
	casting_character.SetDash()
	var timer = Timer.new()
	CombatHandler.add_child(timer)
	timer.one_shot = true
	timer.start(5)
	await timer.timeout
	casting_character.ApplyHeal(100)
	timer.queue_free()
