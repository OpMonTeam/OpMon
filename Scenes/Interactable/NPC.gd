extends "res://Scenes/Interactable/Interactable.gd"

export var dialog_lines := ["Fake line 1.", "Fake line 2."]

func interact():
	_dialog_box_instance = load(PATH_DIALOG_BOX_SCENE).instance()
	_dialog_box_instance.set_dialog_lines(dialog_lines)
	_root.add_child(_dialog_box_instance)
	_dialog_box_instance.go()
