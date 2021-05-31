extends Trigger

class_name Teleporter

# The path to the map the teleporter will lead
export var _map_path: String
# The position of the player in the new map
export var _position: Vector2

func start(player):
	.start(player)
	if _active:
		_manager.pause_player() # Prevents the player from moving before being teleported

func frame():
	.frame()

func end():
	_manager.unpause_player()
	_manager._load_map(_map_path, _position.x, _position.y) # Teleports the player
	
