class_name Spell extends Control


var requires : Array
var unlocked : bool = false
var line_leading_to : Line2D
var spell_data : Dictionary

signal right_clicked(this_node)

func SetSelf(spellname, icon):
	$TextureRect.texture = icon
	$VBoxContainer/Label.text = spellname
	
func UpdateUnlocked():
	if unlocked:
		if line_leading_to:
			line_leading_to.default_color = Color.GREEN
		$TextureRect.modulate = Color(1,1,1,1)
		$VBoxContainer/Label.modulate = Color(1,1,1,1) 
	else:
		if line_leading_to:
			line_leading_to.default_color = Color.RED
		$TextureRect.modulate = Color(0.22,0.22,0.22,1)
		$VBoxContainer/Label.modulate = Color(0.5,0.5,0.5,1)
		
func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_RIGHT:
				right_clicked.emit(self)
				var spell_popup : PopupMenu = get_tree().get_nodes_in_group("spell_popup")[0]
				if not unlocked:
					spell_popup.add_item("Purchase "+self.name)
				spell_popup.position = get_global_mouse_position()
				spell_popup.popup()
