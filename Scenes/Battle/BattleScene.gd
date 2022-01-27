extends Interface

const Stats = preload("res://Objects/Enumerations.gd").Stats

var player_team: OpTeam
var opponent_team: OpTeam

var player_opmon: OpMon
var opponent_opmon: OpMon

var move_dialog = null

func init(p_player_team: OpTeam, p_opponent_team: OpTeam):
	player_team = p_player_team
	opponent_team = p_opponent_team
	player_opmon = player_team.get_opmon(0)
	opponent_opmon = opponent_team.get_opmon(0)
	
func _enter_tree():
	$PlayerOpMon.texture = player_opmon.species.back_texture
	$OpponentOpMon.texture = opponent_opmon.species.front_texture
	$PlayerInfobox/Name.text = player_opmon.get_effective_name()
	$OpponentInfobox/Name.text = opponent_opmon.get_effective_name()
	$PlayerInfobox/HPLabel.text = player_opmon.get_hp_string()
	$PlayerInfobox/HP.max_value = player_opmon.stats[Stats.HP]
	$PlayerInfobox/HP.value = player_opmon.hp
	$OpponentInfobox/HP.max_value = opponent_opmon.stats[Stats.HP]
	$OpponentInfobox/HP.value = opponent_opmon.hp

func opmon_selected():
	pass
	
func item_selected():
	pass
	
func move_selected():
	$BaseDialog.visible = false
	move_dialog = load("res://Scenes/Battle/MoveDialog.tscn").instance()
	move_dialog.set_moves(player_opmon.moves)
	move_dialog.rect_position = $BaseDialog.rect_position
	add_child(move_dialog)
	
func move_chosen(id):
	var opponent_chosen = 0
	
	# Calculates the order of the turn
	var order = []
	var player_move_priority = player_opmon.moves[id].data.priority > opponent_opmon.moves[opponent_chosen].data.priority
	var no_move_priority = player_opmon.moves[id].data.priority == opponent_opmon.moves[opponent_chosen].data.priority
	var player_faster = player_opmon.get_effective_stats()[Stats.SPE] >= opponent_opmon.get_effective_stats()[Stats.SPE]
	if player_move_priority or (no_move_priority and player_faster):
		order.append(player_opmon)
		order.append(opponent_opmon)
	else:
		order.append(opponent_opmon)
		order.append(player_opmon)
	
	# Processes the turn
	for opmon in order:
		var move
		var opponent
		if opmon == player_opmon:
			move = id
			opponent = opponent_opmon
		else:
			move = opponent_chosen
			opponent = player_opmon
		opmon.moves[move].move(self, opmon, opponent)
		if opmon.is_ko() or opponent.is_ko():
			ko()
	self.call_deferred("show_base_dialog")
	remove_child(move_dialog)

func show_base_dialog():
	$BaseDialog.visible = true

func run_selected():
	emit_signal("closed")
	
func move_failed():
	pass
	
func move_ineffective():
	pass
	
func effectiveness(factor):
	pass

func update_hp():
	$PlayerInfobox/HP.value = player_opmon.hp
	$PlayerInfobox/HPLabel.text = player_opmon.get_hp_string()
	$OpponentInfobox/HP.value = opponent_opmon.hp
	pass
	
func stat_changed(target: OpMon, stat, change):
	pass

func ko():
	emit_signal("closed")
