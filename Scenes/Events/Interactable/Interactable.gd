# Represents anything the player can interact with.
extends CharacterBody2D

class_name Iteractable

var _map_manager

const _constants = preload("res://Utils/Constants.gd")

func _ready():
	_map_manager = get_parent().get_parent()

func interact(_player):
	push_error("Virtual method interact was called")
