# An event used to trigger actions in the game when the player walks on it.
extends Area2D

class_name Trigger

const PlayerObject = preload("res://Scenes/Events/Interactable/Player.gd")

var _map_manager

const _constants = preload("res://Utils/Constants.gd")

func _ready():
	_map_manager = get_parent().get_parent()

# True if the player just started walking on the trigger and not finished yet
var _active = false
var _player: PlayerObject

func _process(_delta):
	if _active:
		frame()

# This method is called when the player begins to walk towards the trigger
func start(body):
	if body is PlayerObject:
		_player = body as PlayerObject
		_active = _player.is_moving()

# This method is called each frame while the player walks towards the trigger
func frame():
	if not _player.is_moving():
		end()

	
# This method is called when the player stands still on the trigger
func end():
	_active = false
