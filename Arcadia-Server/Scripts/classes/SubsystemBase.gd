class_name SubsystemBase extends Node

signal subsystem_start_success(name, node)
signal subsystem_start_failed(name, node)
signal subsystem_shutdown(name, node)

func SubsystemInit(node_name:String):
	pass
	
func SubsystemShutdown(node_name:String):
	pass
