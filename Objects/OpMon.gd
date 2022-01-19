extends Object

class_name OpMon

const Type = preload("res://Objects/Enumerations.gd").Type
const Stats = preload("res://Objects/Enumerations.gd").Stats
const Status = preload("res://Objects/Enumerations.gd").Status

var stats = [0, 0, 0, 0, 0, 0]
var ev = [0, 0, 0, 0, 0, 0]
var stats_change = [0, 0, 0, 0, 0, 0, 0, 0]

var species: Species
var level: int
var moves = [null, null, null, null]
var nature: Nature
var hp: int
var status = Status.NOTHING
var nickname: String

func calc_stats():
	var base_stats = [species.base_attack, species.base_defense, species.base_special_attack, species.base_special_defense,
	species.base_speed, species.base_hp]
	for i in range(6):
		stats[i] = round(((((2 * base_stats[i] + 31 + (ev[i] / 4)) * level) / 100) + 5))
		if nature.bonus == i:
			stats[i] *= 1.1
		elif nature.malus == i:
			stats[i] *= 0.9

func _init(p_nickname: String, p_species: Species, p_level: int, p_moves: Array, p_nature: Nature):
	nickname = p_nickname
	species = p_species
	level = p_level
	moves = p_moves
	nature = p_nature
	calc_stats()
	
func get_effective_stats():
	var effective_stats = stats
	# Accuracy and evasion
	effective_stats.append(100)
	effective_stats.append(100)
	# TODO: add in-battle stat modification (+think of a more efficient system than the c++ version)
