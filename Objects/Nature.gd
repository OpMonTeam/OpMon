extends Resource

class_name Nature

const Stats = preload("res://Objects/Enumerations.gd").Stats

@export var id: String # used for storage in the code and in the translations
@export var bonus: Stats
@export var malus: Stats

func _init(p_id = "", p_bonus = Stats.ATK, p_malus = Stats.DEF):
	id = p_id
	bonus = p_bonus
	malus = p_malus
