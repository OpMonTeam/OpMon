extends Control

var _curpos = 0
var _positions = [Vector2(12,20),Vector2(12,63),Vector2(132,20),Vector2(132,63)]

func _ready():
	print("BattleDialog")

func _process(delta):
	if self.visible:
		var olcur = _curpos
		if Input.is_action_just_pressed("ui_down") and _curpos % 2 == 0: # If down and in the upper part of box
			_curpos += 1
		elif Input.is_action_just_pressed("ui_up") and _curpos % 2 == 1: # If up and in the lower part of the box
			_curpos -= 1
		elif Input.is_action_just_pressed("ui_right") and _curpos < 2: # If right and in the left part of the box
			_curpos += 2
		elif Input.is_action_just_pressed("ui_left") and _curpos >= 2: # If left and in the right part of the box
			_curpos -= 2
		if olcur != _curpos: # Update the position only if the position has changed
			$Small_Dialog/Arrow.rect_position = _positions[_curpos]
