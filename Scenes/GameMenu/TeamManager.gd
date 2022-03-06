extends Control

var opmons := []

var selection := 0

signal choice(id)

func _ready():
	opmons.append($Mon1)
	opmons.append($Mon2)
	opmons.append($Mon3)
	opmons.append($Mon4)
	opmons.append($Mon5)
	opmons.append($Mon6)

func _input(event):
	# Conditions on selection are here to avoid warping
	if event.is_action_pressed("ui_accept"):
		emit_signal("choice", selection)
		emit_signal("closed")
	elif event.is_action_pressed("menu"):
		emit_signal("closed")
	elif event.is_action_pressed("ui_down") and selection != 4:
		selection += 2
	elif event.is_action_pressed("ui_up") and selection != 1:
		selection -= 2
	elif event.is_action_pressed("ui_left") and selection % 2 == 1:
		selection -= 1
	elif event.is_action_pressed("ui_right") and selection % 2 == 0:
		selection += 1
	if selection < 0:
			selection = 0
	elif selection > 5:
		selection = 5
	$Selrect.rect_position = opmons[selection].rect_position
