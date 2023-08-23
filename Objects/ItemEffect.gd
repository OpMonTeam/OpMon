extends Resource

class_name ItemEffect

signal close_bag

func _init():
	super._init()

# Every method here returns a boolean, true if the item is effectively used and false
# if it can’t be used right now (then if the item is consumed after use it won’t be, and the
# "not now" dialog will appear if in the overworld or "it has no effect" if in battle)

# Effect that applies when used in the overworld if the item doesn’t need an OpMon to be applied to
func apply_overworld(map_manager: MapManager) -> bool:
	return false
	
# Effect that applies when used in the overworld on an OpMon
func apply_opmon_overworld(map_manager: MapManager, user: OpMon) -> bool:
	return false
	
# Effect that applies when used in battle if the item doesn’t need an OpMon to be applied to
func apply_battle(battle_scene: BattleScene, players_team: OpTeam, opponent_team: OpTeam) -> bool:
	return false

# Effect that applies when used in battle on an OpMon
func apply_opmon_battle(battle_scene: BattleScene, user: OpMon, opponent: OpMon) -> bool:
	return false
