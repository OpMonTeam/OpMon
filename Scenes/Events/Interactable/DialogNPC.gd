extends "res://Scenes/Events/Interactable/Character.gd"

const PlayerClass = preload("Player.gd")

export var dialog_lines := ["Fake line 1.", "Fake line 2."]

# Called when the player interacts with the NPC
func interact(player: PlayerClass):
	change_faced_direction(player.get_direction()) # Changes the faced direction of the NPC to face the player
	var dialog_box_instance = load(_constants.PATH_DIALOG_BOX_SCENE).instance() # Loads the dialog
	var user_interface_node = get_node(_constants.PATH_USER_INTERFACE_NODE) # Retrieves the interface node
	dialog_box_instance.set_dialog_lines(dialog_lines) # Adds the dialog lines to the dialog
	user_interface_node.add_child(dialog_box_instance) # Puts the dialog box in the intreface
	dialog_box_instance.go() # Starts the dialog

func change_faced_direction(player_faced_direction):
	# Change the direction the NPC is facing based on the direction the player
	# is facing: if the player is facing up then face down, etc.
	if player_faced_direction == Vector2.UP:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "idle_down"
	elif player_faced_direction == Vector2.DOWN:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "idle_up"
	elif player_faced_direction == Vector2.RIGHT:
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.animation = "idle_right"
	elif player_faced_direction == Vector2.LEFT:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "idle_right"
