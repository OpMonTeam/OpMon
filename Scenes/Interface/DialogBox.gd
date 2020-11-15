extends Control

# Lines of dialog stored as an array
export var dialog_lines := ["Lorem ipsum dolor sit amet.", "Consectetur adipiscing elit, sed do eiusmod tempor incididunt."]

# Speed at which the dialog lines are displayed
export var dialog_speed := 10.0

# Index of the current shown dialog line
var _current_dialog_line_index := -1

# True if the current dialog line is fully printed
var _awaiting_next_dialog_line := false

# Timer for displaying dialog line characters one at a time
var _timer = null

func _ready():
	# Prepare the timer
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_one_shot(false)
	_timer.set_wait_time(1/dialog_speed)
	_start_new_line();

	# Start the animation of the dial arrow
	get_node("DialArrow/AnimationPlayer").current_animation = "idle"
	get_node("DialArrow/AnimationPlayer").playback_active = true

func _start_new_line():
	_current_dialog_line_index += 1
	$DialArrow.visible = false
	_awaiting_next_dialog_line = false
	_timer.start()
	$Text.visible_characters = 0
	$Text.text = dialog_lines[_current_dialog_line_index]

func _finish_current_line():
	$DialArrow.visible = true
	_awaiting_next_dialog_line = true
	_timer.stop()
	$Text.visible_characters = -1

func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if _awaiting_next_dialog_line:
			if _current_dialog_line_index < dialog_lines.size() - 1:
				_start_new_line()
		else:
			_finish_current_line()

func _on_Timer_timeout():
	$Text.visible_characters += 1
	if $Text.visible_characters == dialog_lines[_current_dialog_line_index].length():
		_finish_current_line()
