class_name AdminManager extends SubsystemBase

enum RANK_FLAGS {NONE, MANAGE_TICKETS, IS_STAFF, PLAYER_NOTES,TELEPORT, ALL}
enum TICKET_FLAGS {TICKET_OPEN, TICKET_STAFF_ASSIGNED, TICKET_CLOSED}

@onready var admin_directory = "user://" + "admin"
@onready var Server = get_tree().get_root().get_node("Server")

var next_ticket_status_check = 0

var ranks : Dictionary = {
	"Admin Test Rank":{
		"RankNameShort" : "Test",
		"RankNameLong" : "Test Rank",
		"TagColor" : "#ffa970",
		"Permissions" : [RANK_FLAGS.ALL]
	},
	"Test Rank":{
		"RankNameShort" : "Test",
		"RankNameLong" : "Test Rank",
		"TagColor" : "#ffa970",
		"Permissions" : [RANK_FLAGS.NONE]
	}
}
var ban_data : Dictionary = {
	"banned_ips":[],
	"banned_uuids":[],
	"banned_users":[]
}
var player_notes : Dictionary = {}
var tickets : Dictionary = {}
var ticket_dict_skeleton = {
	"Creator":"",
	"Title":"",
	"AssignedStaff":"",
	"Usernames":[],
	"Messages":{},
	"Critical":false,
	"AdminCreated":false,
	"Status": TICKET_FLAGS.TICKET_OPEN
}
var player_note_dict_skeleton = {
	"Creator":"",
	"Description":"",
	"Date":"",
	"LastEdited":"",
	"Note":""
}
var ban_dict_skeleton = {
	"Username":"",
	"Duration":"",
	"ip":"",
	"uuid":""
}

signal admin_data_loaded

func SubsystemInit(node_name:String):
	CheckBanDataExists()
	
func SubsystemShutdown(node_name:String):
	subsystem_shutdown.emit(node_name, self)
	
func _process(delta):
	
	if Time.get_unix_time_from_system() >= next_ticket_status_check || !next_ticket_status_check:
		next_ticket_status_check = Time.get_unix_time_from_system() + 600 #10 minutes
		var tickets_without_staff : int = 0
		for I in tickets.keys():
			if tickets[I]["Status"] == TICKET_FLAGS.TICKET_OPEN:
				if !IsTicketClaimedByStaff(I):
					tickets_without_staff += 1
		if tickets_without_staff == 0:
			return
		for I in get_tree().get_nodes_in_group("players"):
			if HasRank(I):
				if CheckPermissions(RANK_FLAGS.MANAGE_TICKETS, I):
					Server.SendSingleChat(ChatHandler.FormatSimpleMessage("[There are "+str(tickets_without_staff)+" tickets without a staff member assigned.]"), I.associated_pid)
		
func CheckBanDataExists():
	var dir = DirAccess.open(admin_directory)
	var error = OK
	Logging.log_notice("[ADMIN] Loading admin data...")
	if not dir.dir_exists(admin_directory):
		dir.make_dir(admin_directory)
		Logging.log_notice("[ADMIN] Creating save directory for admin data at dir " + admin_directory)
	if not dir.file_exists(admin_directory+"/"+"ban_data.json"):
		var newsave = FileAccess.open(admin_directory+"/"+"ban_data.json", FileAccess.WRITE)
		newsave.store_line(JSON.stringify(ban_data))
		Logging.log_notice("[ADMIN] Creating JSON for ban data.")
		newsave.close()
	if not dir.file_exists(admin_directory+"/"+"player_note_data.json"):
		var newsave = FileAccess.open(admin_directory+"/"+"player_note_data.json", FileAccess.WRITE)
		newsave.store_line(JSON.stringify(player_notes))
		Logging.log_notice("[ADMIN] Creating JSON for player note data.")
		newsave.close()
	LoadBanData()

		
func LoadBanData():
	var loadfile = FileAccess.open(admin_directory+"/"+"ban_data.json", FileAccess.READ)
	var bandict : Dictionary
	var test_json_conv = JSON.new()
	test_json_conv.parse(loadfile.get_as_text())
	var temp = test_json_conv.get_data()
	if(temp):
		bandict = temp.duplicate(true)
	loadfile.close()
	admin_data_loaded.emit()
	subsystem_start_success.emit(name, self)
		
