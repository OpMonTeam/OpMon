tool
extends "res://Scenes/Events/Interactable/DialogNPC.gd"

# List of instructions for the path
# Can't be empty
export(Array, String, "Left", "Right", "Up", "Down", "Stand") var path: Array

# Duration of each instruction of the path, in tiles
export(Array, int, 1, 1000000) var durations: Array
# These two arrays above must have the same size

# True if when the instructions of path are over, return at the beginning.
export(bool) var loop: bool

# True if the path goes to the next instruction even if the NPC couldn't move
export(bool) var progress_despite_obstacles: bool

# Keeps track of the current step of "path"
var _current_step := 0
# Counts the number of tiles the current instruction has been running
var _progress := 0
# If the movement is over
var _stopped := false
# A frame countdown for the "Stand" instruction
var _pause := -1
# Flag to start moving in _process instead of _ready to be sure
# every event is loaded
var start := false

func save() -> Dictionary:
	var ret := .save()
	ret["_current_step"] = _current_step
	ret["_progress"] = _progress
	ret["_stopped"] = _stopped
	ret["_pause"] = _pause
	return ret
	
func load_save(data: Dictionary) -> void:
	.load_save(data)
	_current_step = data["_current_step"]
	_progress = data["_progress"]
	_stopped = data["_stopped"]
	_pause = data["_pause"]

func _ready():
	# Checks for errors before initializing
	if path.size() == 0:
		push_error("No path defined, use DialogNPC instead.")
	if path.size() != durations.size():
		push_error("The array of durations does not have the same size as the array of paths.")
	if not Engine.editor_hint:
		start = true
	._ready()

func _next_move():
	_check_pending_interaction()
	if _paused: # Stop the animation if the movement is paused.
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
		return
	# When the instruction has been running long enough
	if _progress == durations[_current_step]:
		_progress = 0
		_current_step+=1
	# If the current step is the last one
	if _current_step == path.size():
		if loop:
			_current_step = 0
			_progress = 0
		else: # Definitely stop the movement
			_stopped = true
			$AnimatedSprite.stop()
			$AnimatedSprite.frame = 0
			return
	var dir: Vector2 = _get_direction(path[_current_step])
	if dir != Vector2.ZERO: # It it is a movement
		_moving = Vector2.ZERO
		if move(dir) or progress_despite_obstacles:
			_progress+=1
	else: # The "Stand" instruction
		_pause = 16
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0

func _process(_delta):
	if not Engine.editor_hint:
		if start:
			start = false
			_next_move()
		elif _pause == 0: # If the "Stand" instruction is over
			_progress+=1
			_pause = -1
			_next_move()
		elif _pause > 0: # Else continue the countdown
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
	call_deferred("_next_move")
