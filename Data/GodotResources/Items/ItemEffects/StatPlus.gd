extends ItemEffect

class_name StatPlus

const Stats = preload("res://Objects/Enumerations.gd").Stats

@export var stat: Stats
@export var change: int
var cse: ChangeStatEffect # Emulates the effect of a move of this type

func _init(p_stat, p_change):
	stat = p_stat
	change = p_change
	cse = ChangeStatEffect.new(stat, change, false)

func apply_opmon_battle(battle_scene: BattleScene, user: OpMon, opponent: OpMon) -> bool:
	return cse.apply(battle_scene, null, user, opponent) # Always return true
