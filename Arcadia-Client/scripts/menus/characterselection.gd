extends Node

var CharacterBarResource = preload("res://scenes/CharacterSelectBar.tscn")
var CharacterCreationScreenResource = preload("res://scenes/CharacterCreation.tscn")

func _ready():
	Server.GetCharacterList()
	yield(get_tree().create_timer(0.3), "timeout")
	var remaining_slots = 6
	if Globals.CharacterList.size() > 0:
		for i in Globals.CharacterList.keys():
			var newbarinstance = CharacterBarResource.instance()
			newbarinstance.name = Globals.uuid_generator.v4()
			newbarinstance.displayname = Globals.CharacterList[i]
			newbarinstance.originator = self
			newbarinstance.is_empty_slot = false
			newbarinstance.assigned_uuid = i
			get_node("NinePatchRect/GridContainer").add_child(newbarinstance)
			remaining_slots -= 1
		if remaining_slots > 0:
			for i in remaining_slots:
				var newbarinstance = CharacterBarResource.instance()
				newbarinstance.name = Globals.uuid_generator.v4()
				newbarinstance.displayname = "Empty Slot"
				newbarinstance.originator = self
				newbarinstance.is_empty_slot = true
				newbarinstance.assigned_uuid = null
				get_node("NinePatchRect/GridContainer").add_child(newbarinstance)
	else:
		for i in 6:
			var newbarinstance = CharacterBarResource.instance()
			newbarinstance.name = Globals.uuid_generator.v4()
			newbarinstance.displayname = "Empty Slot"
			newbarinstance.originator = self
			newbarinstance.is_empty_slot = true
			newbarinstance.assigned_uuid = null
			get_node("NinePatchRect/GridContainer").add_child(newbarinstance)
	
func SelectCharacter(uuid, is_new):
	if is_new:
		var charcreation = CharacterCreationScreenResource.instance()
		self.get_parent().add_child(charcreation)
		self.queue_free()
	else:
		Server.SelectCharacter(uuid)
		
func DeleteCharacter(uuid):
	Server.DeleteCharacter(uuid)
