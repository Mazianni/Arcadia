extends Node

func log_error(string):
	var out = Time.get_datetime_string_from_system(false, true) + " - [ERR:] - " + string
	Print.line(Print.BLACK + Print.RED_BACKGROUND, out)
	
func log_warning(string):
	var out = Time.get_datetime_string_from_system(false, true) + " - [WARN:] - " + string
	Print.line(Print.BLACK + Print.YELLOW_BACKGROUND, out)
	
func log_notice(string):
	var out = Time.get_datetime_string_from_system(false, true) + " - [NOTIF:] - " + string
	Print.line(Print.BLACK + Print.GREEN_BACKGROUND, out)
