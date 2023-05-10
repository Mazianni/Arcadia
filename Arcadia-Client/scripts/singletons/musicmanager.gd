extends Node

var track_lists : Dictionary = {
	"Login" : {
		"Arcane Realm":{"author":"Gabriel Solas/Solas Composer","stream":load("res://sounds/music/arcanerealm.ogg"), "url":"https://solas1111.bandcamp.com/"},
		"Home At Last":{"author":"Gabriel Solas/Solas Composer","stream":load("res://sounds/music/homeatlast.ogg"), "url":"https://solas1111.bandcamp.com/"},
		"Sea Of Stars":{"author":"Gabriel Solas/Solas Composer","stream":load("res://sounds/music/seaofstars.ogg"), "url":"https://solas1111.bandcamp.com/"},
		"Song Of The Free":{"author":"Gabriel Solas/Solas Composer","stream":load("res://sounds/music/songofthefree.ogg"), "url":"https://solas1111.bandcamp.com/"},
		"The Lands Between":{"author":"Gabriel Solas/Solas Composer","stream":load("res://sounds/music/thelandsbetween.ogg"), "url":"https://solas1111.bandcamp.com/"},
		"Realm Of The Eternal":{"author":"Gabriel Solas/Solas Composer","stream":load("res://sounds/music/realmoftheeternal.ogg"), "url":"https://solas1111.bandcamp.com/"},
		"From The Ashes":{"author":"Gabriel Solas/Solas Composer","stream":load("res://sounds/music/fromtheashes.ogg"), "url":"https://solas1111.bandcamp.com/"}
	}
}
var current_track_list : String = "Login"
var last_played_track : String
onready var music_player : AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(music_player)
	music_player.connect("finished", self, "OnTrackFinished")
	get_tree().get_root().get_node("Settings").connect("settings_loaded", self, "OnSettingsLoaded")
	yield(get_tree().create_timer(0.01), "timeout")
	OnTrackFinished()
	
func OnSettingsLoaded():
	print("dfsih")
	music_player.set_volume_db(linear2db(Settings.CurrentSettingsDict["Music Volume"]))
	
func OnTrackFinished(pick_new : bool = false):
	if pick_new:
		yield(get_tree().create_timer(0.5), "timeout")
	var track_array = track_lists[current_track_list].keys()
	var new_track = track_array[randi() % track_array.size()]
	var message
	if new_track == last_played_track: #we don't want to play the same track over and over.
		OnTrackFinished(true)
		return
	last_played_track = new_track
	print("playing new track " + new_track)
	music_player.stream = track_lists[current_track_list][new_track]["stream"]
	music_player.play()
	message = "Now playing "+new_track+"\nBy "+track_lists[current_track_list][new_track]["author"]
	if(track_lists[current_track_list][new_track]["url"]):
		message += "\n"+track_lists[current_track_list][new_track]["url"]
	print(message)
	Gui.CreateEaseFloatingMessage(message)
