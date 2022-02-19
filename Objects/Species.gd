extends Resource

class_name Species

const Type = preload("res://Objects/Enumerations.gd").Type
const Stats = preload("res://Objects/Enumerations.gd").Stats

export(String) var name
export(int) var opdex_number
# Has to be another Species (Godot does not support exporting custom resources for now)
export(Resource) var evolution
export(Type) var type_1
export(Type) var type_2
export(float) var height
export(float) var weight
export(String, MULTILINE) var opdex_entry

export(int) var base_attack
export(int) var base_defense
export(int) var base_special_attack
export(int) var base_special_defense
export(int) var base_speed
export(int) var base_hp
export(Array, Stats) var ev_given = []
export(int) var capture_rate

export(Texture) var front_texture
export(Texture) var back_texture

func _init(p_name = "", p_opdex_number = 0, p_evolution = null, p_type_1 = Type.UNKNOWN, p_type_2 = Type.UNKNOWN,
p_height = 0.0, p_weight = 0.0, p_opdex_entry = "", p_base_attack = 0, p_base_defense = 0, p_base_special_attack = 0,
p_base_special_defense = 0, p_base_speed = 0, p_base_hp = 0, p_ev_given = [], p_capture_rate = 255, p_front_texture = null,
p_back_texture = null):
	name = p_name
	opdex_number = p_opdex_number
	evolution = p_evolution
	type_1 = p_type_1
	type_2 = p_type_2
	height = p_height
	weight = p_weight
	opdex_entry = p_opdex_entry
	base_attack = p_base_attack
	base_defense = p_base_defense
	base_special_attack = p_base_special_attack
	base_special_defense = p_base_special_defense
	base_speed = p_base_speed
	base_hp = p_base_hp
	ev_given = p_ev_given
	capture_rate = p_capture_rate
	front_texture = p_front_texture
	back_texture = p_back_texture
