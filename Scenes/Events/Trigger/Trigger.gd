# An event used to trigger actions in the game when the player walks on it.
extends Area2D

class_name Trigger

var _root
var _manager

const _constants = preload("res://Utils/Constants.gd")

func _ready():
	_root = get_node("/root")
	_manager = get_node("/root/Manager")

# True if the player has began to walk on the trigger and not finished yet
var _active = false
var _player: Player

func _process(_delta):
	if _active:
		frame()

# This method is called when the player begins to walk towards the trigger
func start(body):
	if body is Player:
		_player = body as Player
		_active = true

# This method is called each frame while the player walks towards the trigger
func frame():
	if not _player.is_moving():
		end()

	
# This method is called when the player stands still on the trigger
func end():
	_active = false
