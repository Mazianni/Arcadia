class_name SpellTreeNode extends Node

signal clicked(name)

func SetIcon(icon:Texture2D):
	$VBoxContainer/Button.icon = icon

func _on_button_pressed():
	clicked.emit(name)
