# Manages the current scene, the camera and the switching from a scene to another one.
# It also manages the player in the overworld.
extends Node

signal map_loaded

const _constants = preload("res://Utils/Constants.gd")

var _first_map = ""
var _first_map_pos = Vector2(0,0)

var maps = {}

# The instance of Player used in the overworld. Contains the camera when in map mode, and is given
# to the current map.
var player_instance: Node

var camera_instance: Node

var interface = null

func init(p_first_map: String, p_first_map_pos: Vector2):
	_first_map = p_first_map
	_first_map_pos = p_first_map_pos

func _ready():
	player_instance = load(_constants.PATH_PLAYER_SCENE).instance()
	camera_instance = load(_constants.PATH_CAMERA_SCENE).instance()
	camera_instance.set_map_mode()
	player_instance.add_child(camera_instance)
	player_instance.position = _first_map_pos * (_constants.TILE_SIZE / 2)
	load_map(_first_map, _first_map_pos)
	maps[_first_map].add_child(player_instance)

func load_interface(p_interface: Node):
	if interface == null and p_interface.has_method("set_map"):
		interface = p_interface
		p_interface.set_map(self)
		$Interface.add_child(interface)

func unload_interface():
	if interface != null:
		interface.call_deferred("free")
		interface = null
		call_deferred("unpause_player")

func load_map(map_name: String, map_pos = Vector2(0,0)):
	print("[MAPNAGER] Loading map " + map_name)
	maps[map_name] = load(_constants.PATH_MAP_SCENE + map_name + "/" + map_name + ".tscn").instance()
	add_child(maps[map_name])
	emit_signal("map_loaded")

# TODO when it will be necessary
#func fade(duration: float):
#	var fade: ColorRect = load(_constants.PATH_FADE_SCENE).instance()
#	var tween: Tween = fade.get_node("Tween")
#	fade.set_size(get_viewport().size)
#	get_node(_constants.PATH_USER_INTERFACE_NODE).add_child(fade)
#	tween.interpolate_property(fade, "alpha", 0.0, 1.0, duration)
#	tween.start()
#	return fade
#	
#func unfade(duration: float, fade: ColorRect):
#	var tween: Tween = fade.get_node("Tween")
#	tween.interpolate_property(fade, "alpha", 1.0, 0.0, duration)
#	tween.start()
#	tween.connect("tween_completed", self, "remove_fade")
#	
#func remove_fade(object, _key):
#	object.queue_free()

func pause_player():
	player_instance.set_paused(true)

func unpause_player():
	player_instance.set_paused(false)
