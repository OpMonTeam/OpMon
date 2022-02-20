# Manages the current map, the camera and the switching from a scene to another one.
# It also manages the player in the overworld.
extends Node

const _constants = preload("res://Utils/Constants.gd")

var _first_map := ""
var _first_player_pos := Vector2(0,0)

var maps := {}

# The instance of Player used in the overworld. Contains the camera when in map mode, and is given
# to the current map.
var player_instance: Node
var player_current_map: String

var camera_instance: Node

var interface = null

# Sets the number of frames to wait before unpausing the player
# -1 if the player has not to be unpaused
var unpause_player_delay := -1

func init(p_first_map: String, p_first_player_pos: Vector2):
	_first_map = p_first_map
	_first_player_pos = p_first_player_pos

func _ready():
	player_instance = load(_constants.PATH_PLAYER_SCENE).instance()
	camera_instance = load(_constants.PATH_CAMERA_SCENE).instance()
	camera_instance.set_map_mode()
	player_instance.add_child(camera_instance)
	change_map(_first_map, _first_player_pos)
	
	
func _process(_delta):
	if unpause_player_delay > 0:
		unpause_player_delay -= 1
	elif unpause_player_delay == 0:
		unpause_player_delay -= 1
		unpause_player()

func load_interface(p_interface: Node):
	if interface == null and p_interface.has_method("set_map"):
		interface = p_interface
		p_interface.set_map(self)
		$Interface.add_child(interface)

func unload_interface():
	if interface != null:
		interface.call_deferred("free")
		interface = null
		unpause_player_delay = 5

# Loads a map at the given position in the global MapManager
# Does not associate the map with the player yet, only shows the map on screen
# map_pos has to be in map coordinates (one tile = 16 px)
func load_map(map_name: String, map_pos = Vector2(0,0)):
	print("[MAPNAGER] Loading map " + map_name)
	maps[map_name] = load(_constants.PATH_MAP_SCENE + map_name + "/" + map_name + ".tscn").instance()
	maps[map_name].position = map_pos * _constants.TILE_SIZE
	add_child(maps[map_name])
	maps[map_name].emit_signal("map_loaded")

# Completely changes all loaded maps and teleports the player
# Loads the map given at (0,0).
# player_pos has to be in map coordinates (one tile = 16 px)
func change_map(map_name: String, player_pos: Vector2):
	for map in maps.keys():
		unload_map(map)
	load_map(map_name)
	maps[map_name].add_child(player_instance)
	player_current_map = map_name
	player_instance.position = player_pos * (_constants.TILE_SIZE / 2)
	
# Unloads the given map, returns true if succeded
# Returns false if fails because the map given isn’t loaded.
func unload_map(map_name: String) -> bool:
	if maps.has(map_name):
		if player_current_map == map_name:
			maps[map_name].remove_child(player_instance)
			player_current_map = ""
		maps[map_name].queue_free()
		maps.erase(map_name)
		return true
	else: return false
	
func fade(duration: float):
	var fade: ColorRect = load(_constants.PATH_FADE_SCENE).instance()
	var tween: Tween = fade.get_node("Tween")
	fade.set_size(get_viewport().size)
	$Interface.add_child(fade)
	tween.interpolate_property(fade, "alpha", 0.0, 1.0, duration)
	tween.start()
	return fade
	
func unfade(duration: float, fade: ColorRect):
	var tween: Tween = fade.get_node("Tween")
	tween.interpolate_property(fade, "alpha", 1.0, 0.0, duration)
	tween.start()
	tween.connect("tween_completed", self, "remove_fade")
	
func remove_fade(object, _key):
	object.call_deferred("queue_free")
	unpause_player()

func pause_player():
	player_instance.set_paused(true)

func unpause_player():
	player_instance.set_paused(false)
