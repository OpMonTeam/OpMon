@tool
extends "res://Scenes/Events/Interactable/Character.gd"

const InteractableClass = preload("Interactable.gd")

var player_data: PlayerData

func _ready():
	super._ready()
	player_data = get_node("/root/PlayerData")

func _input(event):
	if not Engine.is_editor_hint():
		if event.is_action_pressed("interact") and not _paused:
			_interact()

func _process(_delta):
	if not self._paused:
		if not Engine.is_editor_hint():
			_check_move()
		queue_redraw()
		
# Checks if the player wants to move the character and starts
# the movement if so.
func _check_move():
	var input_direction = _get_input_direction()
	if input_direction != Vector2.ZERO:
		move(input_direction) # Move in this direction

func _get_input_direction():
	var horizontal_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	var vertical_input = Input.get_action_strength("down") - Input.get_action_strength("up")

	if abs(horizontal_input) > abs(vertical_input):
		return Vector2(horizontal_input, 0)
	elif  abs(vertical_input) > abs(horizontal_input):
		return Vector2(0, vertical_input)
	else:
		return Vector2.ZERO

# Interacts with an Interactable event if there is one
func _interact():
	var collider = _get_collider(_faced_direction) # Returns what's in front of the player
	if collider != null and collider is InteractableClass: # If it can be interacted with
		collider = collider as InteractableClass
		collider.interact(self)

# Function connected to the end of the Tween
func _end_move():
	emit_signal("square_tick")
	_moving = Vector2.ZERO
	_check_move()
	if _moving == Vector2.ZERO: # If not, then the movement is over, stop the animation
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 0
	# If _moving is true, the animation continues

func is_moving():
	return _moving != Vector2.ZERO

