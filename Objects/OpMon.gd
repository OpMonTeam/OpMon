extends Object

const Type = preload("res://Objects/Enumerations.gd").Type
const Stats = preload("res://Objects/Enumerations.gd").Stats
const Status = preload("res://Objects/Enumerations.gd").Status

var stats = [0, 0, 0, 0, 0, 0]
var ev = [0, 0, 0, 0, 0, 0]
var stats_change = [0, 0, 0, 0, 0, 0, 0, 0]

var species: Species
var level: int
# Must contain OpMove objects
var moves = [null, null, null, null]
var nature: Nature
var hp: int
var status = Status.NOTHING
var nickname = ""

# Recalculates the stats from the base stats, evs, nature and level
func calc_stats():
	var base_stats = [species.base_attack, species.base_defense, species.base_special_attack, species.base_special_defense,
	species.base_speed, species.base_hp]
	for i in range(6):
		stats[i] = round(((((2 * base_stats[i] + 31 + (ev[i] / 4)) * level) / 100) + 5))
		if nature.bonus == i:
			stats[i] *= 1.1
		elif nature.malus == i:
			stats[i] *= 0.9

# p_moves must contain four Move objects
func _init(p_nickname: String, p_species: Species, p_level: int, p_moves: Array, p_nature: Nature):
	nickname = p_nickname
	species = p_species
	level = p_level
	for i in range(4): # Initializes OpMoves from the raw data of Moves
		if moves[i] != null:
			moves[i] = OpMove.new(p_moves[i])
	nature = p_nature
	calc_stats()
	hp = stats[Stats.HP]

# Returns the final statistics of the OpMon, with the in-battle modifications
func get_effective_stats():
	var effective_stats = stats
	# Accuracy and evasion
	effective_stats.append(100)
	effective_stats.append(100)
	# TODO: add in-battle stat modification (+think of a more efficient system than the c++ version)

# Completely heals the OpMon
func heal():
	hp = stats[Stats.HP]
	status = Status.NOTHING
	for move in moves:
		move.power_points = move.data.max_power_points
		
func is_ko():
	return hp > 0
	
func get_effective_name():
	if nickname == "":
		return species.name
	else:
		return nickname
		
func get_hp_string():
	return String(hp) + " / " + String(stats[Stats.HP])

# A Move class representing an OpMon’s move. It uses the data of Move but this class is "living",
# meaning it’s edited to store the power points and other dynamic data of a move.
# It also contains the method that processes the move
class OpMove:
	var power_points: int
	var data: Move
	
	# Private variables used to calculate damages
	# Hp lost by the defending OpMon
	var hp_lost: int
	# Used for moves that use multiple turns
	func _init(p_data: Move):
		data = p_data
		power_points = data.max_power_points
