extends Node

var AllowedEars : Array
var AllowedTail : Array
var AllowedAccessoryOne : Array
var AllowedSkinColors : Dictionary
var AllowedSpawns : Array
var HeightMinMax : Dictionary

var CharacterName : String
var SelectedRace : String
var SelectedAge : int
var SelectedBodytype : String
var SelectedSpawn : String
var SelectedHeight : int
var CurrentDirection : int = 1
var CurrentDirText : String

var SkinColor : Color
var HairColor : Color
var EyeColor : Color

var SelectedHair : String
var SelectedEars : String
var SelectedTail : String
var SelectedAccessoryOne : String

var RaceScene = "res://scenes/RaceTab/RaceTab.tscn"
var SubraceScene = preload("res://scenes/RaceTab/SubraceTab.tscn")

var previewspritespath = "res://sprites/player/"
var previewspriteshairpath = "res://sprites/player/hair"

@onready var maxpopuprect : Rect2 = Rect2(0,0,500,500)

@onready var doll_eyes = $PreviewSpriteContainer/Eyes
@onready var doll_body = $PreviewSpriteContainer/Body
@onready var doll_hair = $PreviewSpriteContainer/Hair

@onready var DetailsPanelContainer = $NinePatchRect
@onready var RacePanel = $NinePatchRect2/RaceSelection/RaceContainer
@onready var RaceSelection = $NinePatchRect2/RaceSelection
@onready var RaceSelectionContainer = $NinePatchRect2

@onready var BodytypeSelection = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/BodytypeMenu
@onready var HairStyleSelection = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/HairStyleMenu
@onready var SkinColorSelection = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/SkinMenu
@onready var TailStyleSelection = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/TailMenu
@onready var AccessoryStyleSelection = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/AccessoryMenu
@onready var EyeColorSelection = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/EyesMenu/EyePicker
@onready var HairColorSelection = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/HairColorMenu/HairPicker
@onready var DirSelection = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/DirSelect
@onready var SpawnLocationSelection = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/SpawnMenu
@onready var EarStyleSelection = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/EarMenu
@onready var AgeInputSlider = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/AgeInput
@onready var NameInput = $NinePatchRect/MarginContainer/VBoxContainer/NameInput
@onready var CreateConfirmButton = $CreateConfirmButton
@onready var HeightInputSlider = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/HeightInput

@onready var AgeInputLabel = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/AgeInput/Label2
@onready var HeightInputLabel = $NinePatchRect/MarginContainer/VBoxContainer/GridContainer/HeightInput/Label2

# Called when the node enters the scene tree for the first time.
func _ready():
	Server.GetRaceList()
	await get_tree().create_timer(0.1).timeout
	var defaultlist = Globals.RaceList.keys()
	GenerateRaces()
	
func GenerateRaces():
	for i in Globals.RaceList.keys():
		print(i)
		print(Globals.RaceList[i]["Long Description"])
		print(Globals.RaceList[i]["Icon"])
		var newraceinstance = SubraceScene.instantiate()
		newraceinstance.name = i
		newraceinstance.racename = i 
		newraceinstance.racedesc = Globals.RaceList[i]["Long Description"]
		newraceinstance.raceicon = Globals.RaceList[i]["Icon"]
		RacePanel.add_child(newraceinstance)
	
func SetDefaults():
	SelectedAge = AgeInputSlider.value
	SkinColor = Globals.RaceList[SelectedRace]["ValidSkin"].values()[0]
	HairColor = Color(randf(), randf(), randf())
	EyeColor = Color(randf(), randf(), randf())
	EyeColorSelection.color = EyeColor
	HairColorSelection.color = HairColor
	SelectedHair = Globals.HairList[0]
	SelectedEars = AllowedEars[0]
	SelectedTail = AllowedTail[0]
	SelectedAccessoryOne = AllowedAccessoryOne[0]
	SelectedSpawn = AllowedSpawns[0]
	SelectedBodytype = Globals.BodytypeList[0]
	SelectedEars = AllowedEars[0]
	CurrentDirText = Globals.DirectionsList[CurrentDirection]
	
func PopulateOptions():
	for i in AllowedSpawns:
		SpawnLocationSelection.add_item(str(i))
	
	for i in Globals.BodytypeList:
		BodytypeSelection.add_item(str(i))
	
	for i in Globals.HairList:
		HairStyleSelection.add_item(str(i))
		
	for i in AllowedSkinColors.keys():
		if i.ends_with("SEP"):
			SkinColorSelection.add_separator()
		else:
			SkinColorSelection.add_item(i)
		
	for i in AllowedTail:
		TailStyleSelection.add_item(str(i))
		
	for i in AllowedAccessoryOne:
		AccessoryStyleSelection.add_item(str(i))
		
	for i in AllowedEars:
		EarStyleSelection.add_item(str(i))
		
