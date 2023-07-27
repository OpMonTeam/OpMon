@tool
# Used to run the AnimatedSprite in the Character scene in the editor
# It allows to show the characters’ sprites inside the editor
extends AnimatedSprite2D

func _process(delta):
	queue_redraw()
