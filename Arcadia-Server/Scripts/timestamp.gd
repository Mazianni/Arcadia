extends Node

func log_error(string):
	var out = Time.get_datetime_string_from_system(false, true) + " - [ERR:] - " + string
	print(out)
	
func log_warning(string):
	var out = Time.get_datetime_string_from_system(false, true) + " - [WARN:] - " + string
	print(out)
	
func log_notice(string):
	var out = Time.get_datetime_string_from_system(false, true) + " - [NOTIF:] - " + string
	print(out)
