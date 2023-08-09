extends Node

var CharacterBarResource = preload("res://scenes/CharacterSelectBar.tscn")
var CharacterCreationScreenResource = preload("res://scenes/CharacterCreation.tscn")

@onready var barcointainer = $NinePatchRect/CenterContainer/GridContainer

func _ready():
	Server.connect("character_list_recieved", Callable(self, "RenderSlots"))
	Globals.character_list_refresh_requested.connect(Callable(self, "RefreshCharacterList"))
	if Globals.CharacterList.size() == 0:
		Server.RequestCharacterList()
	else:
		RenderSlots()
		
func _exit_tree():
	Server.disconnect("character_list_recieved", Callable(self, "RenderSlots"))
	Globals.character_list_refresh_requested.disconnect(Callable(self, "RefreshCharacterList"))	

func RenderSlots():
	if barcointainer.get_children():
		for i in barcointainer.get_children():
			i.queue_free()
	var remaining_slots = 6
	if Globals.CharacterList.size() > 0:
		for i in Globals.CharacterList.keys():
			var newbarinstance = CharacterBarResource.instantiate()
			newbarinstance.name = Globals.uuid_generator.v4()
			newbarinstance.displayname = Globals.CharacterList[i]
			newbarinstance.originator = self
			newbarinstance.is_empty_slot = false
			newbarinstance.assigned_uuid = i
			barcointainer.add_child(newbarinstance)
			remaining_slots -= 1
		if remaining_slots > 0:
			for i in remaining_slots:
				var newbarinstance = CharacterBarResource.instantiate()
				newbarinstance.name = Globals.uuid_generator.v4()
				newbarinstance.displayname = "Empty Slot"
				newbarinstance.originator = self
				newbarinstance.is_empty_slot = true
				newbarinstance.assigned_uuid = null
				barcointainer.add_child(newbarinstance)
	else:
		for i in 6:
			var newbarinstance = CharacterBarResource.instantiate()
			newbarinstance.name = Globals.uuid_generator.v4()
			newbarinstance.displayname = "Empty Slot"
			newbarinstance.originator = self
			newbarinstance.is_empty_slot = true
			newbarinstance.assigned_uuid = null
			$NinePatchRect/CenterContainer/GridContainer.add_child(newbarinstance)
	
func SelectCharacter(uuid, is_new):
	if is_new:
		Gui.ChangeGUIScene("CharacterCreation")
	else:
		Server.SelectCharacter(uuid)
		Globals.character_uuid = uuid
		
func DeleteCharacter(uuid):
	Server.DeleteCharacter(uuid)
	
func RefreshCharacterList():
	Server.RequestCharacterList()
	RenderSlots()