func CheckBanned(username:String, puuid:String, ip:String): # returns false if not banned
	var result = OK
	print("user "+username)
	print("puuid "+puuid)
	print("ip "+ip)
	if !username:
		result = ERR_PARSE_ERROR
		return result
	if !puuid:
		result = ERR_PARSE_ERROR
		return result
	if !ip:
		result = ERR_PARSE_ERROR
		return result
	if username in ban_data["banned_users"]:
		result = FAILED
		Logging.log_warning("[ADMIN] Banned user " + username + " attempted login.")
		if !puuid in ban_data["banned_uuids"]:
			ban_data["banned_uuids"].append(puuid)
			Logging.log_warning("[ADMIN] Banned user" + username + " attempted login from unique persistent UUID.")
		if !ip in ban_data["banned_ips"]:
			ban_data["banned_ips"].append(ip)
			Logging.log_warning("[ADMIN] Banned user" + username + " attempted from unique IP.")
	elif puuid in ban_data["banned_uuids"]:
		result = FAILED
		Logging.log_warning("[ADMIN] User " + username + " attempted login from banned persistent UUID.")
		if !username in ban_data["banned_users"]:
			ban_data["banned_users"].append(username)
			Logging.log_warning("[ADMIN] User " + username + " added to ban database.")
		if !ip in ban_data["banned_ips"]:
			ban_data["banned_ips"].append(ip)
			Logging.log_warning("[ADMIN] IP of " + username + " added to ban database.")
	elif ip in ban_data["banned_ips"]:
		result = FAILED
		Logging.log_warning("[ADMIN] User " + username + " attempted login from banned IP.")
		if !username in ban_data["banned_users"]:
			ban_data["banned_users"].append(username)
			Logging.log_warning("[ADMIN] User " + username + " added to ban database.")
		if !puuid in ban_data["banned_uuids"]:
			ban_data["banned_uuids"].append(puuid)
			Logging.log_warning("[ADMIN] New unique UUID added to ban database.")
	return result
		
func IsRankValid(player:PlayerContainer):
	if player.PlayerData.Rank in ranks.keys():
		return true
	else:
		return false
	
func HasRank(player:PlayerContainer):
	if player.PlayerData.Rank:
		return true
	return false
	
func GetRank(player:PlayerContainer):
	return player.PlayerData.Rank
	
func GetRankColor(player:PlayerContainer):
	print(player.PlayerData.Rank)
	if IsRankValid(player):
		return ranks[GetRank(player)]["TagColor"]
	Logging.log_error("[RANKS] Invalid Rank supplied to GetRankColor!")
	return null
	
func GetRankTitleShort(player:PlayerContainer):
	return ranks[GetRank(player)]["RankNameShort"]
	
func IsStaff(player:PlayerContainer):
	if HasRank(player):
		if CheckPermissions(RANK_FLAGS.IS_STAFF, player):
			return true
		if CheckPermissions(RANK_FLAGS.ALL, player):
			return true
	return false
	
func RetrievePermissions(player:PlayerContainer):
	if HasRank(player):
		return ranks[player.PlayerData.Rank]["Permissions"]
		
func CheckPermissions(required: int, player_id:PlayerContainer):
	var permission = required
	if !permission:
		Logging.log_error("[RANKS] Permission supplied was null or invalid!")
		return false
	if !GetRank(player_id):
		return false #user has no rank
	if !IsRankValid(player_id):
		Logging.log_error("[RANKS] User "+ str(player_id.PlayerData.Username) +" has an invalid rank:" + str(player_id.PlayerData.Rank))
		return false
	if RetrievePermissions(player_id).has(RANK_FLAGS.ALL):
		return true
	if ranks[GetRank(player_id)]["Permissions"].has(required):
		return true
	return false
	
func PermissionString2Enum(input: String):
	match input:
		"None":
			return RANK_FLAGS.NONE
		"Manage Tickets":
			return RANK_FLAGS.MANAGE_TICKETS
		"Is Staff":
			return RANK_FLAGS.IS_STAFF
		"Player Notes":
			return RANK_FLAGS.PLAYER_NOTES
		"All": 
			return RANK_FLAGS.ALL
	Logging.log_error("[PERMISSIONS] Invalid Permission "+str(input))
	
#tickets
	
func NotifyStaffTicketCreated(title:String, number:int):
	Helpers.NotifyStaff("[A new ticket has been opened: #"+str(number)+" - " +title+"]")
		
