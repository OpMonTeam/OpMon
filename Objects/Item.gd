extends Resource

class_name Item

const BagCategory = preload("res://Objects/Enumerations.gd").BagCategory

enum UseType {
	OVERWORLD,
	OVERWORLD_OPMON,
	BATTLE,
	BATTLE_OPMON
}

# Item ID used for storage in the code and in the translations:
# the name key is ITEM_{id}_NAME and the description key is ITEM_{id}_DESCRIPTION
@export var id: String
# true if the player has to choose an opmon to which apply the item
@export var applies_to_opmon: bool
# If the item is deleted from the player’s bag after being used
@export var consumes: bool

# Must contain resources that "inherits" from ItemEffect (cf. ItemEffect comments)
# If empty, will trigger the classic dialog that shows when you can’t use an item
# Will execute the effect in order, one after the other. Will show the dialog
# « can’t use this item » only if none of the effects returns true
@export var effect_used: Array[ItemEffect] # (Array, Resource)

func _init(p_id = "", p_applies_to_opmon = false, p_consumes = false, p_effect_used: Array[ItemEffect] = []):
	id = p_id
	applies_to_opmon = p_applies_to_opmon
	consumes = p_consumes
	effect_used = p_effect_used
	
# Uses the item in the overworld if the item doesn’t need an OpMon to be applied to
func apply_overworld(map_manager: MapManager) -> bool:
	var applies = false
	for effect in effect_used:
		applies = applies || effect.apply_overworld(map_manager)
	return applies

# Uses the item in the overworld on an OpMon
func apply_opmon_overworld(map_manager: MapManager, user: OpMon) -> bool:
	if not applies_to_opmon: return false
	var applies = false
	for effect in effect_used:
		applies = applies || effect.apply_opmon_overworld(map_manager, user)
	return applies
	
# Uses the item in battle without applying it to a specific OpMon
func apply_battle(battle_scene: BattleScene, players_team: OpTeam, opponent_team: OpTeam) -> bool:
	var applies = false
	for effect in effect_used:
		applies = applies || effect.apply_battle(battle_scene, players_team, opponent_team)
	return applies

# Uses the item in battle on an OpMon
func apply_opmon_battle(battle_scene: BattleScene, user: OpMon, opponent: OpMon) -> bool:
	if not applies_to_opmon: return false
	var applies = false
	for effect in effect_used:
		applies = applies || effect.apply_opmon_battle(battle_scene, user, opponent)
	return applies
