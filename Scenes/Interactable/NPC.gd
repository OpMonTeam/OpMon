extends "res://Scenes/Interactable/Interactable.gd"

export var dialog_lines := ["Fake line 1.", "Fake line 2."]

func interact(player_facing_direction):
	change_faced_direction(player_facing_direction)
	_dialog_box_instance = load(PATH_DIALOG_BOX_SCENE).instance()
	_dialog_box_instance.set_dialog_lines(dialog_lines)
	_root.add_child(_dialog_box_instance)
	_dialog_box_instance.go()

func change_faced_direction(player_facing_direction):
	# Change the direction the NPC is facing based on the direction the player
	# is facing: if the player is facing up then face down, etc.
	if player_facing_direction == Vector2.UP:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "idle_down"
	elif player_facing_direction == Vector2.DOWN:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "idle_up"
	elif player_facing_direction == Vector2.RIGHT:
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.animation = "idle_right"
	elif player_facing_direction == Vector2.LEFT:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.animation = "idle_right"
