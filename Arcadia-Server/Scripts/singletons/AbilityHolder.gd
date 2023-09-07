class_name AbilityDataRepository extends Node

enum SPELL_TYPE_FLAGS{SPELL_OFFENSIVE, SPELL_DEFENSIVE}
enum SPELL_EFFECT_TYPE{SPELL_TRACKER, SPELL_AOE, SPELL_INSTAHIT, SPELL_SPECIAL}

var tree_resources : Array = [
	load("res://Resources/Spells/Spell Trees/thunder.tres")
]

# Each spell in one of the respective trees below should be formatted as such.
# "name":String,
# "desc":String,
# "position_in_tree":Vector2,
# "texture":String,
# "point_cost":int,
# "requires_spells":Array[String],
# "flags":Array[enum],
# "mastery:bool
#
# Each subtree should be structured as such:
# "name":String,
# "texture":String,
# "position_in_tree":Vector2,
# "desc":String,
# "spells":Dictionary

func _ready():
	
	for i in tree_resources:
		var tree_spells : Dictionary = {}
		for s in i.abilities:
			tree_spells[s.ability_name] = {
				"name":s.ability_name,
				"desc":"",
				"position_in_tree":s.position_in_tree,
				"point_cost":s.point_cost,
				"mastery":s.mastery,
				"requires_spells":s.requires_spells.duplicate(true),
				"flags":s.flags.duplicate(true),
				"texture":s.texture,
			}
			all_abilities[s.ability_name] = s
		
		ability_dictionary[i.master_class][i.name] = {
			"name":i.name,
			"texture":i.texture,
			"position_in_tree": i.position_in_tree,
			"desc":i.description_short,
			"spells":tree_spells.duplicate(true)
		}

var ability_dictionary : Dictionary = {
	"Volition":{
		
	},
	"Cognition":{

	},
	"Erudition":{
		
	}
}

var all_abilities : Dictionary = {}
var all_effects : Dictionary = {}
