extends Control

class_name Interface

var _map

signal closed

func set_map(map: Node):
	_map = map
	connect("closed", _map, "unload_interface")
