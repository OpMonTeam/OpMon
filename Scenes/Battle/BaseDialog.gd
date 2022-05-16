extends Control

var _curpos = 0
const _positions = [Vector2(12,20),Vector2(12,63),Vector2(132,20),Vector2(132,63)]

signal move_selected
signal item_selected
signal opmon_selected
signal run_selected

const _signals = ["move_selected", "item_selected", "opmon_selected", "run_selected"]

var cooldown := 5

func _ready():
	for s in _signals:
		connect(s, get_parent(), s)
	$BigDialog/RichTextLabel.text = tr("BATTLE_BASEDIALOG_FILLER").replace("{opmon}",get_parent().player_opmon.get_effective_name())

func _process(_delta):
	if cooldown > 0 and visible:
		cooldown -= 1

func _input(event):
	if self.visible and cooldown == 0:
		var olcur = _curpos
		if event.is_action_pressed("ui_down") and _curpos % 2 == 0: # If down and in the upper part of box
			_curpos += 1
		elif event.is_action_pressed("ui_up") and _curpos % 2 == 1: # If up and in the lower part of the box
			_curpos -= 1
		elif event.is_action_pressed("ui_right") and _curpos < 2: # If right and in the left part of the box
			_curpos += 2
		elif event.is_action_pressed("ui_left") and _curpos >= 2: # If left and in the right part of the box
			_curpos -= 2
		elif event.is_action_pressed("ui_accept"):
			emit_signal(_signals[_curpos])
			cooldown = 5
		if olcur != _curpos: # Update the position only if the position has changed
			$SmallDialog/Arrow.rect_position = _positions[_curpos]
