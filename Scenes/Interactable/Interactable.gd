extends KinematicBody2D

const _constants = preload("res://Utils/Constants.gd")

var _root
var _manager

func _ready():
	_root = get_node("/root")
	_manager = get_node("/root/Manager")

func interact(facing_direction):
	push_error("Virtual method interact was called")
