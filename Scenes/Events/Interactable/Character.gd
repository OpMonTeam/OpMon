# Describes the physics of a basic character
extends "res://Scenes/Events/Interactable/Interactable.gd"

class_name Character

export(String, "Left", "Right", "Up", "Down") var faced_direction: String

var _faced_direction

# Indicate if the player can act (the player cannot act during a dialogue or
# cutscene, etc.)
var _paused = false

# Indicate if the player is in the process of moving from one tile to another
var _moving: Vector2

export var textures: SpriteFrames

func _enter_tree():
	$AnimatedSprite.frames = textures
	if faced_direction == "Up":
		_faced_direction = Vector2.UP
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_up"
	elif faced_direction == "Down":
		_faced_direction = Vector2.DOWN
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_down"
	elif faced_direction == "Right":
		_faced_direction = Vector2.RIGHT
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_side"
	elif faced_direction == "Left":
		_faced_direction = Vector2.LEFT
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.animation = "walk_side"

func interact(_player):
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
	if _moving != Vector2.ZERO or _paused:
		return false
	var ret: bool = false
	_moving = direction
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
		ret = true
	$Tween.interpolate_property(self, "position", position, next, _constants.WALK_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

	# Starts the animation that will loop until the movement is over.
	$AnimatedSprite.play()
	return ret

func face(direction: Vector2):
	_faced_direction = direction
	
func set_paused(value):
	_paused = value

func stop_move():
	_moving = Vector2.ZERO

# The movement is stopped if it has explicitely been stopped by calling stop_move
# Function connected to the end of the Tween
func _end_move(_object, _key):
	# This method might set _moving to true if the player continues moving
	if _moving == Vector2.ZERO or _paused: # If not, then the movement is over, stop the animation
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
	else:
		_moving = Vector2.ZERO
		move(_faced_direction) # Else, continue moving.
	# If _moving is true, the animation continues


func get_direction():
	return _faced_direction