func NotifyTicketClosed(number:String, by_admin:bool = false, staff_user:String = ""):
	if by_admin:
		Helpers.NotifyUsersInArray(tickets[number]["Usernames"],"[Ticket #"+str(number)+" has been closed by "+staff_user+"]")	
	else:	
		Helpers.NotifyUsersInArray(tickets[number]["Usernames"],"[Ticket #"+str(number)+" has been closed.]")		
			
func CreateTicket(creator:String, username:String, title:String, details:String, critical:bool = false, admin_created:bool = false):
	var ticket_skeleton = ticket_dict_skeleton.duplicate(true)
	var ticketnumber = str(tickets.keys().size())
	ticket_skeleton["Creator"] = creator
	ticket_skeleton["Title"] = title
	if(username):
		ticket_skeleton["Usernames"].append(username)
	if !creator in ticket_skeleton["Usernames"]:
		ticket_skeleton["Usernames"].append(creator)
	ticket_skeleton["Critical"] = critical
	ticket_skeleton["AdminCreated"] = admin_created
	tickets[ticketnumber] = ticket_skeleton
	if critical:
		pass #TODO discord webhook integration here
	if admin_created:
		Server.SendSingleChat(ChatHandler.FormatSimpleMessage("[b]An administrator has opened a new ticket with you.[/b]"), Helpers.Username2PID(username))
		Server.SendSingleChat(ChatHandler.FormatSimpleMessage("[b]You've opened a new ticket with "+username+".[/b]"), Helpers.Username2PID(creator))
	else:
		Server.SendSingleChat(ChatHandler.FormatSimpleMessage("[b]You've opened a new ticket.[/b]"), Helpers.Username2PID(creator))
	NotifyStaffTicketCreated(title, tickets.keys().size())
	tickets[ticketnumber]["Messages"]["0"] = {"Sender":creator, "T":Time.get_time_string_from_system(true),"Message":title}
	tickets[ticketnumber]["Messages"]["1"] = {"Sender":creator, "T":Time.get_time_string_from_system(true),"Message":details}
	for I in tickets[ticketnumber]["Usernames"]:
		Server.PushTicketsToClient(Helpers.Username2PID(I), GetTicketsWithUser(I))
		
func CloseTicket(ticket_number:String, pid:int):
	if tickets[ticket_number]["Status"] != TICKET_FLAGS.TICKET_CLOSED:
		if Server.has_node(str(pid)):
			if tickets[ticket_number]["AdminCreated"]:
				if CheckPermissions(RANK_FLAGS.MANAGE_TICKETS, Server.get_node(str(pid))):
					tickets[ticket_number]["Status"] = TICKET_FLAGS.TICKET_CLOSED
					NotifyTicketClosed(ticket_number, true, Helpers.PID2Username(pid))
					tickets[ticket_number]["Title"] += " [CLOSED]"
					tickets[ticket_number]["Messages"][tickets[ticket_number]["Messages"].size()] = {
					"Sender":"SYSTEM",
					"T":Time.get_time_string_from_system(true),
					"Message": "Ticket " +  ticket_number + " has been marked as CLOSED."
					}
					UpdateTicketMessages(ticket_number)
				else:
					return false
			else:
				tickets[ticket_number]["Status"] = TICKET_FLAGS.TICKET_CLOSED
				tickets[ticket_number]["Title"] += " [CLOSED]"
				tickets[ticket_number]["Messages"][str(tickets[ticket_number]["Messages"].size())] = {
			"Sender":"SYSTEM",
			"T":Time.get_time_string_from_system(true),
			"Message": "Ticket " +  ticket_number + " has been marked as CLOSED."
			}
				NotifyTicketClosed(ticket_number, false, Helpers.PID2Username(pid))
				UpdateTicketMessages(ticket_number)
				return true
		return false
	return false
	
func GetTicketsWithUser(username:String):
	var return_dict : Dictionary = tickets.duplicate(true)
	for I in return_dict.keys():
		if !username in tickets[I]["Usernames"]:
			return_dict.erase(I)
	return return_dict
	
func GetAllTickets():
	var return_dict = tickets.duplicate(true)
	return return_dict
	
