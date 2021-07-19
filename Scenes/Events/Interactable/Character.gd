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

var _interaction_requested = null
var _interaction_distance: float

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
	if _moving != Vector2.ZERO:
		_interaction_requested = _player
		_interaction_distance = (_player.get_position() - self.position).length()
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
		$TileReservation.disabled = false
		$TileReservation.set_position(direction * _constants.TILE_SIZE)
		$TileReservation.get_node("Tween").interpolate_property(
			$TileReservation, "position", $TileReservation.position, 
			Vector2.ZERO, _constants.WALK_SPEED, 
			Tween.TRANS_LINEAR, Tween.EASE_IN)
		$TileReservation.get_node("Tween").start()
	$Tween.interpolate_property(self, "position", position, next, 
		_constants.WALK_SPEED, Tween.TRANS_LINEAR, Tween.EASE_IN)
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

func _check_pending_interaction():
	var _old_moving = _moving
	_moving = Vector2.ZERO
	if _interaction_requested != null:
		if _interaction_distance >= (_interaction_requested.get_position() - self.position).length():
			interact(_interaction_requested)
		_interaction_requested = null
	_moving = _old_moving

# The movement is stopped if it has explicitely been stopped by calling stop_move
# Function connected to the end of the Tween
func _end_move(_object, _key):
	_check_pending_interaction()
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
