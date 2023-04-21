extends Node

# The dictionary resulting from this should look something like this.
# newdict = {
# "text:"somestring",
# "is_emote":true or false,
# "originator":"somestring",
# "T":"sometimestampstring",
# "distance":42069,
# "category":"somestringcategory",
# "is_global": true or false,
# "is_admin_msg": true or false #TODO reserved for future use.
# "output": {"text":"string", "T":"timestampstring","is_emote":true or false, "category":"somestring"}
# }
func EscapeBBCode(msg:String):
	return msg.replace("[", "[lb]")

func IsMsgGlobal(msg:Dictionary):
	if msg["is_emote"] == true:
		return false
	elif msg["category"] == "OOC":
		return true
	elif msg["category"] == "ADMIN":
		return true
	return false
		
func IsMsgOOC(msg:Dictionary):
	if msg["is_emote"] == true:
		return false
	elif msg["category"] == "OOC":
		return true
	elif msg["category"] == "LOOC":
		return true	
	return false
	
#Welcome to string concatenation hell.
		
func ParseChat(msg:Dictionary, originator:String, is_global:bool = false):
	var newdict : Dictionary = msg.duplicate(true)
	var outputdict : Dictionary = {} #nested dictionary within newdict that is actually sent to the client.
	var teststring : String = EscapeBBCode(newdict["text"])
	var is_ooc : bool = IsMsgOOC(msg)
	var is_special_type : bool
	var particle : String 
	var special_type_start : String
	var special_type_end : String
	var add_formatting : String
	var end_formatting : String
	var needs_formatting : bool = false
	var all_caps : bool = false
	
	newdict["T"] = Time.get_time_string_from_system(true)
	newdict["distance"] = DataRepository.default_emote_range
	newdict["is_global"] = is_global
	newdict["originator"] = originator
	outputdict["is_emote"] = newdict["is_emote"]
	outputdict["T"] = newdict["T"]
	outputdict["category"] = newdict["category"]
	
	if newdict["is_emote"]:
		outputdict["category"] = "IC"
	
	if !is_global:
		if not newdict["is_emote"]:
			for i in DataRepository.chat_commands_dict.keys():
				if DataRepository.chat_commands_dict[i]["command"] in teststring:
					var s2g : String = DataRepository.chat_commands_dict[i]["command"]
					newdict["distance"] = DataRepository.chat_commands_dict[i]["distance"]
					is_special_type = true
					particle = DataRepository.chat_commands_dict[i]["particle"]
					special_type_start = DataRepository.chat_commands_dict[i]["start_formatting"]
					special_type_end = DataRepository.chat_commands_dict[i]["end_formatting"]
					all_caps = DataRepository.chat_commands_dict[i]["allcaps"]
					teststring = teststring.trim_prefix(s2g)
	#TODO add markdown handling here.
	
	if is_global || is_ooc: #ooc, admin, looc.
		match newdict["category"]:
			"LOOC":
				add_formatting = "[color="+DataRepository.category_bbcode_colors[newdict["category"]]+"][b]"+str(newdict["category"])+" - "+str(originator)+"[/b]:[i] "
				end_formatting = "[/i][/color]"				
				needs_formatting = true
			"OOC":
				add_formatting = "[color="+DataRepository.category_bbcode_colors[newdict["category"]]+"][b]"+str(newdict["category"])+"  - "+str(originator)+"[/b]: "
				end_formatting = "[/color]"			
				needs_formatting = true
			"ADMIN":
				add_formatting = "[color="+DataRepository.category_bbcode_colors[newdict["category"]]+"][b]"+str(newdict["category"])+" - "+str(originator)+"[/b]: "
				end_formatting = "[/color]"
				needs_formatting = true
		if !add_formatting && !end_formatting && needs_formatting:
			Logging.log_warning("[CHAT] Unhandled category in message. Contents " + str(newdict))
	elif !newdict["is_emote"] && !is_global && !is_ooc: #normal say
		if is_special_type:
			if all_caps:
				teststring = teststring.to_upper()
			add_formatting = special_type_start+"[b]"+str(originator)+"[/b] "+particle+", \""
			end_formatting = "\""+special_type_end
		else:	
			add_formatting = "[b]"+str(originator)+"[/b] says, \""
			end_formatting = "\""
	elif newdict["is_emote"] && !is_global && !is_ooc: # emotes
		newdict["category"] = "IC"
		add_formatting = "[color="+DataRepository.category_bbcode_colors["Emote"]+"]"
		end_formatting = "\n[b]("+str(originator)+")[/b][/color]"
		
	teststring = ParseMarkdown(teststring)	
		
	outputdict["text"] = add_formatting+teststring+end_formatting
	
	newdict["output"] = outputdict.duplicate(true)
	
	print(newdict)

	return newdict
	
func ParseMarkdown(msg:String):
	var mutated : String 
	var all_markup_found : bool = false
	var iterator : int = 0
	var opened : bool = false
	for i in msg:
		var current_tag : String = i
		var tag_found : bool = false
		var offset : int = 0
		if Helpers.Match3(msg, i, iterator): # find the opening tag.
			current_tag = current_tag.repeat(2)
			Logging.log_error(current_tag)
			offset = 2
		elif Helpers.Match2(msg, i, iterator):
			current_tag = current_tag.repeat(1)
			Logging.log_error(current_tag)
			offset = 1
		for m in DataRepository.markdown_dict.keys():
			if current_tag == m:
				msg.erase(iterator, offset)
				iterator -= offset
				tag_found = true
				if not opened:
					mutated += DataRepository.markdown_dict[current_tag]["opener_bbcode"]
					opened = true
				else:
					mutated += DataRepository.markdown_dict[current_tag]["closer_bbcode"]
					opened = false
				break
		if !tag_found:
			mutated += i
		iterator += 1
	return mutated