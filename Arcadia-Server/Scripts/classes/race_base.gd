class_name SpeciesBase extends Resource

# This is the base class for races; all others should extend this. (and preferably, only modify existing variables).

@export var race_name: String = "Test"
@export var race_description_short = "This is a test, and if you are seeing it, something is broken." # (String, MULTILINE)
@export var race_description_extended = "This is a test, and if you are seeing it, something is broken." # (String, MULTILINE)
@export var race_icon: String
@export var racial_spell_tree: String = "NONE"
@export var requires_approval: bool = false
@export var base_stats: Dictionary = {"Vigor": 10, "Ability": 10, "Deftness": 10, "Willpower": 10}
@export var default_skin_colors: Dictionary = {}
@export var heightminmax: Dictionary = {"max": 175, "min" : 120}
@export var default_ear_styles: Array = []
@export var default_tail_styles: Array = []
@export var default_accessory_one_styles: Array = []
@export var valid_spawns: Array = []

