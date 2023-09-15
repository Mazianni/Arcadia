extends Node

var SubsystemInitOrder : Dictionary = {
	"Admin" = {"requires_creation":true, "resource":load("res://Scenes/Instances/Admin.tscn")},
	"PlayerManager" = {"requires_creation":true, "resource":load("res://Scenes/Instances/PlayerManager.tscn")},
	"Maphandler" = {"requires_creation":false, "resource":null},
	"StateProcessing" = {"requires_creation":false, "resource":null},
} #init order is defined by placement in this dict.

var ReverseInitOrder : Array 

#Subsystem init dicts are as follows...
# subsystem_name = {"requires_creation":true/false, "resource":load(path_to_resource)}
#It's assumed that if the subsystem doesn't require creation, then it's named the same as the subsystem_name

var subsystems_loaded : int = 0
var subsystems_to_load : int = 0
var subsystems_to_shut_down : int = 0
var subsystems_shutdown : int = 0
var next_subsystem_to_load : String
var next_subsystem_to_shutdown : String

signal subsystems_init_complete()
signal subsystems_shutdown_complete()
signal subsystem_manager_loaded_subsystem(subsystem_name, node)

func _ready():
	var order_to_reverse : Array = SubsystemInitOrder.keys()
	for k in order_to_reverse:
		ReverseInitOrder.push_front(k)
	subsystems_to_load = SubsystemInitOrder.size()
	subsystems_to_shut_down = SubsystemInitOrder.size()
	next_subsystem_to_load = SubsystemInitOrder.keys()[0]
	next_subsystem_to_shutdown = ReverseInitOrder[0]
	
func MasterSubsystemInit():
	Logging.log_notice("[SUBSYSTEM MGMT] Subsystem Init started.")
	Logging.log_notice("[SUBSYSTEM MGMT] Subsystems to initialize: "+str(subsystems_to_load))
	InitializeNextSubsystem()
	
func MasterSubsystemShutdown():
	Logging.log_notice("[SUBSYSTEM MGMT] Subsystem shutdown started.")
	Logging.log_notice("[SUBSYSTEM MGMT] Subsystems to shutdown: "+str(subsystems_to_load))
	ShutdownNextSubsystem()
	
func InitializeNextSubsystem():
	var subsystem_node : SubsystemBase
	if SubsystemInitOrder[next_subsystem_to_load]["requires_creation"] == true:
		Logging.log_notice("[SUBSYSTEM MGMT] Instantiating subsystem "+next_subsystem_to_load+"...")
		subsystem_node = SubsystemInitOrder[next_subsystem_to_load]["resource"].instantiate()
		subsystem_node.name = next_subsystem_to_load
		DataRepository.Server.add_child(subsystem_node)
	else:
		subsystem_node = DataRepository.Server.get_node(next_subsystem_to_load)
	Logging.log_notice("[SUBSYSTEM MGMT] Initializing subsystem "+next_subsystem_to_load+"...")
	subsystem_node.subsystem_start_success.connect(Callable(self, "SubsystemInitCallback"))
	subsystem_node.SubsystemInit(next_subsystem_to_load)

		
func ShutdownNextSubsystem():
	subsystems_to_shut_down = SubsystemInitOrder.keys().size()
	var subsystem_node : SubsystemBase = DataRepository.Server.get_node(next_subsystem_to_shutdown)
	Logging.log_notice("[SUBSYSTEM MGMT] Shutting down subsystem "+next_subsystem_to_shutdown+"...")
	subsystem_node.subsystem_shutdown.connect(Callable(self, "SubsystemShutdownCallback"))
	subsystem_node.SubsystemShutdown(next_subsystem_to_shutdown)

			
func SubsystemInitCallback(i:String, subsystem_node:Node):
	subsystem_node.subsystem_start_success.disconnect(Callable(self, "SubsystemInitCallback"))
	subsystems_loaded += 1
	Logging.log_notice("[SUBSYSTEM MGMT] Subsystem "+i+" loaded. "+str(subsystems_loaded)+"/"+str(subsystems_to_load)+" subsystems loaded.")
	subsystem_manager_loaded_subsystem.emit(i, subsystem_node)
	if subsystems_loaded == subsystems_to_load:
		Logging.log_notice("[SUBSYSTEM MGMT] All subsystems loaded!")
		subsystems_init_complete.emit()
		DataRepository.SetServerState(DataRepository.SERVER_STATE.SERVER_LOADED)
		return
	else:
		next_subsystem_to_load = SubsystemInitOrder.keys()[subsystems_loaded]
		InitializeNextSubsystem()
	
func SubsystemShutdownCallback(i:String, subsystem_node:Node):
	subsystem_node.subsystem_shutdown.disconnect(Callable(self, "SubsystemShutdownCallback"))
	subsystems_shutdown += 1
	Logging.log_notice("[SUBSYSTEM MGMT] Subsystem "+i+" shut down. "+str(subsystems_shutdown)+"/"+str(subsystems_to_shut_down)+" subsystems shut down.")
	if subsystems_shutdown == subsystems_to_shut_down:
		Logging.log_notice("[SUBSYSTEM MGMT] All subsystems shut down!")
		DataRepository.SetServerState(DataRepository.SERVER_STATE.CAN_SHUTDOWN)
		subsystems_shutdown_complete.emit()
		Logging.log_notice("[SERVER INIT] Arcadia Server v"+DataRepository.serverversion+" exiting...")
		await get_tree().create_timer(1).timeout
		get_tree().quit()
	else:
		next_subsystem_to_shutdown = ReverseInitOrder[subsystems_shutdown]
		ShutdownNextSubsystem()
	

	
