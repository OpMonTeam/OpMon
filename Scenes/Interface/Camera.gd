# This is the camera used throughout the game. It should be instantiated in a
# scene by the Manager.
#
# The camera can behave according to two modes:
# - In map mode, the camera is instantiated as a child of the player node, and
#   therefore follows the player. In that case, the camera anchor needs to be
#   its center so the player is at the center of the screen.
# - In static mode, the camera is instantiated as a child of the root node, and
#   therefore never moves. In that case, the camera anchor needs to be its top
#   left.

extends Camera2D

func set_map_mode():
	anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER

func set_static_mode():
	anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
