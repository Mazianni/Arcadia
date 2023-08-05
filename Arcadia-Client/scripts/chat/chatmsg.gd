extends RichTextLabel

var display_timestamps : bool = false
var is_emote : bool = false
var timestamp : String
var msgtext : String
var category : String
@onready var themeresource = load("res://themes/chattheme.tres")

func _ready():
	theme = themeresource

func ParseMessage(msg:Dictionary):
	is_emote = msg["is_emote"]
	timestamp = msg["T"]
	msgtext = msg["text"]
	category = msg["category"]
	DrawMsg()
	
func DrawMsg():
	var t : String = ""
	if display_timestamps:
		t = "["+timestamp+"] "
	text = t+msgtext
	var themefont : Font = theme.get_font("mono_font", "RichTextLabel")
	custom_minimum_size = themefont.get_multiline_string_size(text)
		
