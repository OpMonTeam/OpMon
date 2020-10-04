extends Node2D

const TILE_SIZE = 16
const WALK_SPEED = 0.5

var moving = false


func _process(_delta):
	var input_direction = get_input_direction()
	if input_direction and not moving:
		var target_position = position + input_direction * TILE_SIZE

		# TODO: extract this in a method to check collision	*
		var local_position = to_local(position)
		var local_target_position = to_local(target_position)
		$RayCast2D.position = local_position
		$RayCast2D.cast_to = local_target_position
		$RayCast2D.force_raycast_update ( )
		if not $RayCast2D.is_colliding():
			move_to(target_position, input_direction)
		else:
			move_to(position, input_direction)
	update()

func get_input_direction():
	var horizontal_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var vertical_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if abs(horizontal_input) > abs(vertical_input):
		return Vector2(horizontal_input, 0)
	elif  abs(vertical_input) > abs(horizontal_input):
		return Vector2(0, vertical_input)
	else:
		return Vector2(0, 0)

func move_to(target_position, input_direction):
	# Set the player to "moving" so it won't accept any other input while moving
	moving = true

	# Select an animation based on the movement direction
	if input_direction == Vector2.UP:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_up"
	elif input_direction == Vector2.DOWN:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_down"
	elif input_direction == Vector2.RIGHT:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_right"
	elif input_direction == Vector2.LEFT:
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.animation = "walk_right"

	# Interpolate between current and target position
	$Tween.interpolate_property(self, "position", position, target_position, WALK_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

	# Start the animation and wait until it is finished
	# TODO: the animation is constitued of 3 frames, so the speed of the
	# animation (in FPS) must be 3 times the value of 1/WALK_SPEED in order for
	# each frame to be displayed once during the movement from one tile to the
	# next.
	$AnimatedSprite.play()
	yield($AnimatedSprite, "animation_finished")

	# Stop the animation, reset to frame 0 (where the player appears idle), and
	# unset "moving" so the player can now accept new inputs
	$AnimatedSprite.stop()
	$AnimatedSprite.frame = 0
	moving = false
