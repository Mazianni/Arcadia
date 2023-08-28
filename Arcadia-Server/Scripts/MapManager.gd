class_name MapManager extends SubsystemBase

var MapsToLoad : Dictionary = {"Test" : load("res://Scenes/maps/Test/Test.tscn")} #formatted as "mapname" : path_to_map.tscn
var NumLoaded : int = 0
var DefaultSpawnMap

func SubsystemInit(node_name:String):
	LoadMaps()
	
func SubsystemShutdown(node_name:String):
	subsystem_shutdown.emit(node_name, self)

func LoadMaps():
#TODO add server state stuff
	Logging.log_notice("[MAP] Loading Maps...")
	Logging.log_notice("[MAP] Total maps to load: "+str(MapsToLoad.size()))
	if MapsToLoad.size():
		for i in MapsToLoad.keys():
			var new_instance = MapsToLoad[i].instantiate()
			self.add_child(new_instance)
			new_instance.name = new_instance.map_name
			new_instance.GenerateWarpers()
			new_instance.z_index = NumLoaded
			NumLoaded += 1	
			Logging.log_notice("[MAP] Map "+ new_instance.map_name+ " Loaded. "+str(NumLoaded)+"/"+str(MapsToLoad.size()))
			if new_instance.default_spawn_map:
				DefaultSpawnMap = new_instance
			if NumLoaded == MapsToLoad.size():
				Logging.log_notice("[MAP] All maps loaded.")
				subsystem_start_success.emit(name, self)
				break

func MovePlayerToMapStandalone(playerNode : PlayerCollider, NewMap, position): #used when spawning a new player collider.
	Logging.log_notice("Moving player to map "+str(NewMap)+".")
	get_node(NewMap).AddPlayerChild(playerNode)
	playerNode.CurrentMap = NewMap
	playerNode.ControllingCharacter.CurrentMap = NewMap
	playerNode.ControllingCharacter.CurrentPosition = position
	playerNode.position = position
	DataRepository.Server.SyncClientMap(playerNode.ControllingCharacter.ActiveController.associated_pid, NewMap)

func MovePlayerToMap(playerNode, OldMap, NewMap, position): #used when transitioning between maps via warpers.
	Logging.log_notice("Moving player to map "+str(NewMap)+" from "+str(OldMap)+".")
	get_node(OldMap).RemovePlayerChild(playerNode)
	get_node(NewMap).AddPlayerChild(playerNode)
	playerNode.CurrentMap = NewMap
	playerNode.ControllingCharacter.CurrentMap = NewMap
	playerNode.ControllingCharacter.CurrentPosition = position
	DataRepository.Server.SyncClientMap(playerNode.ControllingCharacter.ActiveController.associated_pid, NewMap)

func GenerateMapGroundItemDict(map_name : String):
	var map : MapBase = get_node(map_name)
	return map.GenerateGroundItemDict()
	
func GenerateMapObjects(map_name : String):
	var map : MapBase = get_node(map_name)
	return map.GenerateMapObjects()
