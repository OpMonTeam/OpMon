extends Object

class_name OpMon

const Type = preload("res://Objects/Enumerations.gd").Type
const Stats = preload("res://Objects/Enumerations.gd").Stats
const Status = preload("res://Objects/Enumerations.gd").Status
const TYPE_EFFECTIVENESS = preload("res://Objects/Enumerations.gd").TYPE_EFFECTIVENESS

var stats = [0, 0, 0, 0, 0, 0]
var ev = [0, 0, 0, 0, 0, 0]
var stats_change = [0, 0, 0, 0, 0, 0, 0, 0]

# In-battle stats modificators for basic stats
const mod_stat = [0.25, 0.29, 0.33, 0.40, 0.50, 0.67, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0]
# In-battle stats modificators for accuracy and evasion
const mod_stat_2 = [0.33, 0.38, 0.43, 0.5, 0.6, 0.75, 1.0, 1.33, 1.67, 2.0, 2.33, 2.67, 3.0]

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
	
	for i in range(6):
		effective_stats[i] *= mod_stat[stats_change[i] + 6]
		
	for i in range(6,8):
		effective_stats[i] *= mod_stat_2[stats_change[i] + 6]
	
	return effective_stats

# Completely heals the OpMon
func heal():
	hp = stats[Stats.HP]
	status = Status.NOTHING
	for move in moves:
		move.power_points = move.data.max_power_points
		
func is_ko() -> bool:
	return hp <= 0
	
func get_effective_name() -> String:
	if nickname == "":
		return tr(species.name)
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

# A Move class representing an OpMon’s move. It uses the data of Move but this class is "living",
# meaning it’s edited to store the power points and other dynamic data of a move.
# It also contains the method that processes the move
class OpMove:
	var power_points: int
	var data: Move
	
	const Stats = preload("res://Objects/Enumerations.gd").Stats
	
	# Private variables used to calculate damages
	# Hp lost by the defending OpMon
	var hp_lost: int
	# Used for moves that use multiple turns
	func _init(p_data: Move):
		data = p_data
		power_points = data.max_power_points

	func move(battle_scene, user: OpMon, opponent: OpMon):
		power_points -= 1
		battle_scene.add_dialog([tr("BATTLE_MOVE_USE").replace("{opmon}",user.get_effective_name()).replace("{move}",tr(self.data.name))])
		# Checks if the move fails
		if (100*randf()) > (data.accuracy * (user.stats[Stats.ACC] / opponent.stats[Stats.EVA])) and not data.never_fails:
			battle_scene.move_failed()
			var proceed = true
			for e in data.fail_effect:
				proceed = proceed and e.apply(battle_scene, data, user, opponent)
				if not proceed:
					return
			return
		
		# Processes the pre-move effects
		var proceed = true
		for e in data.pre_effect:
			proceed = proceed and e.apply(battle_scene, data, user, opponent)
			if not proceed:
				return
				
		# Checks if the move is effective
		var effectiveness = TYPE_EFFECTIVENESS[data.type][opponent.species.type_1] * TYPE_EFFECTIVENESS[data.type][opponent.species.type_2]
		if effectiveness == 0.0:
			battle_scene.effectiveness(effectiveness)
			proceed = true
			for e in data.fail_effect:
				proceed = proceed and e.apply(battle_scene, data, user, opponent)
				if not proceed:
					return
			return
		
		# TODO: Animations here
		
		# Calculates and applies the damages
		if(data.category != Move.Category.STATUS):
			var ad = user.get_effective_stats()[Stats.ATK if data.category == data.Category.PHYSICAL else Stats.ATKSPE] / user.get_effective_stats()[Stats.DEF if data.category == data.Category.PHYSICAL else Stats.DEFSPE]
			var hp_lost_float = (((2/5) * user.level + 2) * data.power * ad / 50) + 2
			if data.type == user.species.type_1 or data.type == user.species.type_2:
				hp_lost_float *= 1.5
			hp_lost_float *= effectiveness
			hp_lost_float *= 0.85 + 0.15 * randf()
			hp_lost = round(hp_lost_float)
			opponent.hp -= hp_lost
			battle_scene.update_hp(false, opponent.hp)
			battle_scene.effectiveness(effectiveness)
		
		# Processes the post-move effects
		proceed = true
		for e in data.post_effect:
			proceed = proceed and e.apply(battle_scene, data, user, opponent)
			if not proceed:
				return
