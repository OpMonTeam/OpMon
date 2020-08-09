extends AnimatedSprite

const TILE_SIZE = 16
const WALK_SPEED = 1

var moving = false

func _process(_delta):
	var input_direction = get_input_direction()
	if input_direction and not moving:
		var target_position = position + input_direction * TILE_SIZE
		move_to(target_position, input_direction)
	else:
		return

func get_input_direction():
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

func move_to(target_position, input_direction):
	# Set the player to "moving" so it won't accept any other input while moving
	moving = true

	# Select an animation based on the movement direction
	if input_direction == Vector2.UP:
		flip_h = false
		animation = "walk_up"
	elif input_direction == Vector2.DOWN:
		flip_h = false
		animation = "walk_down"
	elif input_direction == Vector2.RIGHT:
		flip_h = false
		animation = "walk_right"
	elif input_direction == Vector2.LEFT:
		flip_h = true
		animation = "walk_right"

	# Interpolate between current and target position
	$Tween.interpolate_property(self, "position", position, target_position, WALK_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

	# Start the animation and wait until it is finished
	# TODO: the current WALK_SPEED (1 second) and the current animation speed 
	# (3 FPS) were set manually so everything is in sync, we need to find a
	# better wya to do this
	play()
	yield(self, "animation_finished")

	# Stop the animation, reset to frame 0 (where the player appears idle), and
	# unset "moving" so the player can now accept new inputs
	stop()
	frame = 0
	moving = false
