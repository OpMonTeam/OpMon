extends Resource

class_name StatPlus

const Stats = preload("res://Objects/Enumerations.gd").Stats

@export var stat: Stats
@export var change: int
var cse: ChangeStatEffect

func _init(p_stat, p_change):
	stat = p_stat
	change = p_change
	cse = ChangeStatEffect.new(stat, change, false)

func apply_opmon_battle(battle_scene, user: OpMon, opponent: OpMon) -> bool:
	return cse.apply(battle_scene, null, user, opponent) # Always return true

func apply_overworld(map_manager) -> bool:
	return false
	
func apply_opmon_overworld(map_manager, user: OpMon) -> bool:
	return false
	
func apply_battle(battle_scene, players_team: OpTeam, opponent_team: OpTeam) -> bool:
	return false
