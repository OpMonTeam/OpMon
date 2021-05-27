# Describes the physics of a basic character
extends "res://Scenes/Events/Interactable/Interactable.gd"

class_name Character

var _faced_direction = Vector2.UP

# Indicate if the player can act (the player cannot act during a dialogue or
# cutscene, etc.)
var _paused = false

# Indicate if the player is in the process of moving from one tile to another
var _moving = false

export var textures: SpriteFrames

func _enter_tree():
	$AnimatedSprite.frames = textures
	$AnimatedSprite.animation = textures.get_animation_names()[0]
	

func interact(player):
	pass

func _process(_delta):
	if not _paused:
		update()

func _get_collider(direction: Vector2):
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

func _collides(direction: Vector2):
	return _get_collider(direction) != null

func move(direction: Vector2):
	_faced_direction = direction
	if direction == Vector2.UP:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_up"
	elif direction == Vector2.DOWN:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_down"
	elif direction == Vector2.RIGHT:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_side"
	elif direction == Vector2.LEFT:
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.animation = "walk_side"
	
	var next = position
	# Interpolate between current and target position
	if not _collides(direction):
		next += (direction * _constants.TILE_SIZE)
	$Tween.interpolate_property(self, "position", position, next, _constants.WALK_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

	# Starts the animation that will loop until the movement is over.
	$AnimatedSprite.play()

func face(direction: Vector2):
	_faced_direction = direction
	
func set_paused(value):
	_paused = value

func stop_move():
	_moving = false

# The movement is stopped if it has explicitely been stopped by calling stop_move
func _end_move(object, key):
	# This method might set _moving to true if the player continues moving
	if not _moving: # If not, then the movement is over, stop the animation
		_moving = false;
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
	else:
		move(_faced_direction) # Else, continue moving.
	# If _moving is true, the animation continues


func get_direction():
	return _faced_direction
