extends Node

var CharacterBarResource = preload("res://scenes/CharacterSelectBar.tscn")
var CharacterCreationScreenResource = preload("res://scenes/CharacterCreation.tscn")

func _ready():
	Server.connect("character_list_recieved", Callable(self, "RenderSlots"))
	if Globals.CharacterList.size() == 0:
		Server.RequestCharacterList()
	else:
		RenderSlots()

func RenderSlots():
	var remaining_slots = 6
	if Globals.CharacterList.size() > 0:
		for i in Globals.CharacterList.keys():
			var newbarinstance = CharacterBarResource.instantiate()
			newbarinstance.name = Globals.uuid_generator.v4()
			newbarinstance.displayname = Globals.CharacterList[i]
			newbarinstance.originator = self
			newbarinstance.is_empty_slot = false
			newbarinstance.assigned_uuid = i
			$NinePatchRect/CenterContainer/GridContainer.add_child(newbarinstance)
			remaining_slots -= 1
		if remaining_slots > 0:
			for i in remaining_slots:
				var newbarinstance = CharacterBarResource.instantiate()
				newbarinstance.name = Globals.uuid_generator.v4()
				newbarinstance.displayname = "Empty Slot"
				newbarinstance.originator = self
				newbarinstance.is_empty_slot = true
				newbarinstance.assigned_uuid = null
				$NinePatchRect/CenterContainer/GridContainer.add_child(newbarinstance)
	else:
		for i in 6:
			var newbarinstance = CharacterBarResource.instantiate()
			newbarinstance.name = Globals.uuid_generator.v4()
			newbarinstance.displayname = "Empty Slot"
			newbarinstance.originator = self
			newbarinstance.is_empty_slot = true
			newbarinstance.assigned_uuid = null
			$NinePatchRect/CenterContainer/GridContainer.add_child(newbarinstance)
	Server.disconnect("character_list_recieved", Callable(self, "RenderSlots"))
	
func SelectCharacter(uuid, is_new):
	if is_new:
		var charcreation = CharacterCreationScreenResource.instantiate()
		self.get_parent().add_child(charcreation)
		self.queue_free()
	else:
		Server.SelectCharacter(uuid)
		Globals.character_uuid = uuid
		
func DeleteCharacter(uuid):
	Server.DeleteCharacter(uuid)
	
func RefreshCharacterList():
	Server.RequestCharacterList()
	RenderSlots()
