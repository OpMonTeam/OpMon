# Represents anything the player can interact with.
extends KinematicBody2D

# If the player can go through the event or not
export var _collides: bool = true
var _root
var _manager

const _constants = preload("res://Utils/Constants.gd")

func _ready():
	_root = get_node("/root")
	_manager = get_node("/root/Manager")

func collides():
	return _collides

func interact(player_faced_direction):
	push_error("Virtual method interact was called")