func IsTicketClaimedByStaff(ticket_number:String):
	for U in tickets[ticket_number]["Usernames"]:
		if U == tickets[ticket_number]["Creator"]:
			continue
		if DataRepository.PlayerMgmt.has_node(Helpers.Username2PID(U)):
			var user = DataRepository.PlayerMgmt.get_node(Helpers.Username2PID(U))
			if HasRank(user):
				if CheckPermissions(RANK_FLAGS.MANAGE_TICKETS, user):
					return true
				
func AddUserToTicket(username:String, ticket_number:String):
	tickets[ticket_number]["Usernames"].append(username)
	Server.SendSingleChat(ChatHandler.FormatSimpleMessage("You've been added to ticket #"+str(ticket_number)))
			
func ClaimTicket(username:String, ticket_number:String):
	if DataRepository.PlayerMgmt.has_node((Helpers.Username2PID(username))):
		var user = Server.get_node(Helpers.Username2PID(username))
		if HasRank(user):
			if CheckPermissions(RANK_FLAGS.MANAGE_TICKETS, user):
				tickets[ticket_number]["AssignedStaff"] += username
				AddMessageToTicket(user.PlayerData.Username + " has been assigned to ticket "+ticket_number, ticket_number,"", true)
				tickets[ticket_number]["Status"] = TICKET_FLAGS.TICKET_STAFF_ASSIGNED
				UpdateTicketMessages(ticket_number)

func UpdateTicketMessages(ticket_number:String):
	for I in tickets[ticket_number]["Usernames"]:
		var pid = Helpers.Username2PID(I)
		Server.UpdateTicket(pid, ticket_number, tickets[ticket_number].duplicate(true))

func AddMessageToTicket(message:String, ticket_number:String, player_id:String, is_system:bool = false):
	if !is_system:
		if !Helpers.PID2Username(int(player_id)) in tickets[ticket_number]["Usernames"]:
			Logging.log_error("[ADMIN] Client "+ str(player_id)+" Username "+Helpers.Username2PID(str(player_id)) + "attempted to add a message to a ticket they were not part of.")
			return
	var msgnumber = tickets[ticket_number]["Messages"].keys().size()
	if !is_system:
		tickets[ticket_number]["Messages"][str(msgnumber)] = {
			"Sender":Helpers.PID2Username(int(player_id)),
			"T":Time.get_time_string_from_system(true),
			"Message": message
			}
	else:
		tickets[ticket_number]["Messages"][str(msgnumber)] = {
			"Sender":"SYSTEM",
			"T":Time.get_time_string_from_system(true),
			"Message": message
			}
	for I in tickets[ticket_number]["Usernames"]:
		var pid = Helpers.Username2PID(I)
		Server.UpdateTicketMessages(ticket_number)
		if I != Helpers.PID2Username(int(player_id)) && !is_system:
			Server.SendSingleChat(ChatHandler.FormatSimpleMessage("A new message has been sent to ticket #"+str(ticket_number)), player_id)			
			
#end tickets

#player notes

func GetPlayerNotes():
	return player_notes.duplicate(true)

func AddPlayerNote(username:String, title:String, note:String, player_id:int):
	var new_note_dict = player_note_dict_skeleton.duplicate(true)
	new_note_dict["Creator"] = Helpers.PID2Username(player_id)
	new_note_dict["Description"] = title
	new_note_dict["Date"] = Time.get_date_string_from_system()
	new_note_dict["Note"] = note
	if player_notes.keys().has(username):
		player_notes[username]["Notes"][str(player_notes[username].size())] = new_note_dict
	else:
		player_notes[username] = {"Notes"={}}
		player_notes[username]["Notes"]["1"] = new_note_dict
	Logging.log_notice(Helpers.PID2Username(player_id) + "has added a new player note for "+username)

func RemovePlayerNote(username:String, note_number:String, player_id:int):
	if player_notes.has(username):
		if player_notes[username].has(note_number):
			player_notes[username].remove(note_number)
			Logging.log_notice(Helpers.PID2Username(player_id) + "has removed a player note for "+username)
	
func EditPlayerNote(username:String, note_number:String, new_note:String, player_id:int):
	if player_notes.has(username):
		if player_notes[username].has(note_number):
			player_notes[username][note_number]["Note"] = new_note
			player_notes[username][note_number]["LastEdited"] = Time.get_date_string_from_system()
			Logging.log_notice(Helpers.PID2Username(player_id) + "has edited a new player note for "+username)

#end player notes
