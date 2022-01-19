extends Resource

class_name Nature

const Stats = preload("res://Objects/Enumerations.gd").Stats

export(Stats) var bonus
export(Stats) var malus

func _init(p_bonus = Stats.ATK, p_malus = Stats.DEF):
	bonus = p_bonus
	malus = p_malus
