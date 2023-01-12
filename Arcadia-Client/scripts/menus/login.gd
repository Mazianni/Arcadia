extends Control

onready var username_input = get_node("NinePatchRect/VBoxContainer/Username")
onready var userpassword_input = get_node("NinePatchRect/VBoxContainer/Password")
onready var login_button = get_node("NinePatchRect/VBoxContainer/LoginButton")


func _on_LoginButton_pressed():
	if username_input.text == "" or userpassword_input.text == "":
		print("Please input a valid username and password.")
	else:
		login_button.disabled = true
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		print("Attempting to Login...")
		Gateway.ConnectToServer(username, password)
		
func _on_CreateAccount_pressed():
	pass # Replace with function body.
