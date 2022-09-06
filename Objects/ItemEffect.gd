# Note: model class
# Can’t be use as actual resource class since Godot’s interface can’t create new resources
# with types inheriting types inheriting from Resource
# Hope this will be possible in 4.0
# Meanwhile, just copy-paste these methods into each class and make it directly inherit Resource
extends Resource

class_name ItemEffect

# Every method here returns a boolean, true if the item if effectively used and false
# if it can’t be used right now (then if the item is consumed after use it won’t be, and the
# "not now" dialog will appear if in the overworld or "it has no effect" if in battle)

# Effect that applies when used in the overworld if the item doesn’t need an OpMon to be applied to
func apply_overworld(map_manager) -> bool:
	return false
	
# Effect that applies when used in the overworld on an OpMon
func apply_opmon_overworld(map_manager, user: OpMon) -> bool:
	return false
	
# Effect that applies when used in battle if the item doesn’t need an OpMon to be applied to
func apply_battle(battle_scene, players_team: OpTeam, opponent_team: OpTeam) -> bool:
	return false

# Effect that applies when used in battle on an OpMon
func apply_opmon_battle(battle_scene, user: OpMon, opponent: OpMon) -> bool:
	return false
