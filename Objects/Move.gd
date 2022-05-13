extends Resource

# Class Move: Represent the raw data of a move. For an actual move object that
# evolves in the game (pp and other modificators), see the OpMove class in the OpMon object

class_name Move

const Type = preload("res://Objects/Enumerations.gd").Type

enum Category {PHYSICAL, SPECIAL, STATUS}

export(String) var name
export(int,0,200) var power
export(Type) var type
export(int,0,100) var accuracy
export(Category) var category
export(bool) var never_fails
export(int, 5, 60) var max_power_points
# 15 for top priority, 1 for low priority, uniquely determines the priority for prioritary moves
# if 0, the move is not prioritary, the order of action will be determined by speed
export(int, 0, 15) var priority

# Must contain resources of the type MoveEffect (Godot does not support exporting custom resources yet)
# Leave empty for no effects
# Effects will be called in the order first to last
export(Array, Resource) var pre_effect = []
export(Array, Resource) var post_effect = []
export(Array, Resource) var fail_effect = []

export(String) var move_animation

func _init(p_name = "", p_power = 0, p_type = Type.UNKNOWN, p_accuracy = 0, p_category = Category.PHYSICAL,
p_never_fails = false, p_max_power_points = 50, p_priority = 0, p_pre_effect = [], p_post_effect = [],
p_fail_effect = [], p_move_animation = "NONE"):
	name = p_name
	power = p_power
	type = p_type
	accuracy = p_accuracy
	category = p_category
	never_fails = p_never_fails
	max_power_points = p_max_power_points
	priority = p_priority
	pre_effect = p_pre_effect
	post_effect = p_post_effect
	fail_effect = p_fail_effect
	move_animation = p_move_animation
