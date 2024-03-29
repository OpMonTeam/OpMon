extends Trigger

class_name Teleporter

# The name of the map the teleporter will lead
@export var _map_name: String
# The position of the player in the new map
@export var _position: Vector2
# The teleporter keeps the fade object
var _fade: ColorRect

func _ready():
	super._ready()
	get_parent().connect("map_loaded", Callable(self, "map_loaded"))

func start(player):
	super.start(player)
	if _active:
		_map_manager.pause_player() # Prevents the player from moving before being teleported

func frame():
	super.frame()

func end():
	super.end()
	_fade = _map_manager.fade(0.5)
	# Waits for the end of the fading animation to teleport the player
	_fade.tween.tween_callback(Callable(self, "teleport"))
	
	
func teleport():
	_map_manager.change_map(_map_name, _position) # Teleports the player
	_map_manager.unfade(0.5, _fade)
	
func map_loaded():
	pass
