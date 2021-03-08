extends Node

const _constants = preload("res://Utils/Constants.gd")

var current_scene_name = ""

var current_scene_node : Node

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
	var current_scene_child_node = null
	if current_scene_name != "":
		current_scene_child_node = current_scene_node.get_node(current_scene_name)
	if current_scene_child_node != null:
		current_scene_child_node.queue_free()

func _load_main_menu():
	_remove_current_scene()
	current_scene_name = "MainMenu"
	print("[MANAGER] Loading main menu")
	var main_menu_instance = load(_constants.PATH_MAIN_MENU_SCENE).instance()
	var camera_instance = load(_constants.PATH_CAMERA_SCENE).instance()
	camera_instance.set_static_mode()
	current_scene_node.add_child(main_menu_instance)
	current_scene_node.add_child(camera_instance)

func _load_map(map_name : String, player_x, player_y):
	_remove_current_scene()
	current_scene_name = map_name
	print("[MANAGER] Loading map " + map_name)
	var map_instance = load(_constants.PATH_MAP_SCENE + map_name + ".tscn").instance()
	var camera_instance = load(_constants.PATH_CAMERA_SCENE).instance()
	camera_instance.set_map_mode()
	player_instance = load(_constants.PATH_PLAYER_SCENE).instance()
	player_instance.position.x = player_x * 8
	player_instance.position.y = player_y * 8
	player_instance.add_child(camera_instance)
	map_instance.add_child(player_instance)
	current_scene_node.add_child(map_instance)

func pause_player():
	player_instance.set_paused(true)

func unpause_player():
	player_instance.set_paused(false)
