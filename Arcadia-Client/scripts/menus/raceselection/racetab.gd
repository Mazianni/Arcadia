extends Node

var racename : String
var raceicon : String
var racedesc : String

onready var desc = $RaceDescription
onready var icon = $RaceIcon

func _ready():
	desc.bbcode_text = racedesc
	icon.SetRaceIcon(raceicon)
	
	
