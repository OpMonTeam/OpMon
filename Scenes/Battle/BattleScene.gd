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
	pass
	
func run_selected():
	emit_signal("closed")
	
func move_failed():
	pass
	
func move_ineffective():
	pass
	
func effectiveness(factor):
	pass
	
func update_hp():
	pass
