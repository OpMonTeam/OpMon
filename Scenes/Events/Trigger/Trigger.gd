# An event used to trigger actions in the game when the player walks on it.
extends Area2D

class_name Trigger

var _root
var _manager

const _constants = preload("res://Utils/Constants.gd")

func _ready():
	_root = get_node("/root")
	_manager = get_node("/root/Manager")


# This method is called when the player begins to walk towards the trigger
func start():
	push_error("Virtual method interact was called")

# This method is called each frame while the player walks towards the trigger
func frame():
	push_error("Virtual method interact was called")
	
# This method is called when the player stands still on the trigger
func end():
	push_error("Virtual method interact was called")
