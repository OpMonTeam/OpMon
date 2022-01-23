# Represents anything the player can interact with.
extends KinematicBody2D

class_name Iteractable

var _root

var _map

const _constants = preload("res://Utils/Constants.gd")

func _ready():
	_root = get_node("/root")
	_map = get_parent().get_parent()

func interact(_player):
	push_error("Virtual method interact was called")
