extends RichTextLabel

var display_timestamps : bool = false
var is_emote : bool = false
var timestamp : String
var msgtext : String
var category : String

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
	text = msgtext
		
