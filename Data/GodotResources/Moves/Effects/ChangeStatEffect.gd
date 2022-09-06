extends Resource

class_name ChangeStatEffect

const Stats = preload("res://Objects/Enumerations.gd").Stats

export(Stats) var stat
export(int) var change
export(bool) var to_opponent

func _init(p_stat = Stats.ATK, p_change = 0, p_to_opponent = false):
	stat = p_stat
	change = p_change
	to_opponent = p_to_opponent

func apply(battle_scene, _move, user: OpMon, opponent: OpMon) -> bool:
	var target = opponent if to_opponent else user
	battle_scene.stat_changed(target, stat, target.change_stat(stat, change))
	return true
	
