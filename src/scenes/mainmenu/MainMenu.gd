extends Control

signal button_pressed(id)

var _selection := 0
var _buttons: Array


# Called when the node enters the scene tree for the first time.
func _ready():
	_buttons = [$Play as NinePatchRect, 
			   $Load as NinePatchRect,
			   $Settings as NinePatchRect, 
			   $Quit as NinePatchRect]
	connect("button_pressed", self, "pressed")
	_buttons[_selection].modulate = Color(1,1,1,1)


func _process(_delta):
	# Movements up and down
	var just_moved = false
	if Input.is_action_just_pressed("ui_up"):
		_selection -= 1
		if _selection < 0: _selection = 3
		$Change.play()
		just_moved = true
	elif Input.is_action_just_pressed("ui_down"):
		_selection += 1
		if _selection > 3: _selection = 0
		$Change.play()
		just_moved = true
	
	if just_moved: # Avoids refreshing all the time
		for button in _buttons: # Colors the active button
			button.modulate = Color(0.31,0.31,0.31,1) if button != _buttons[_selection] else Color(1,1,1,1)
	
	if Input.is_action_just_pressed("ui_accept"): # If a button is pressed
		emit_signal("button_pressed", _selection)


func pressed(id):
	if id == 3:
		get_tree().quit()
	elif id == 0:
		get_tree().change_scene("res://src/scenes/introscene/IntroScene.tscn")
	else:
		$Nope.play()
