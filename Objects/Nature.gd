extends Resource

class_name Nature

const Stats = preload("res://Objects/Enumerations.gd").Stats

@export var bonus: Stats
@export var malus: Stats

func _init(p_bonus = Stats.ATK, p_malus = Stats.DEF):
	bonus = p_bonus
	malus = p_malus
