extends ItemEffect

class_name Heal

@export var hp: int

func _init(p_hp: int):
	hp = p_hp

func apply_opmon_battle(battle_scene: BattleScene, user: OpMon, opponent: OpMon) -> bool:
	user.hp += hp
	battle_scene.heal(user, hp)
	return true
	
func apply_opmon_overworld(map_manager: MapManager, user: OpMon) -> bool:
	user.hp += hp
	# TODO add dialog here, standardize a way to start a dialog from MapManager so the
	# items and events can start a dialog the same way and easily
	return true

