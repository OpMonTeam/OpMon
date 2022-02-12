extends "res://Scenes/Events/Interactable/Character.gd"

const PlayerClass = preload("Player.gd")

export var dialog_lines := ["Fake line 1.", "Fake line 2."]

# Called when the player interacts with the NPC
func interact(player: PlayerClass):
	.interact(player)
	if _moving != Vector2.ZERO:
		return
	_paused = true
	change_faced_direction(player.get_direction()) # Changes the faced direction of the NPC to face the player
	var dialog_box_instance = load(_constants.PATH_DIALOG_BOX_SCENE).instance() # Loads the dialog
	dialog_box_instance.set_dialog_lines(dialog_lines) # Adds the dialog lines to the dialog
	dialog_box_instance.close_when_over = true
	_map.load_interface(dialog_box_instance)
	dialog_box_instance.go() # Starts the dialog
	dialog_box_instance.connect("dialog_over", self, "_unpause") # When the dialog is over, unpauses the character

func change_faced_direction(player_faced_direction):
	# Change the direction the NPC is facing based on the direction the player
	# is facing: if the player is facing up then face down, etc.
	if player_faced_direction == Vector2.UP:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_down"
	elif player_faced_direction == Vector2.DOWN:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_up"
	elif player_faced_direction == Vector2.RIGHT:
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.animation = "walk_side"
	elif player_faced_direction == Vector2.LEFT:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "walk_side"

func _unpause():
	_paused = false
