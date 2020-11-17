extends Node

const PATH_CURRENT_SCENE_NODE = "/root/Game/CurrentScene"

const PATH_MAIN_MENU_SCENE = "res://Scenes/MainMenu/MainMenu.tscn"

const PATH_MAP_SCENE = "res://Scenes/Maps/"

const PATH_PLAYER_SCENE =  "res://Scenes/Player/Player.tscn"

var current_scene_node : Node

func _ready():
	print("[MANAGER] Manager ready")
	current_scene_node = get_node(PATH_CURRENT_SCENE_NODE)
	_load_main_menu()

func _remove_current_scene():
	print("[MANAGER] Removing current scene")
	var current_scene_child_node = current_scene_node.get_child(0)
	if (current_scene_child_node != null):
		current_scene_child_node.queue_free()

func _load_main_menu():
	_remove_current_scene()
	print("[MANAGER] Loading main menu")
	var main_menu_instance = load(PATH_MAIN_MENU_SCENE).instance()
	current_scene_node.add_child(main_menu_instance)

func _load_map(map_name : String, player_x, player_y):
	_remove_current_scene()
	print("[MANAGER] Loading map " + map_name)
	var map_instance = load(PATH_MAP_SCENE + map_name + ".tscn").instance()
	var player_instance = load(PATH_PLAYER_SCENE).instance()
	player_instance.position.x = player_x * 8
	player_instance.position.y = player_y * 8
	map_instance.add_child(player_instance)
	current_scene_node.add_child(map_instance)
