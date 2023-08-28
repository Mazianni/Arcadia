class_name SpellTree extends Node


func SetLabel(lname):
	$Label.text = lname

func AddSpell(spell):
	$CenterContainer/Control.add_child(spell)

func GetContainerChildren():
	return $CenterContainer/Control.get_children()
	
func ContainerHasNode(node):
	return $CenterContainer/Control.has_node(node)
	
func ContainerGetNode(node):
	return $CenterContainer/Control.get_node(node)
