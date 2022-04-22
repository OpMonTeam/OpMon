# Script for using the Team screen as a Manager (in the Game Menu)
# This screen allows changing the organization of the team and only
# closes by pressing the menu button.
extends "Team.gd"

func _input(event):
	._input(event)
	if event.is_action_pressed("ui_accept"):
		emit_signal("closed")
	elif event.is_action_pressed("menu"):
		emit_signal("closed")
