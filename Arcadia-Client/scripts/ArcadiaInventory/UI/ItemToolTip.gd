extends Node


var item : Dictionary = {}

func DrawTooltip():
	var new_text : String
	
	if item.has("rarity"):
		match item["rarity"]:
			ItemSkeletonRepository.ITEM_RARITY_FLAGS.ITEM_NORMAL:
				new_text += "[color=#909692][Mundane][/color]"
			ItemSkeletonRepository.ITEM_RARITY_FLAGS.ITEM_ATYPICAL:
				new_text += "[color=#caa1ed][Atypical][/color]"
			ItemSkeletonRepository.ITEM_RARITY_FLAGS.ITEM_RARE:
				new_text += "[color=#78de89][Rare][/color]"
			ItemSkeletonRepository.ITEM_RARITY_FLAGS.ITEM_DIVINE:
				new_text += "[color=#d12866][b][DIVINE][/b][/color]"
			ItemSkeletonRepository.ITEM_RARITY_FLAGS.ITEM_PRIMORDIAL:
				new_text += "[color=#8e1cff][b][PRIMORDIAL][/b][/color]"
	new_text += " "
	new_text += item["item_name"]
	new_text += "\n"
	new_text += "Type: "
	for i in item["item_flags"]:
		if i == ItemSkeletonRepository.ITEM_CLASS_FLAGS.FLAG_RESOURCE:
			new_text += "[color=#909692][Resource][/color]"
		if i == ItemSkeletonRepository.ITEM_CLASS_FLAGS.FLAG_FUEL:
			new_text += "[color=#3f3f40][Fuel][/color]"
		if i == ItemSkeletonRepository.ITEM_CLASS_FLAGS.FLAG_EQUIPMENT:
			new_text += "[color=#b56435][Equipment][/color]"
	new_text += "\n"
	if item.has("stats"):
		pass
	new_text += item["description"]
	$MarginContainer/RichTextLabel.text = new_text
