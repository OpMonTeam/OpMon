extends Object

class_name OpMon

const Type = preload("res://Objects/Enumerations.gd").Type
const Stats = preload("res://Objects/Enumerations.gd").Stats
const Status = preload("res://Objects/Enumerations.gd").Status
const TYPE_EFFECTIVENESS = preload("res://Objects/Enumerations.gd").TYPE_EFFECTIVENESS

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
		if p_moves[i] != null:
			moves[i] = OpMove.new(p_moves[i])
	nature = p_nature
	calc_stats()
	hp = stats[Stats.HP]

# Returns the final statistics of the OpMon, with the in-battle modifications
func get_effective_stats() -> Array:
	var effective_stats = stats
	# Accuracy and evasion
	effective_stats.append(100)
	effective_stats.append(100)
	# TODO: add in-battle stat modification (+think of a more efficient system than the c++ version)
	return effective_stats

# Completely heals the OpMon
func heal():
	hp = stats[Stats.HP]
	status = Status.NOTHING
	for move in moves:
		move.power_points = move.data.max_power_points
		
func is_ko() -> bool:
	return hp > 0
	
func get_effective_name() -> String:
	if nickname == "":
		return species.name
	else:
		return nickname
		
func get_hp_string() -> String:
	return String(hp) + " / " + String(stats[Stats.HP])
	
	
# In-battle modification of statistics, capped at ±6
# Returns the actual modification
func change_stat(stat, change) -> int:
	# Checks if the cap is already reached
	if (change > 0 and stats_change[stat] == 6) or (change < 0 and stats_change[stat] == -6):
		return 0
	stats_change[stat] += change
	var overflow = stats_change[stat] - 6
	if overflow > 0:
		stats_change[stat] = 6
		return change - overflow
	var underflow = stats_change[stat] + 6
	if underflow < 0:
		stats_change[stat] = -6
		return change - underflow
	return change
	
func make_connections(battle_scene):
	for m in moves:
		if m != null:
			m.make_connections(battle_scene)
			
func break_connections(battle_scene):
	for m in moves:
		if m != null:
			m.break_connections(battle_scene)

# A Move class representing an OpMon’s move. It uses the data of Move but this class is "living",
# meaning it’s edited to store the power points and other dynamic data of a move.
# It also contains the method that processes the move
class OpMove:
	var power_points: int
	var data: Move
	
	signal fail
	signal ineffective
	signal effectiveness(factor)
	signal update_hp
	
	const Stats = preload("res://Objects/Enumerations.gd").Stats
	
	# Private variables used to calculate damages
	# Hp lost by the defending OpMon
	var hp_lost: int
	# Used for moves that use multiple turns
	func _init(p_data: Move):
		data = p_data
		power_points = data.max_power_points
		
	func make_connections(battle_scene):
		connect("fail", battle_scene, "move_failed")
		connect("ineffective", battle_scene, "move_ineffective")
		connect("effectiveness", battle_scene, "effectiveness")
		connect("update_hp", battle_scene, "update_hp")
		#for e in data.pre_effect:
			#for s in e.signals:
				#e.connect(s, battle_scene, s)
				
	func break_connections(battle_scene):
		disconnect("fail", battle_scene, "move_failed")
		disconnect("ineffective", battle_scene, "move_ineffective")
		disconnect("effectiveness", battle_scene, "effectiveness")
		disconnect("update_hp", battle_scene, "update_hp")
		#for e in data.pre_effect:
			#for s in e.signals:
				#e.disconnect(s, battle_scene, s)
	func move(user: OpMon, opponent: OpMon):
		power_points -= 1
		if (100*randf()) > (user.stats[Stats.ACC] / opponent.stats[Stats.EVA]) and not data.never_fails:
			emit_signal("fail")
			var proceed = true
			for e in data.fail_effect:
				proceed = proceed and e.apply(self, user, opponent)
				if not proceed:
					return
			return
		
		var proceed = true
		for e in data.pre_effect:
			proceed = proceed and e.apply(self, user, opponent)
			if not proceed:
				return
		var effectiveness = TYPE_EFFECTIVENESS[data.type][opponent.species.type_1] * TYPE_EFFECTIVENESS[data.type][opponent.species.type_2]
		if effectiveness == 0.0:
			emit_signal("ineffective")
			proceed = true
			for e in data.fail_effect:
				proceed = proceed and e.apply(self, user, opponent)
				if not proceed:
					return
			return
		
		# TODO: Animations here
		
		if(data.type != Move.Category.STATUS):
			var ad = user.get_effective_stats()[Stats.ATK if data.category == data.Category.PHYSICAL else Stats.ATKSPE] / user.get_effective_stats()[Stats.DEF if data.category == data.Category.PHYSICAL else Stats.DEFSPE]
			var hp_lost_float = (((2/5) * user.level + 2) * data.power * ad / 50) + 2
			if data.type == user.species.type_1 or data.type == user.species.type_2:
				hp_lost_float *= 1.5
			hp_lost_float *= effectiveness
			hp_lost_float *= 0.85 + 0.15 * randf()
			hp_lost = round(hp_lost_float)
			opponent.hp -= hp_lost
			emit_signal("update_hp")
			emit_signal("effectiveness", effectiveness)
		proceed = true
		for e in data.post_effect:
			proceed = proceed and e.apply(self, user, opponent)
			if not proceed:
				return
