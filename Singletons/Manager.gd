extends Node

const CURRENT_SCENE_NODE = "/root/Game/CurrentScene"

const PATH_MAIN_MENU_SCENE = "res://Scenes/MainMenu/MainMenu.tscn"

func _ready():
	print("[MANAGER] Manager ready")
	_load_main_menu()
	
func _load_main_menu():
	print("[MANAGER] Loading main menu")
	var main_menu_instance = load(PATH_MAIN_MENU_SCENE).instance()
	get_node(CURRENT_SCENE_NODE).add_child(main_menu_instance)
