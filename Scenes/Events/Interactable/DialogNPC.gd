@tool
extends "res://Scenes/Events/Interactable/Character.gd"

@export var dialog_key := ""

# Countdown to avoid the confusion between the event that closes a dialog with the event that
# interacts with the NPC to start a dialog
var _dialog_countdown := 0

# Called when the player interacts with the NPC
func interact(player):
	super.interact(player)
	if _moving != Vector2.ZERO:
		return
	if _dialog_countdown == 0:
		_paused = true
		change_faced_direction(player.get_direction()) # Changes the faced direction of the NPC to face the player
		var dialog_box_instance = _map_manager.load_dialog(dialog_key)
		dialog_box_instance.connect("dialog_over", Callable(self, "_unpause")) # When the dialog is over, unpauses the character
		dialog_box_instance.go() # Starts the dialog

func _process(delta):
	super._process(delta)
	if _dialog_countdown > 0:
		_dialog_countdown -= 1

func change_faced_direction(player_faced_direction):
	# Change the direction the NPC is facing based on the direction the player
	# is facing: if the player is facing up then face down, etc.
	if player_faced_direction == Vector2.UP:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.animation = "walk_down"
	elif player_faced_direction == Vector2.DOWN:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.animation = "walk_up"
	elif player_faced_direction == Vector2.RIGHT:
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.animation = "walk_side"
	elif player_faced_direction == Vector2.LEFT:
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.animation = "walk_side"

func _unpause():
	_paused = false
	_dialog_countdown = 5
