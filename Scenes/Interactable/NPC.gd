extends "res://Scenes/Interactable/Interactable.gd"

export var dialog_lines := ["Lorem ipsum dolor sit amet.", "Consectetur adipiscing elit, sed do eiusmod tempor incididunt."]

func interact():
	_root.add_child(_dialog_box_instance)
