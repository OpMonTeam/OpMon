extends Control

class_name Interface

var _map_manager: MapManager

signal closed

func set_map(map_manager: MapManager):
	_map_manager = map_manager
	connect("closed", Callable(_map_manager, "unload_interface"))
