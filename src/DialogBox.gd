extends NinePatchRect

var DialogBox = load("res://src/DialogBox.gd")

# The base dialog in one string
# This dialog will be split in several dialogues that will
# be played one after the other.
export var dialog: String
# How fast the dialog prints itself
# While the programmer enter the speed as "bigger the quicker",
# the script works in periods and not in frequency, so it
# automatically inverts the value
export var dialog_speed := 1.0
# The different dialogs to show
var _dialogs: Array
# The ID of the current shown dialog
var _current_dialog := 0
# If the current dialog is fully printed and the game waiting
# for the player to go to the next one
var _wait_next := false
# If all the dialogs has been printed
var _end := false
# Cooldown until the dialog refreshs again
var _next_update := 0.0

# When all the dialogs has been printed
signal dialog_ended

func _init():
	pass

func _ready():
	_dialogs = split_string(dialog)
	dialog_speed = 1.0 / dialog_speed # Allows user-friendly speed setting
	$Text.text = _dialogs[0]
	$Text.visible_characters = 0
	pass
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if _wait_next: # If the player wants to go to the next dialog
			$Array.rect_position.y = 60
			$Array.visible = false
			_wait_next = false
			$Text.visible_characters = 0
			_current_dialog += 1
			$DialogSound.play()
			if _current_dialog == _dialogs.size():
				emit_signal("dialog_ended")
				_end = true
			else:
				$Text.text = _dialogs[_current_dialog]
		else: # The player wants to skip the dialogue
			$Text.percent_visible = 1
			
	if _next_update <= 0.0 and not _end:
		if not _wait_next: # If the dialog is printing
			if $Text.percent_visible == 1: # If the dialog is fully printed
				_wait_next = true
				$Array.visible = true
			else:
				$Text.visible_characters += 1
		elif  _wait_next: # If all the dialog is printed
			# Little arrow animation
			$Array.rect_position.y += 2
			if $Array.rect_position.y >= 70:
				$Array.rect_position.y = 60
		_next_update = dialog_speed * 0.1
	_next_update -= delta

static func split_string(string: String, limit: int = 60) -> Array:
	var char_array := string.to_utf8() # The string parameter in an array of chararcters
	var return_array := [] # The array that will contain the String objects to return
	var future_string: PoolByteArray # A buffer that will contain the String that will be put into return_array
	var char_counter := 0 # Counts the characters
	for character in char_array:
		if char_counter > limit and character == 0x20: # If above the limit, waits for a space to split
			return_array.append(future_string.get_string_from_utf8())
			future_string = [] as PoolByteArray
			char_counter = 0
		else:
			future_string.append(character)
			char_counter += 1
	return return_array
