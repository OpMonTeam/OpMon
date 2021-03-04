extends Control

# Speed at which the dialog lines are displayed
export var dialog_speed := 10.0

# Lines of dialog stored as an array
var _dialog_lines

# Index of the current shown dialog line
var _current_dialog_line_index := -1

# True if the current dialog line is fully printed
var _awaiting_next_dialog_line := false

# Timer for displaying dialog line characters one at a time
var _timer = null

var _dial_arrow

var _text

var _manager

func set_dialog_lines(dialog_lines):
	_dialog_lines = dialog_lines

func go():
	# Display the first line of dialogue
	_start_new_line();

	# Start the animation of the dial arrow
	_dial_arrow.get_node("AnimationPlayer").current_animation = "idle"
	_dial_arrow.get_node("AnimationPlayer").playback_active = true

func _ready():
	_manager = get_node("/root/Manager") as Manager
	_manager.pause_player()
	
	_dial_arrow = get_node("NinePatchRect/DialArrow")
	_text = get_node("NinePatchRect/Text")

	# Prepare the timer
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_one_shot(false)
	_timer.set_wait_time(1/dialog_speed)

func _exit_tree():
	_manager.unpause_player()

func _start_new_line():
	_current_dialog_line_index += 1
	_dial_arrow.visible = false
	_awaiting_next_dialog_line = false
	_timer.start()
	_text.visible_characters = 0
	_text.text = _dialog_lines[_current_dialog_line_index]

func _finish_current_line():
	_dial_arrow.visible = true
	_awaiting_next_dialog_line = true
	_timer.stop()
	_text.visible_characters = -1

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if _awaiting_next_dialog_line:
			if _current_dialog_line_index < _dialog_lines.size() - 1:
				_start_new_line()
			else:
				queue_free()
		else:
			_finish_current_line()

func _on_Timer_timeout():
	_text.visible_characters += 1
	if _text.visible_characters == _dialog_lines[_current_dialog_line_index].length():
		_finish_current_line()
