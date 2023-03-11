extends Node

onready var icon = $NinePatchRect/TextureRect
var raceiconpath = "res://images/race_icons/"

func SetRaceIcon(iconname):
	var newtex : StreamTexture = load(raceiconpath+iconname+".png")
	icon.set_texture(newtex)
