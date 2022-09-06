extends Resource

class_name Item

const BagCategory = preload("res://Objects/Enumerations.gd").BagCategory

# Item ID used in the translations so the name key is ITEM_{id}_NAME and
# the description key is ITEM_{id}_DESCRIPTION
export(String) var id
# true if the player has to choose an opmon to which apply the item
export(bool) var applies_to_opmon
# If the item is deleted from the player’s bag after being used
export(bool) var consumes

# Must contain resources that "inherits" from ItemEffect (cf. ItemEffect comments)
# If empty, will trigger the classic dialog that shows when you can’t use an item
export(Array, Resource) var effect_used

func _init(p_id, p_applies_to_opmon, p_consumes, p_effect_used):
	id = p_id
	applies_to_opmon = p_applies_to_opmon
	consumes = p_consumes
	effect_used = p_effect_used
