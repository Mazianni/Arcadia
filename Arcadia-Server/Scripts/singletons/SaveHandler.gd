extends Node

#common read/write/delete functions instead of smattering these everywhere.

func WriteFile(filepath: String): pass

func ReadFile(save_file: String):
	var load_dict : Dictionary = {}
	var loadfile = FileAccess.open(save_file, FileAccess.READ)
	var temp
	temp = loadfile.get_as_text()
	var test_json_conv = JSON.new()
	test_json_conv.parse(temp)
	if(loadfile.get_error()):
		Logging.log_error("[SAVEHANDLER] [FILE] Error loading file "+save_file)
		loadfile.close()
		return
	if(test_json_conv.get_error_message()):
		Logging.log_error("[SAVEHANDLER] [FILE] Error parsing JSON for file at path "+save_file)
		loadfile.close()
		return
	if(test_json_conv.get_data() == null):
		Logging.log_error("[SAVEHANDLER] [FILE] Null data/corrupt data parsed in file at path "+save_file)
		loadfile.close()
		return
	load_dict = test_json_conv.get_data()
	return load_dict
	
func DeleteFile(filepath: String): pass
