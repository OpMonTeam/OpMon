# Describes the physics of a basic character
tool
extends "res://Scenes/Events/Interactable/Interactable.gd"

export var textures: SpriteFrames setget set_textures

# Signal launched when the character finishes walking on a square (and will be going onto the next one
# one if its programmation tells so)
# At this moment, the player’s position is exactly aligned with the tiles.
signal square_tick

# Variable used in the editor to have string labels of vector directions
export(String, "Left", "Right", "Up", "Down") var faced_direction: String setget set_faced_direction

# Vector indicating direction in the code
var _faced_direction: Vector2

# Indicate if the player can act (the player cannot act during a dialogue or
# cutscene, etc.)
var _paused = false

# Indicate if the player is in the process of moving from one tile to another
var _moving: Vector2

# Is filled with the Player if they asked for an interaction with the character.
var _interaction_requested = null
# The distance between the player and the character when the interaction has been requested.
var _interaction_distance: float

func set_textures(new_textures: SpriteFrames):
	$AnimatedSprite.frames = new_textures
	textures = new_textures

func set_faced_direction(new_faced_direction: String):
	faced_direction = new_faced_direction
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

func _ready():
	# Sets the texture and the faced direction
	set_textures(textures)
	set_faced_direction(faced_direction)

func interact(_player):
	# If the player requested an interaction but the character is moving,
	# indicate an interaction has been requested and calculates the distance
	# between the player and the character.
	# If when the interaction is taken into account the distance has increased,
	# the character was moving outwards the player and can't be interacted with
	# anymore: the interaction request will be discarded.
	if _moving != Vector2.ZERO:
		_interaction_requested = _player
		_interaction_distance = (_player.get_position() - self.position).length()
	pass

func _process(_delta):
	if not _paused:
		update()
	

func _get_collider(direction: Vector2):
	var local_target_position = direction * _constants.TILE_SIZE
	var raycast = $RayCast2D
	$RayCast2D.cast_to = local_target_position # Sets the position to check
	$RayCast2D.force_raycast_update ( )
	if $RayCast2D.is_colliding(): # Checks the collision
		return $RayCast2D.get_collider()
	else:
		return null

func _collides(direction: Vector2):
	return _get_collider(direction) != null

# Retuns true if the character is actually moving, false if only the animation plays
func move(direction: Vector2):
	# Don't move if the character is already moving or paused.
	if _moving != Vector2.ZERO or _paused:
		return false
	var ret: bool = false
	_moving = direction
	_faced_direction = direction
	# Chooses the animation to play
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
	# If there is no collisions, do a real movement.
	if not _collides(direction):
		next += (direction * _constants.TILE_SIZE) # Adds the movement to the current position.
		ret = true
		# Reserves the next tile so no other character can go on the same one.
		$TileReservation.set_position(direction  * _constants.TILE_SIZE + Vector2(8,8))
		# Makes the collision used for the reservation move against the player's movements
		# so it stays in the same tile on the map.
		$TileReservation.get_node("Tween").interpolate_property(
			$TileReservation, "position", $TileReservation.position, 
			$CharacterCollision.position, _constants.WALK_SPEED, 
			Tween.TRANS_LINEAR, Tween.EASE_IN)
		$TileReservation.get_node("Tween").start()
		$TileReservation.disabled = false
	# Starts the movement if position and next are different.
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

# Checks if the pending interaction is valid (if the player is in front of the character).
# See interact for more information on how it is done.
# This method is made to be called between two movements.
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
	emit_signal("square_tick")
	_check_pending_interaction()
	# This method might set _moving to true if the player continues moving
	if _moving == Vector2.ZERO or _paused: # If not, then the movement is over, stop the animation
		$AnimatedSprite.stop()
		$AnimatedSprite.frame = 0
		$TileReservation.disabled = true
	else:
		_moving = Vector2.ZERO
		move(_faced_direction) # Else, continue moving.
	# If _moving is true, the animation continues


func get_direction():
	return _faced_direction

func save() -> Dictionary:
	# Rounds the position to the nearest square if the Character is moving
	var rounded_pos := Vector2(round(position.x / _constants.TILE_SIZE) * _constants.TILE_SIZE, round(position.y / _constants.TILE_SIZE) * _constants.TILE_SIZE)
	return {
		"textures" : textures.resource_path,
		"faced_direction" : faced_direction,
		"_faced_direction" : [_faced_direction.x, _faced_direction.y],
		"_paused" : _paused,
		"position" : [rounded_pos.x, rounded_pos.y]
	}
	
func load_save(data: Dictionary) -> void:
	textures = load(data["textures"])
	faced_direction = data["faced_direction"]
	_faced_direction = Vector2(data["_faced_direction"][0], data["_faced_direction"][1])
	_paused = data["_paused"]
	position = Vector2(data["position"][0], data["position"][1])
