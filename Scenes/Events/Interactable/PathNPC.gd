extends "res://Scenes/Events/Interactable/DialogNPC.gd"

export(Array, String, "Left", "Right", "Up", "Down", "Stand") var path: Array

export(Array, int, 1, 1000000) var durations: Array

export(bool) var loop: bool

export(bool) var progress_despite_obstacles: bool

var _current_step: int = 0
var _progress: int = 0
var _stopped: bool = false
var _pause: int = -1

func _enter_tree():
	if path.size() == 0:
		push_error("No path defined, use DialogNPC instead.")
	if path.size() != durations.size():
		push_error("the array of durations does not have the same size as the array of paths.")
	._enter_tree()

func _ready():
	_next_move()

func _next_move():
	if _paused:
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
		return
	if _progress == durations[_current_step]:
		_progress = 0
		_current_step+=1
	if _current_step == path.size():
		if loop:
			_current_step = 0
			_progress = 0
		else:
			_stopped = true
			$AnimatedSprite.stop()
			$AnimatedSprite.frame = 0
			return
	var dir: Vector2 = _get_direction(path[_current_step])
	if dir != Vector2.ZERO:
		_moving = Vector2.ZERO
		if move(dir) or progress_despite_obstacles:
			_progress+=1
	else:
		_pause = 16
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0

func _process(_delta):
	if _pause == 0:
		_progress+=1
		_pause = -1
		_next_move()
	elif _pause > 0:
		_pause -= 1
	._process(_delta)

func _get_direction(sdir: String):
	match sdir:
		"Up":    return Vector2.UP
		"Down":  return Vector2.DOWN
		"Left":  return Vector2.LEFT
		"Right": return Vector2.RIGHT
		"Stand": return Vector2.ZERO
		
func _end_move(_1, _2):
	_next_move()
	
func _unpause():
	._unpause()
	_next_move()
