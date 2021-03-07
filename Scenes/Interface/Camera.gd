extends Camera2D

func set_map_mode():
	anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER

func set_normal_mode():
	anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
