extends Node

const PATH_CURRENT_SCENE_NODE = "/root/Game/CurrentScene"

const PATH_MAIN_MENU_SCENE = "res://Scenes/MainMenu/MainMenu.tscn"

const PATH_MAP_SCENE = "res://Scenes/Maps/"

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

func _load_map(map_name : String):
	_remove_current_scene()
	print("[MANAGER] Loading map " + map_name)
	var map_instance = load(PATH_MAP_SCENE + map_name + ".tscn").instance()
	current_scene_node.add_child(map_instance)
