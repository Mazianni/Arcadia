class_name Spell extends Control


var requires : Array
var unlocked : bool = false
var lines_leading_from : Array
var spell_data : Dictionary

@onready var spellpreviewres = preload("res://scenes/Spells/SpellTree/GrabbedSpellPreview.tscn")

signal right_clicked(this_node)

func SetSelf(spellname, icon):
	$TextureRect2.texture = icon
	$VBoxContainer/Label.text = spellname
	
func UpdateUnlocked():
	if unlocked:
		if lines_leading_from.size():
			for i in lines_leading_from:
				i.default_color = Color.GREEN
		$TextureRect2.modulate = Color(1,1,1,1)
		$VBoxContainer/Label.modulate = Color(1,1,1,1) 
	else:
		if lines_leading_from.size():
			for i in lines_leading_from:
				i.default_color = Color.GREEN
		$TextureRect2.modulate = Color(0.22,0.22,0.22,1)
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
				
func _make_custom_tooltip(for_text):
	var tooltip_res = preload("res://scenes/Spells/SpellTree/SpellTooltip.tscn")
	var tooltip_scene = tooltip_res.instantiate()
	if spell_data == {}:
		return
	tooltip_scene.spell = spell_data.duplicate(true)
	tooltip_scene.DrawTooltip()
	return tooltip_scene
				
func _get_drag_data(at_position):
	if not unlocked:
		return null
	set_drag_preview(make_preview(spell_data.duplicate(true)))
	return spell_data
	
func make_preview(spell_data):
	var preview = spellpreviewres.instantiate()
	preview.texture = load("res://sprites/spell_trees/"+spell_data["texture"])
	preview.z_index = 999
	return preview
