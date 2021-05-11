# Manages the current scene, the camera and the switching from a scene to another one.
# It also manages the player in the overworld.
extends Node

const _constants = preload("res://Utils/Constants.gd")

var current_scene_name = ""

# A node that will contain the active scene and the camera if it is in static mode (see Camera.gd)
var current_scene_node : Node

# The instance of Player used in the overworld. Contains the camera when in map mode, and is given
# to the current map.
var player_instance : Node

func _ready():
	print("[MANAGER] Manager ready")
	current_scene_node = get_node(_constants.PATH_CURRENT_SCENE_NODE)
	_load_main_menu()

func _remove_current_scene():
	if current_scene_name.empty():
		print("[MANAGER] No current scene to remove")
	else:
		print("[MANAGER] Removing current scene " + current_scene_name)
	# Contains the current scene to remove
	var current_scene_child_node = null
	if current_scene_name != "": # If there is a current scene
		current_scene_child_node = current_scene_node.get_node(current_scene_name) # Puts it in current_scene_child_node
	if current_scene_child_node != null: # If a current scene has been found
		current_scene_child_node.queue_free() # Deletes the scene

# Note TODO: I don't know if it will work well for interfaces above the overworld like in-game menus.
# It might reset the map or something like that.
func _load_interface(interface_name : String, interface_path : String):
	_remove_current_scene() # Removes any previous scenes
	current_scene_name = interface_name
	# Loads the scene and the camera
	var interface_instance = load(interface_path + interface_name + ".tscn").instance()
	var camera_instance = load(_constants.PATH_CAMERA_SCENE).instance()
	camera_instance.set_static_mode()
	# Sets the current scene to the new interface
	current_scene_node.add_child(interface_instance)
	current_scene_node.add_child(camera_instance)

func _load_main_menu():
	_load_interface("MainMenu", "res://Scenes/MainMenu/")

func _load_map(map_name : String, player_x, player_y):
	_remove_current_scene() # Removes any previous scene
	current_scene_name = map_name
	print("[MANAGER] Loading map " + map_name)
	# Loads the map and the camera
	var map_instance = load(_constants.PATH_MAP_SCENE + map_name + ".tscn").instance()
	var camera_instance = load(_constants.PATH_CAMERA_SCENE).instance()
	camera_instance.set_map_mode()
	# Loads the player
	player_instance = load(_constants.PATH_PLAYER_SCENE).instance()
	# Sets the position of the player on the map
	player_instance.position.x = player_x * (_constants.TILE_SIZE / 2)
	player_instance.position.y = player_y * (_constants.TILE_SIZE / 2)
	player_instance.add_child(camera_instance) # Binds the camera to the player
	map_instance.add_child(player_instance) # Adds the player to the map
	current_scene_node.add_child(map_instance) # Sets the map as the active scene

func pause_player():
	player_instance.set_paused(true)

func unpause_player():
	player_instance.set_paused(false)
