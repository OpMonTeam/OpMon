extends Node2D

const TriggerClass = preload("res://Scenes/Events/Trigger/Trigger.gd")

const TeleporterClass = preload("res://Scenes/Events/Trigger/Teleporter.gd")

const InteractableClass = preload("res://Scenes/Events/Interactable/Interactable.gd")

const _constants = preload("res://Utils/Constants.gd")

# The direction currently faced by the player
var _faced_direction = Vector2.UP

# Indicate if the player can act (the player cannot act during a dialogue or
# cutscene, etc.)
var _paused = false

# Indicate if the player is in the process of moving from one tile to another
var _moving = false

# The current trigger the player is walking on
var _walking_on: TriggerClass = null

func _process(_delta):
	if _walking_on != null:
		_walking_on.frame()
	if not _paused:
		if Input.is_action_just_pressed("ui_accept"):
			_interact()
		_check_move()
		update()
		
# Checks if the player wants to move the character and starts
# the movement if so.
func _check_move():
	var input_direction = _get_input_direction()
	if input_direction and not _moving:
		var target_position = position + input_direction * _constants.TILE_SIZE
		# Check collisions
		var collider = _get_collider_in_direction(input_direction)
		var collides = false
		if collider != null: # If the collider isn't null, check if it's ok or not
			if collider is InteractableClass:
				# Some interactable objects collide, some don't
				collides = (collider as InteractableClass).collides()
			elif collider is TriggerClass: # A trigger doesn't collide
				collides = false
			else: # If it isn't an event, it always collides
				collides = true
		# If it's null, it does't collides
		if not collides:
			_move_to(target_position, input_direction) # If no collision problem, move to the next tile
		else:
			_move_to(position, input_direction) # Else, only animate, do not move

func _get_collider_in_direction(direction : Vector2):
	var target_position = position + direction * _constants.TILE_SIZE

	var local_position = to_local(position)
	var local_target_position = to_local(target_position)
	$RayCast2D.position = local_position
	$RayCast2D.cast_to = local_target_position
	$RayCast2D.force_raycast_update ( )
	if $RayCast2D.is_colliding(): # Checks the collision
		return $RayCast2D.get_collider()
	else:
		return null

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
	var collider = _get_collider_in_direction(_faced_direction) # Returns what's in front of the player
	if collider != null and collider is InteractableClass: # If it can be interacted with
		collider = collider as InteractableClass
		collider.interact(_faced_direction)

# Triggers a trigger if there is one
func _check_triggers(input_direction):
	var collider = _get_collider_in_direction(input_direction)
	if collider != null and collider is TriggerClass:
		collider = collider as TriggerClass
		_walking_on = collider
		_walking_on.begin()
	

func _move_to(target_position, input_direction):
	# Set the player to "moving" so it won't accept any other input while moving
	_moving = true
	if target_position != position:
		_check_triggers(input_direction)

	# Select an animation based on the movement direction
	_faced_direction = input_direction
	if input_direction == Vector2.UP:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_up"
	elif input_direction == Vector2.DOWN:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_down"
	elif input_direction == Vector2.RIGHT:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_side"
	elif input_direction == Vector2.LEFT:
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.animation = "walk_side"

	# Interpolate between current and target position
	$Tween.interpolate_property(self, "position", position, target_position, _constants.WALK_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

	# Starts the animation that will loop until the movement is over.
	$AnimatedSprite.play()

func set_paused(value):
	_paused = value


func _end_move(object, key):
	_moving = false;
	# Ends the trigger if there is one
	if _walking_on != null:
		_walking_on.end()
		_walking_on = null
	_check_move() # This method might set _moving to true if the player continues moving
	if not _moving: # If not, then the movement is over, stop the animation
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
	# If _moving is true, the animation continues
