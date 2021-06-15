extends Trigger

class_name Teleporter

# The path to the map the teleporter will lead
export var _map_path: String
# The position of the player in the new map
export var _position: Vector2
# The teleporter keeps the fade object
var _fade: ColorRect

func _ready():
	._ready()
	_manager.connect("map_loaded", self, "map_loaded")

func start(player):
	.start(player)
	if _active:
		_manager.pause_player() # Prevents the player from moving before being teleported

func frame():
	.frame()

func end():
	.end()
	_fade = _manager.fade(0.5)
	# Waits for the end of the fading animation to teleport the player
	_fade.get_node("Tween").connect("tween_completed", self, "teleport")
	
	
func teleport(_object, _key):
	_manager._load_map(_map_path, _position.x, _position.y) # Teleports the player
	_fade.get_node("Tween").disconnect("tween_completed", self, "teleport")
	_fade.get_node("Tween").connect("tween_completed", self, "restart_player")
	_manager.unfade(0.5, _fade)
	
func restart_player(_object, _key):
	_manager.unpause_player()
	
func map_loaded():
	pass