func UpdateDoll():
	var gender_prefix : String
	
	match SelectedBodytype:
		"Bodytype A":
			gender_prefix = "m"
		"Bodytype B":
			gender_prefix = "f"
	doll_body.texture = load(previewspritespath+SelectedRace+"_"+gender_prefix+"_"+CurrentDirText+".png")
	doll_eyes.texture = load(previewspritespath+"eyes_"+CurrentDirText+".png")
	doll_hair.texture = load(previewspritespath+"hair/"+SelectedHair+"/"+SelectedHair+"_"+CurrentDirText+".png")
	doll_eyes.set_self_modulate(EyeColor)
	doll_hair.set_self_modulate(HairColor)
	doll_body.set_self_modulate(SkinColor)
	
	
func _on_RaceConfirm_pressed():
	RaceSelection.hide()
	RaceSelectionContainer.hide()
	DetailsPanelContainer.show()
	SelectedRace = RacePanel.get_tab_title(RacePanel.current_tab)
	AllowedEars = Globals.RaceList[SelectedRace]["ValidEars"]
	AllowedTail = Globals.RaceList[SelectedRace]["ValidTails"]
	AllowedAccessoryOne = Globals.RaceList[SelectedRace]["ValidAccessoryOne"]
	AllowedSkinColors = Globals.RaceList[SelectedRace]["ValidSkin"].duplicate(true)
	AllowedSpawns = Globals.RaceList[SelectedRace]["ValidSpawns"]
	HeightMinMax = Globals.RaceList[SelectedRace]["Heightminmax"].duplicate(true)
	HeightInputSlider.min_value = HeightMinMax["min"]
	HeightInputSlider.max_value = HeightMinMax["max"]
	HeightInputSlider.value = HeightMinMax["min"]
	if Settings.CurrentSettingsDict["Measurement Units"] == "Imperial":
		HeightInputLabel.text = Helpers.metric2imperial(HeightMinMax["min"])
	else:
		HeightInputLabel.text = str(HeightMinMax["min"])
	NameInput.show()
	CreateConfirmButton.show()
	SetDefaults()
	PopulateOptions()
	UpdateDoll()
	
func _on_AgeInput_value_changed(value):
	AgeInputLabel.text = str(value)
	UpdateDoll()

func _on_GenderMenu_item_selected(index):
	SelectedBodytype = BodytypeSelection.get_item_text(index)
	UpdateDoll()
	
func _on_HairStyleMenu_item_selected(index):
	SelectedHair = HairStyleSelection.get_item_text(index)
	UpdateDoll()

func _on_SkinMenu_item_selected(index):
	SkinColor = AllowedSkinColors[SkinColorSelection.get_item_text(index)]
	UpdateDoll()

func _on_TailMenu_item_selected(index):
	SelectedTail = TailStyleSelection.get_item_text(index)
	UpdateDoll()

func _on_AccessoryMenu_item_selected(index):
	SelectedAccessoryOne = AccessoryStyleSelection.get_item_text(index)
	UpdateDoll()
	
func _on_EarMenu_item_selected(index):
	SelectedEars = EarStyleSelection.get_item_text(index)
	UpdateDoll()
	
#dir rotation bullshit

func _on_Left_pressed():
	if CurrentDirection == 1:
		CurrentDirection = 4
	else:
		CurrentDirection -= 1
	CurrentDirText = Globals.DirectionsList[CurrentDirection]
	UpdateDoll()

func _on_Right_pressed():
	if CurrentDirection == 4:
		CurrentDirection = 1
	else:
		CurrentDirection += 1
	CurrentDirText = Globals.DirectionsList[CurrentDirection]
	UpdateDoll()

func _on_HairPicker_color_changed(color):
	HairColor = color
	UpdateDoll()

func _on_EyePicker_color_changed(color):
	EyeColor = color
	UpdateDoll()

func _on_NameInput_text_entered(new_text):
	CharacterName = new_text
	UpdateDoll()

func _on_CreateConfirmButton_pressed():
	Server.RequestNewCharacter(SelectedRace, CharacterName, SelectedAge, HairColor.to_html(), SkinColor, SelectedHair, SelectedEars, SelectedTail, SelectedAccessoryOne, SelectedBodytype, SelectedHeight)

func _on_HeightInput_value_changed(value): #internally this stays metric. i hate. imperial units.
	var output = value
	SelectedHeight = value
	if Settings.CurrentSettingsDict["Measurement Units"] == "Imperial":
		output = Helpers.metric2imperial(value)
	else:
		output = str(output) + " cm"
	HeightInputLabel.text = output
