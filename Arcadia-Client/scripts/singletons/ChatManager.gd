extends Node

var CurrentChatTab : String = ""
var CurrentTextOutput
var MaxChatlogLength = 50
onready var ChatMsgContainer = load("res://scenes/ChatMsg/ChatMessage.tscn")

func HookMainUI(node:Control):
	CurrentTextOutput = node

func SetCurrentChatTab(tab:Control):
	CurrentChatTab = tab.name
	UpdateChatDisplay()
	
func SendChat(msg, is_emote):
	var SendDict : Dictionary
	SendDict = {
		"text":msg,
		"is_emote": is_emote,
		"category": CurrentChatTab
	}
	if is_emote:
		SendDict["category"] = "IC"
	Server.SendChat(SendDict)

#	var chatdict : Dictionary = {"speaker":Globals.character_uuid,"text":,"is_emote":false,"T":Time.get_datetime_string_from_system(false, true)}
func CreateNewChatMessage(msg:Dictionary):
	CullChatLength()
	print(str(msg))
	var ncm = ChatMsgContainer.instance()
	ncm.name = Globals.uuid_generator.v4()
	CurrentTextOutput.add_child(ncm)
	ncm.ParseMessage(msg)
	if ncm.category != CurrentChatTab:
		ncm.hide()
	
func CullChatLength():
	print("culling")
	var cull_array : Array = CurrentTextOutput.get_children()
	if cull_array.size() > MaxChatlogLength:
		var n2r = cull_array[0]
		CurrentTextOutput.get_node(n2r).queue_free()
		
func UpdateChatDisplay():
	var updatearray : Array = CurrentTextOutput.get_children()
	for I in updatearray:
		if I.category != CurrentChatTab && CurrentChatTab != "ALL":
			if (I.category == "LOOC" || "IC") && CurrentChatTab == "IC":
				continue
			else:
				I.hide()
		elif I.category == CurrentChatTab:
			I.show()
		elif CurrentChatTab == "ALL":
			I.show()
