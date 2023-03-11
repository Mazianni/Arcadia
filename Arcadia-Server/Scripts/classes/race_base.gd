class_name SpeciesBase extends Resource

# This is the base class for races; all others should extend this. (and preferably, only modify existing variables).

export(String) var race_name = "Test"
export(String) var race_description_short = "This is a test, and if you are seeing it, something is broken."
export(String) var race_description_extended = "This is a test, and if you are seeing it, something is broken."
export(String) var race_icon
export(String) var racial_spell_tree = "NONE"
export(bool) var requires_approval = false
export(Dictionary) var base_stats = {"Vigor": 10, "Ability": 10, "Deftness": 10, "Willpower": 10}
export(Dictionary) var default_skin_colors = {}
export(Dictionary) var heightminmax = {"max": 175, "min" : 120}
export(Array) var default_ear_styles = []
export(Array) var default_tail_styles = []
export(Array) var default_accessory_one_styles = []
export(Array) var valid_spawns = []

