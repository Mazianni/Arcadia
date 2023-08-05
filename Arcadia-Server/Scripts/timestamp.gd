extends Node

var verbose : bool = true

func _ready():
	var args = Array(OS.get_cmdline_args())
	if args.has("-nonverbose"):
		verbose = false
		log_warning("[LOGGING] -nonverbose in command line args. Only warnings and errors will be logged!")

func log_error(string):
	var out = Time.get_datetime_string_from_system(true, true) + " - [ERR:] - " + string
	print(out)
	
func log_warning(string):
	var out = Time.get_datetime_string_from_system(true, true) + " - [WARN:] - " + string
	print(out)
	
func log_notice(string):
	if verbose:
		var out = Time.get_datetime_string_from_system(true, true) + " - [NOTIF:] - " + string
		print(out)
