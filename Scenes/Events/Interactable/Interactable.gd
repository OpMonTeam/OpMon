# Represents anything the player can interact with.
extends KinematicBody2D

class_name Iteractable

var _root
var _manager

const _constants = preload("res://Utils/Constants.gd")

func _ready():
	_root = get_node("/root")
	_manager = get_node("/root/Manager")

func interact(_player):
	push_error("Virtual method interact was called")
