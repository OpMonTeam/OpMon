@tool
extends Teleporter

@export var animation := "": set = set_animation

func set_animation(new_animation):
	$AnimatedSprite2D.animation = new_animation
	animation = new_animation

func start(player):
	super.start(player)
	$AnimatedSprite2D.play()

func teleport(_object,_key):
	super.teleport(_object,_key)
	$AnimatedSprite2D.frame = 0
