extends "res://Scenes/Interactable/Interactable.gd"

export var dialog_lines := ["Lorem ipsum dolor sit amet.", "Consectetur adipiscing elit, sed do eiusmod tempor incididunt."]

func interact():
	_dialog_box_instance = load(PATH_DIALOG_BOX_SCENE).instance()
	_dialog_box_instance.set_dialog_lines(dialog_lines)
	_root.add_child(_dialog_box_instance)
	_dialog_box_instance.go()
