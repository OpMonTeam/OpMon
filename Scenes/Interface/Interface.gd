extends Control

class_name Interface

var _map_manager

signal closed(interface_id)

func set_map(map_manager: Node):
	_map_manager = map_manager
	connect("closed", _map_manager, "unload_interface")
