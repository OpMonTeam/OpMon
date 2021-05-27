extends "res://Scenes/Events/Interactable/Character.gd"

const InteractableClass = preload("Interactable.gd")

# The current trigger the player is walking on
var _walking_on: Trigger = null

func _process(_delta):
	if _walking_on != null:
		_walking_on.frame()
	if not self._paused:
		if Input.is_action_just_pressed("ui_accept"):
			_interact()
		_check_move()
		update()
		
# Checks if the player wants to move the character and starts
# the movement if so.
func _check_move():
	var input_direction = _get_input_direction()
	if input_direction and not _moving:
		move(input_direction) # Move in this direction
	elif _moving:
		stop_move()

func _get_input_direction():
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var vertical_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if abs(horizontal_input) > abs(vertical_input):
		return Vector2(horizontal_input, 0)
	elif  abs(vertical_input) > abs(horizontal_input):
		return Vector2(0, vertical_input)
	else:
		return Vector2(0, 0)

# Interacts with an Interactable event if there is one
func _interact():
	var collider = _get_collider(_faced_direction) # Returns what's in front of the player
	if collider != null and collider is InteractableClass: # If it can be interacted with
		collider = collider as InteractableClass
		collider.interact(self)

func set_trigger(trigger: Trigger):
	if _walking_on == null:
		_walking_on = trigger
		return true
	else:
		return false
