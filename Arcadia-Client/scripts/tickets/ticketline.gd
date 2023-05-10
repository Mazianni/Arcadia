extends Node

onready var TimestampLabel = $HBoxContainer/Panel3/Timestamp
onready var SenderLabel = $HBoxContainer/Panel2/SenderLabel
onready var MessageLabel = $HBoxContainer/Panel/MsgLabel

var timestamp
var sender
var message

func _ready():
	TimestampLabel.text = timestamp
	SenderLabel.text = sender
	MessageLabel.text = message
