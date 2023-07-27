extends Resource

class_name Item

const BagCategory = preload("res://Objects/Enumerations.gd").BagCategory

# Item ID used in the translations so the name key is ITEM_{id}_NAME and
# the description key is ITEM_{id}_DESCRIPTION
@export var id: String
# true if the player has to choose an opmon to which apply the item
@export var applies_to_opmon: bool
# If the item is deleted from the player’s bag after being used
@export var consumes: bool

# Must contain resources that "inherits" from ItemEffect (cf. ItemEffect comments)
# If empty, will trigger the classic dialog that shows when you can’t use an item
@export var effect_used # (Array, Resource)

func _init(p_id, p_applies_to_opmon, p_consumes, p_effect_used):
	id = p_id
	applies_to_opmon = p_applies_to_opmon
	consumes = p_consumes
	effect_used = p_effect_used
