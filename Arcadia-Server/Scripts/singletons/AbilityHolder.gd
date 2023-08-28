class_name AbilityDataRepository extends Node

enum SPELL_TYPE_FLAGS{SPELL_OFFENSIVE, SPELL_DEFENSIVE}
enum SPELL_EFFECT_TYPE{SPELL_TRACKER, SPELL_AOE, SPELL_SPECIAL}


# Each spell in one of the respective trees below should be formatted as such.
# "name":String,
# "desc":String,
# "position_in_tree":Vector2,
# "texture":String,
# "point_cost":int,
# "requires_spells":Array[String]
# "flags":Array[enum]
#
# Each subtree should be structured as such:
# "name":String,
# "texture":String,
# "position_in_tree":Vector2,
# "desc":String,
# "spells":Dictionary



var ability_dictionary : Dictionary = {
	"Volition":{
		
	},
	"Cognition":{
		"Test":{
			"name":"Test Tree",
			"texture":"thundermagic.png",
			"position_in_tree":Vector2(200,200),
			"desc":"This is a test.",
			"spells":{
				"Thunder Strike":{
					"name":"Thunder Strike",
					"desc":"This is a test.",
					"position_in_tree":Vector2(-100,100),
					"texture":"thunder/thunder1.tres",
					"point_cost":10,
					"requires_spells":[]
				},
				"Infernal Smite":{
					"name":"Infernal Smite",
					"desc":"This is a test.",
					"position_in_tree":Vector2(100,100),
					"texture":"thunder/thunder2.tres",
					"point_cost":10,
					"requires_spells":[]
				},
				"Voidrend":{
					"name":"Voidrend",
					"desc":"This is a test.",
					"position_in_tree":Vector2(0,-100),
					"texture":"thunder/thunder1.tres",
					"point_cost":10,
					"requires_spells":["Thunder Strike", "Infernal Smite"]
				}
			}
		}
	},
	"Erudition":{
		
	}
}

var all_abilities : Array = [
	
]
