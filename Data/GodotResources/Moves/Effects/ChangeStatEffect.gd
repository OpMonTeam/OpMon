extends MoveEffect

class_name ChangeStatEffect

const Stats = preload("res://Objects/Enumerations.gd").Stats

@export var stat: Stats
@export var change: int
@export var to_opponent: bool

func _init(p_stat = Stats.ATK, p_change = 0, p_to_opponent = false):
	stat = p_stat
	change = p_change
	to_opponent = p_to_opponent

func apply(battle_scene: BattleScene, _move, user: OpMon, opponent: OpMon) -> bool:
	var target = opponent if to_opponent else user
	battle_scene.stat_changed(target, stat, target.change_stat(stat, change))
	return true
	
