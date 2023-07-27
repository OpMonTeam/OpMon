extends Resource

class_name Species

const Type = preload("res://Objects/Enumerations.gd").Type
const Stats = preload("res://Objects/Enumerations.gd").Stats

@export_group("Properties")
@export var name: String
@export var opdex_number: int
# Has to be another Species (Godot does not support exporting custom resources for now)
@export var evolution: Species
@export var type_1: Type
@export var type_2: Type
@export var height: float
@export var weight: float
@export_multiline var opdex_entry: String

@export_group("Stats")
@export var base_attack: int
@export var base_defense: int
@export var base_special_attack: int
@export var base_special_defense: int
@export var base_speed: int
@export var base_hp: int
@export var ev_given: Array[Stats]
@export var capture_rate: int

@export_group("Textures")
@export var front_texture: Texture2D
@export var back_texture: Texture2D

func _init(p_name = "", p_opdex_number = 0, p_evolution = null, p_type_1 = Type.NONE, p_type_2 = Type.NONE,
p_height = 0.0, p_weight = 0.0, p_opdex_entry = "", p_base_attack = 0, p_base_defense = 0, p_base_special_attack = 0,
p_base_special_defense = 0, p_base_speed = 0, p_base_hp = 0, p_ev_given:Array[Stats] = [], p_capture_rate = 255, p_front_texture = null,
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
