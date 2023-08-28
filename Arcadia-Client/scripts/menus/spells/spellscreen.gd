extends Control

var current_tree : int = 0

var subtrees : Array = []
var spelltrees : Array = []

var last_clicked_spell : Node

var currently_shown_tree : Node

@onready var TreeContainer = $TreeContainer
@onready var VolitionBound = $MarginContainer/TabContainer/Volition/VolitionContainer/VolitionBound
@onready var CognitionBound = $MarginContainer/TabContainer/Cognition/CognitionContainer/CognitionBound
@onready var EruditionBound = $MarginContainer/TabContainer/Erudition/EruditionContainer/EruditionBound
@onready var TabBox : TabContainer = $MarginContainer/TabContainer

@onready var spelltreenoderes = preload("res://scenes/Spells/SpellTree/SpellTreeNode.tscn")
@onready var spelltreeres = preload("res://scenes/Spells/SpellTree/SpellTree.tscn")
@onready var spellres = preload("res://scenes/Spells/SpellTree/Spell.tscn")

func _ready():
	CombatHandler.spells_recieved.connect(Callable(self, "UpdateTree"))
	CombatHandler.ClientCombatHandler_RequestSelfSpells()

func ChangeTree():
	if current_tree >= Globals.ability_trees.size():
		current_tree = 0
		
func UpdateTree(spells):	
	for i in Globals.ability_trees.keys():
		for s in Globals.ability_trees[i].keys():
			var new_node : SpellTreeNode = spelltreenoderes.instantiate()
			new_node.name = Globals.ability_trees[i][s]["name"]
			new_node.SetIcon(load("res://sprites/spell_trees/"+Globals.ability_trees[i][s]["texture"]))
			new_node.position = Globals.ability_trees[i][s]["position_in_tree"]
			new_node.clicked.connect(Callable(self, "ShowSpellTree"))
			subtrees.append(new_node)
			match i:
				"Volition":
					VolitionBound.add_child(new_node)
				"Cognition":
					CognitionBound.add_child(new_node)
				"Erudition":
					EruditionBound.add_child(new_node)
			var new_tree = spelltreeres.instantiate()
			new_tree.name = Globals.ability_trees[i][s]["name"]
			new_tree.SetLabel(Globals.ability_trees[i][s]["name"])
			TreeContainer.add_child(new_tree)
			new_tree.hide()
			spelltrees.append(new_tree)
			for f in Globals.ability_trees[i][s]["spells"].keys():
				var new_spell : Spell = spellres.instantiate()
				new_spell.z_index = 3
				new_spell.name = Globals.ability_trees[i][s]["spells"][f]["name"]
				new_spell.SetSelf(Globals.ability_trees[i][s]["spells"][f]["name"], load("res://sprites/spell_trees/"+Globals.ability_trees[i][s]["spells"][f]["texture"]))
				new_spell.requires = Globals.ability_trees[i][s]["spells"][f]["requires_spells"]
				new_tree.AddSpell(new_spell)
				new_spell.position = Globals.ability_trees[i][s]["spells"][f]["position_in_tree"]
				if new_spell.name in Globals.known_spells:
					new_spell.unlocked = true
				new_spell.UpdateUnlocked()
				new_spell.right_clicked.connect(Callable(self, "SetLastClickedNode"))
				new_spell.spell_data = Globals.ability_trees[i][s]["spells"][f].duplicate(true)
					
	for c in spelltrees:
		var tree = c
		var tree_children : Array = tree.GetContainerChildren()
		print(tree_children)
		for s in tree_children:
			var spell = s
			if spell.requires.size() > 0:
				for a in spell.requires:
					if tree.ContainerHasNode(a):
						var new_line : Line2D = Line2D.new()
						new_line.z_index = 2
						if tree.ContainerGetNode(a).unlocked:
							new_line.default_color = Color.GREEN
						else:
							new_line.default_color = Color.RED
						new_line.modulate = Color(0.22, 0.22, 0.22, 1)
						new_line.add_point(spell.position)
						new_line.add_point(Vector2(spell.position.x,tree.ContainerGetNode(a).position.y/2))
						new_line.add_point(Vector2(tree.ContainerGetNode(a).position.x, tree.ContainerGetNode(a).position.y/2))
						new_line.add_point(tree.ContainerGetNode(a).position)
						spell.line_leading_to = new_line
						tree.AddSpell(new_line)
					
func ShowSpellTree(sname):
	$MarginContainer.hide()
	for i in TreeContainer.get_children():
		if i.name == sname:
			i.show()
			currently_shown_tree = i
			break
			
func UnlockSpell(spellname):
	for i in get_tree().get_nodes_in_group("spells"):
		if i.name == spellname:
			i.unlocked = true
			i.UpdateUnlocked()
					
func _on_previous_pressed():
	if TabBox.current_tab == 0:
		TabBox.current_tab = TabBox.get_tab_count() - 1
	else:
		TabBox.current_tab -= 1

func _on_next_pressed():
	if TabBox.current_tab == TabBox.get_tab_count() - 1:
		TabBox.current_tab = 0
	else:
		TabBox.current_tab += 1


func _on_button_pressed():
	if not $MarginContainer.visible:
		$MarginContainer.show()
		currently_shown_tree.hide()
	else:
		hide()

func _on_button_2_pressed():
	for i in TreeContainer.get_children():
		i.queue_free()
	for i in VolitionBound.get_children():
		i.queue_free()
	for i in CognitionBound.get_children():
		i.queue_free()
	for i in EruditionBound.get_children():
		i.queue_free()
	subtrees.clear()
	spelltrees.clear()
	CombatHandler.ClientCombatHandler_RequestSelfSpells()
	
func SetLastClickedNode(node):
	last_clicked_spell = node

func _on_popup_menu_id_pressed(id):
	var spell_name = last_clicked_spell.name

func _on_popup_menu_popup_hide():
	$PopupMenu.clear()
