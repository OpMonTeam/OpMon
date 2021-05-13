extends "res://Scenes/Events/Trigger/Trigger.gd"
class_name Teleporter

# The path to the map the teleporter will lead
export var _map_path: String
# The position of the player in the new map
export var _position: Vector2

func _init(map_path: String, position: Vector2):
	_map_path = map_path
	_position = position

func begin():
	_manager.pause_player() # Prevents the player from moving before being teleported

func frame():
	pass

func end():
	_manager.load_map(_map_path, _position.x, _position.y) # Teleports the player
	_manager.unpause_player()
	
