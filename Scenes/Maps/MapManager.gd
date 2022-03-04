# Manages the current map, the camera and the switching from a scene to another one.
# It also manages the player in the overworld.
extends Node

const _constants = preload("res://Utils/Constants.gd")

var _first_map := ""
var _first_player_pos := Vector2(0,0)

var current_map := ""

var maps := {}

var next_map := ""

# The instance of Player used in the overworld. Contains the camera.
var player_instance: Node

var camera_instance: Camera2D

var interface = null

# Sets a cooldown after closing the interface
# During the cooldown, the player is still paused and the menu can’t open
# Unpauses the player at the end of the cooldown
# -1 if the cooldown is over
var interface_closed_delay := -1

func init(p_first_map: String, p_first_player_pos: Vector2):
	_first_map = p_first_map
	_first_player_pos = p_first_player_pos

func _ready():
	player_instance = load(_constants.PATH_PLAYER_SCENE).instance()
	camera_instance = load(_constants.PATH_CAMERA_SCENE).instance()
	camera_instance.set_map_mode()
	player_instance.add_child(camera_instance)
	change_map(_first_map, _first_player_pos)
	
func _input(event):
	if event.is_action_pressed("menu") and interface_closed_delay < 0:
		var menu = load("res://Scenes/GameMenu/GameMenu.tscn").instance()
		pause_player()
		load_interface(menu)
	
func _process(_delta):
	if interface_closed_delay > 0:
		interface_closed_delay -= 1
	if interface_closed_delay == 0:
		interface_closed_delay -= 1
		unpause_player()

func load_interface(p_interface: Node):
	if interface == null and p_interface.has_method("set_map"):
		interface = p_interface
		p_interface.set_map(self)
		$Interface.add_child(interface)
	elif not p_interface.has_method("set_map"):
		print("Error: the given interface doesn’t have the set_map method.")

func unload_interface():
	if interface != null:
		interface.call_deferred("free")
		interface = null
		interface_closed_delay = 5

# Loads a map at the given position in the global MapManager and erases all the current present maps
# Does not associate the map with the player yet, only shows the map on screen
# map_pos and player_pos has to be in map coordinates (one tile = 16 px) and relatively to the loaded map
func change_map(map_name: String, player_pos = Vector2(0,0), map_pos = Vector2(0,0)):
	print("[MAPNAGER] Loading map " + map_name)
	if maps.has(current_map):
		maps[current_map].call_deferred("remove_child", player_instance)
	# Removes the old maps
	for key in maps.keys():
		maps[key].call_deferred("queue_free")
		maps.erase(key)
	# Loads the new map
	current_map = map_name
	maps[map_name] = load(_constants.PATH_MAP_SCENE + map_name + "/" + map_name + ".tscn").instance()
	maps[current_map].connect("map_entered", self, "map_entered")
	# Sets the positions
	maps[current_map].position = map_pos * _constants.TILE_SIZE
	player_instance.position = player_pos * _constants.TILE_SIZE
	# Adds the map to the tree and loads adjacent maps
	call_deferred("add_child", maps[current_map])
	maps[current_map].call_deferred("add_child", player_instance)
	maps[current_map].show_adjacent_maps(self, maps)
	maps[current_map].emit_signal("map_loaded")


# Called when the player enters a map already shown on the screen but hasn’t finished walking through a square.
# It connects square_tick to switch_map so the map can be switched as soon as the character finished walking.
func map_entered(map):
	if next_map == "":
		next_map = get_map_key(map)
		player_instance.connect("square_tick",self,"switch_map")

# Called when the player enters a map already shown on the screen and has finished walking on a square.
# Switches the main map to the new one
func switch_map():
	if next_map != current_map and next_map != "":
		print("[MAPNAGER] Switching map")
		# Moving the player
		var old_player_instance = player_instance
		player_instance = player_instance.duplicate()
		maps[next_map].call_deferred("add_child", player_instance)
		maps[current_map].call_deferred("remove_child", old_player_instance)
		player_instance.position += maps[current_map].position
		player_instance.position -= maps[next_map].position
		
		# Changing maps status
		maps[current_map].adjacent_mode(self, maps[next_map])
		maps[next_map].main_mode(self, maps, maps[current_map])
		current_map = next_map
	next_map = ""
	player_instance.disconnect("square_tick",self,"switch_map")


func get_map_key(map) -> String:
	for key in maps.keys():
		if maps[key] == map:
			return key
	return ""
	
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
