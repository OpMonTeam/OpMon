tool
extends Teleporter

export(String, "wooden_door", "shop_door") var animation := "" setget set_animation

func set_animation(new_animation):
	$AnimatedSprite.animation = new_animation
	animation = new_animation

func start(player):
	.start(player)
	$AnimatedSprite.play()

func teleport(_object,_key):
	.teleport(_object,_key)
	$AnimatedSprite.frame = 0
