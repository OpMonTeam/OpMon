extends Resource

# Class Move: Represent the raw data of a move. For an actual move object that
# evolves in the game (pp and other modificators), see the OpMove class in the OpMon object

class_name Move

const Type = preload("res://Objects/Enumerations.gd").Type

export(String) var name
export(int,0,200) var power
export(Type) var type
export(int,0,100) var accuracy
export(bool) var is_special
export(bool) var never_fails
export(int, 5, 60) var max_power_points
# 15 for top priority, 1 for low priority, uniquely determines the priority for prioritary moves
# if 0, the move is not prioritary, the order of action will be determined by speed
export(int, 0, 15) var priority

# Scripts must have the method move_effect(move, user, target). Leave empty for no effect.
export(Script) var pre_effect
export(Script) var post_effect
export(Script) var fail_effect

# TODO: Add the objects related to the animations & co

func _init(p_name = "", p_power = 0, p_type = Type.UNKNOWN, p_accuracy = 0, p_is_special = false,
p_never_fails = false, p_max_power_points = 50, p_priority = 0, p_pre_effect = null, p_post_effect = null,
p_fail_effect = null):
	name = p_name
	power = p_power
	type = p_type
	accuracy = p_accuracy
	is_special = p_is_special
	never_fails = p_never_fails
	max_power_points = p_max_power_points
	priority = p_priority
	pre_effect = p_pre_effect
	post_effect = p_post_effect
	fail_effect = p_fail_effect
