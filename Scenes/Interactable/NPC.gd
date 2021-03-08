extends "res://Scenes/Interactable/Interactable.gd"

export var dialog_lines := ["Fake line 1.", "Fake line 2."]

func interact(player_faced_direction):
	change_faced_direction(player_faced_direction)
	var dialog_box_instance = load(_constants.PATH_DIALOG_BOX_SCENE).instance()
	var user_interface_node = get_node(_constants.PATH_USER_INTERFACE_NODE)
	dialog_box_instance.set_dialog_lines(dialog_lines)
	user_interface_node.add_child(dialog_box_instance)
	dialog_box_instance.go()

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
