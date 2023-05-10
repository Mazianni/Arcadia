extends Control

var pwdvalid_lowercase = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
var pwdvalid_uppercase = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var pwdvalid_numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
var pwdvalid_symbols = ["!", "@", "#", "$", "%", "^", "&", "*"]

#screen vars
onready var loginbox = get_node("NinePatchRect/LoginBox")
onready var accountbox = get_node("NinePatchRect/AccountBox")

onready var username_input = get_node("NinePatchRect/LoginBox/Username")
onready var userpassword_input = get_node("NinePatchRect/LoginBox/Password")
onready var login_button = get_node("NinePatchRect/LoginBox/LoginButton")
onready var create_account_button = get_node("NinePatchRect/LoginBox/CreateAccount")
onready var login_error_text = get_node("NinePatchRect/LoginBox/ButtonMargin/LoginError")
#create account
onready var create_username_input = get_node("NinePatchRect/AccountBox/UsernameInput")
onready var create_userpassword_input = get_node("NinePatchRect/AccountBox/PasswordInput")
onready var create_userpassword_confirm_input = get_node("NinePatchRect/AccountBox/RepeatPass")
onready var create_confirm_button= get_node("NinePatchRect/AccountBox/Confirm")
onready var create_back_button = get_node("NinePatchRect/AccountBox/Back")


func _ready():
	Globals.currentscene = Globals.CURRENT_SCENE.SCENE_LOGIN
	get_node("LoginAnimationPlayer").set_current_animation("fadein")

func _on_LoginButton_pressed():
	if username_input.text == "" or userpassword_input.text == "":
		Gui.CreateFloatingMessage("Please enter a valid username and password!", "bad")
	else:
		DisableInputs()
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		print("Attempting to Login...")
		Server.ConnectToServer()
		Server.Login(username, password, Globals.uuid, Globals.persistent_uuid)
		username = ""
		password = ""
		Server.network.connect("connection_failed", self, "_OnConnectionFailed")
		Server.network.connect("server_disconnected", self, "_OnDisconnected")
		Gui.CreateFloatingMessage("Attempting to connect to server...", "neutral")
		
func _OnConnectionFailed():
	Gui.CreateFloatingMessage("Failed to connect to server.", "bad")
	Server.network.disconnect("connection_failed", self, "_OnConnectionFailed")
	EnableInputs()
	
func _OnDisconnected():
	Server.network.disconnect("server_disconnected", self, "_OnDisconnected")
	print("disconnected")
	EnableInputs()
	
func DisableInputs():
	login_button.disabled = true
	create_account_button.disabled = true
	username_input.editable = false
	userpassword_input.editable = false
	
func EnableInputs():
	login_button.disabled = false
	create_account_button.disabled = false
	username_input.editable = true
	userpassword_input.editable = true
	
func _on_CreateAccount_pressed():
	loginbox.hide()
	accountbox.show()

func _on_Back_pressed():
	loginbox.show()
	accountbox.hide()

func _on_Confirm_pressed():
	if create_username_input.get_text() == "":
		Gui.CreateFloatingMessage("Please enter a valid username!", "bad")
	elif create_userpassword_input.get_text() =="":
		Gui.CreateFloatingMessage("Please enter a valid password.", "bad")
	elif create_userpassword_input.get_text().length() <= 6:
		Gui.CreateFloatingMessage("Passwords must be longer than six characters.", "bad")	
	elif create_userpassword_confirm_input.get_text() != create_userpassword_input.get_text():
		Gui.CreateFloatingMessage("Password and password confirmation do not match.", "bad")
	elif !ValidatePassword(create_userpassword_input.get_text()):
		Gui.CreateFloatingMessage("Valid passwords must contain: a capital/lowercase letter, a symbol, a number, and be six characters long.", "bad")
	var username = create_username_input.get_text()
	var password = create_userpassword_input.get_text()
	DisableInputs()
	Server.ConnectToServer()
	Server.CreateAccount(username, password)
	username = ""
	password = ""

func ValidatePassword(text):
	var valid = 0
	for i in pwdvalid_lowercase:
		if i in text:
			valid += 1
			break
			
	for i in pwdvalid_uppercase:
		if i in text:
			valid += 1
			break
			
	for i in pwdvalid_numbers:
		if i in text:
			valid += 1
			break
			
	for i in pwdvalid_symbols:
		if i in text:
			valid += 1
			break
			
	if valid == 4:
		return true
	else:
		return false
		
