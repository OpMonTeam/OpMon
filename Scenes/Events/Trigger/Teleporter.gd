extends Trigger

class_name Teleporter

# The name of the map the teleporter will lead
export var _map_name: String
# The position of the player in the new map
export var _position: Vector2
# The teleporter keeps the fade object
var _fade: ColorRect

func _ready():
	._ready()
	get_parent().connect("map_loaded", self, "map_loaded")

func start(player):
	.start(player)
	if _active:
		_map_manager.pause_player() # Prevents the player from moving before being teleported

func frame():
	.frame()

func end():
	.end()
	_fade = _map_manager.fade(0.5)
	# Waits for the end of the fading animation to teleport the player
	_fade.get_node("Tween").connect("tween_completed", self, "teleport")
	
	
func teleport(_object, _key):
	_map_manager.change_map(_map_name, _position) # Teleports the player
	_fade.get_node("Tween").disconnect("tween_completed", self, "teleport")
	_map_manager.unfade(0.5, _fade)
	
func map_loaded():
	pass
