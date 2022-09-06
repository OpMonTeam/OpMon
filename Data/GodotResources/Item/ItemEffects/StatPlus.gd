extends Resource

class_name StatPlus

const Stats = preload("res://Objects/Enumerations.gd").Stats

export(Stats) var stat
export(int) var change
var cse: ChangeStatEffect

func _init(p_stat, p_change):
	stat = p_stat
	change = p_change
	cse = ChangeStatEffect.new(stat, change, false)

func apply_opmon_battle(battle_scene, user: OpMon, opponent: OpMon) -> bool:
	return cse.apply(battle_scene, null, user, opponent) # Always return true

# Effect that applies when used in the overworld if the item doesn’t need an OpMon to be applied to
func apply_overworld() -> bool:
	return false
	
# Effect that applies when used in the overworld on an OpMon
func apply_opmon_overworld() -> bool:
	return false
	
# Effect that applies when used in battle if the item doesn’t need an OpMon to be applied to
func apply_battle() -> bool:
	return false
