extends Interface

const Stats = preload("res://Objects/Enumerations.gd").Stats

var player_team: OpTeam
var opponent_team: OpTeam

var player_opmon: OpMon
var opponent_opmon: OpMon

var move_dialog = null

# Visual events during the battle (animations, dialogs or others) are put in the forms
# or "actions", a dictionnary with the name of a method and the parameters to give it
# The action queue is filled during the calculations and is executed afterward
# The action queue is not meant to be filled manually: methods exist to fill
# automatically the queue. You can see them after the "Methods queuing actions" section.
var _action_queue := []

# True if its the player’s turn being calculated, false if it’s the opponent’s
# turn being calculated. Used in some actions to determine which OpMon is active.
var _player_in_action := true

# True if the hp bar is animated so the player’s HP label can be updated in real time.
var _hp_bar_animated := false

func init(p_player_team: OpTeam, p_opponent_team: OpTeam):
	player_team = p_player_team
	opponent_team = p_opponent_team
	
func _enter_tree():
	_load_opmon(player_team.get_opmon(0), true)
	_load_opmon(opponent_team.get_opmon(0), false)
	

func _process(_delta):
	if _hp_bar_animated:
		_update_hp_label()

# Loads a new OpMon in the battle
# Used at the beginning of a battle and when changing of OpMon
# start_hp used to keep the HP bar showing pre-calculations HP when
# switching of OpMon
func _load_opmon(mon, players: bool, start_hp := -1):
	if players:
		player_opmon = mon
		$PlayerOpMon.texture = player_opmon.species.back_texture
		$PlayerInfobox/Name.text = player_opmon.get_effective_name()
		$PlayerInfobox/HPLabel.text = player_opmon.get_hp_string(start_hp)
		$PlayerInfobox/HP.max_value = player_opmon.stats[Stats.HP]
		$PlayerInfobox/HP.value = player_opmon.hp if start_hp < 0 else start_hp
		$BaseDialog.update_idle_dialog()
	else:
		opponent_opmon = mon
		$OpponentOpMon.texture = opponent_opmon.species.front_texture
		$OpponentInfobox/Name.text = opponent_opmon.get_effective_name()
		$OpponentInfobox/HP.max_value = opponent_opmon.stats[Stats.HP]
		$OpponentInfobox/HP.value = opponent_opmon.hp if start_hp < 0 else start_hp


###################
###################
# Choices of the base dialog
###################
###################


# Contains the OpMon selector, an instance of res://Scenes/Interface/Team/Team.tscn
# It’s loaded the first time by _load_opmon_selector, and then reused
var opmon_selector = null

# Different modes of the OpMon selector, 
# they change the methods its signal are connected to
enum SelectorMode {
	SWITCHER,	# When the "OpMon" option is selected
	KO,			# When the player chooses another OpMon after a KO
	NONE		# Only used for initialisation when no connection has been made yet
}

# null = no connection
var _selector_connections = {
	SelectorMode.NONE : {"choice": null, "closed": null},
	SelectorMode.SWITCHER : {"choice": "change_opmon", "closed": "no_opmon_changed"},
	SelectorMode.KO : {"choice": "next_opmon_chosen_after_ko", "closed": null}
}

var _selector_mode = SelectorMode.NONE


# Loads the OpMon selector
func _load_opmon_selector(selector_mode) -> void:
	opmon_selector = load("res://Scenes/Interface/Team/Team.tscn").instantiate()
	opmon_selector.set_map(self._map_manager)
	opmon_selector.mode = opmon_selector.Mode.SELECTOR
	add_child(opmon_selector)
	opmon_selector.disconnect("closed", Callable(_map_manager, "unload_interface"))
	_set_selector_mode(selector_mode)

# Changes the mode of the opmon selector
func _set_selector_mode(new_selector_mode) -> void:
	if new_selector_mode != _selector_mode:
		if _selector_connections[_selector_mode]["choice"] != null:
			opmon_selector.disconnect("choice", Callable(self, _selector_connections[_selector_mode]["choice"]))
		if _selector_connections[_selector_mode]["closed"] != null:
			opmon_selector.disconnect("closed", Callable(self, _selector_connections[_selector_mode]["closed"]))
		_selector_mode = new_selector_mode
		if _selector_connections[_selector_mode]["choice"] != null:
			opmon_selector.connect("choice", Callable(self, _selector_connections[_selector_mode]["choice"]))
		if _selector_connections[_selector_mode]["closed"] != null:
			opmon_selector.connect("closed", Callable(self, _selector_connections[_selector_mode]["closed"]))

func opmon_selected() -> void:
	if opmon_selector == null:
		_load_opmon_selector(SelectorMode.SWITCHER)
	else:
		_set_selector_mode(SelectorMode.SWITCHER)
		opmon_selector.visible = true
	$BaseDialog.visible = false # Disables the base dialog

# Connected to signal "choice" of opmon_selector
func change_opmon(selection: int) -> void:
	if selection == -1:
		no_opmon_changed()
	elif player_team.get_opmon(selection) == player_opmon:
		no_opmon_changed()
	else:
		_player_in_action = true
		# Adds the actions to change the OpMon visually
		switch_opmon(selection)
		# Changing OpMon behind the scenes for turn calculations
		player_opmon = player_team.get_opmon(selection)
		opmon_selector.visible = false
		opmon_selector.reset()
		move_chosen(-1, true)

# If the opmon selector has not selected any OpMon
# Connected to sigal "closed" of opmon_selector
func no_opmon_changed() -> void:
	$BaseDialog.visible = true
	opmon_selector.visible = false
	opmon_selector.reset()

func item_selected() -> void:
	pass

# When the move choice has been selected in the base menu
func move_selected():
	$BaseDialog.visible = false
	move_dialog = load("res://Scenes/Battle/MoveDialog.tscn").instantiate()
	move_dialog.set_moves(player_opmon.moves)
	move_dialog.position = $BaseDialog.position
	add_child(move_dialog)

func run_selected():
	emit_signal("closed")

# Called when a move has been chosen in the move selection menu
# Can also be called when an other action has been chosen and a turn starts (then id < 0)
# id: the identifier of the move (-1 for no move)
# action_priority: if the player has to act first (changing OpMon or using an item for example)
func move_chosen(id: int, action_priority := false):
	if id >= 0: # id == -1 means no move for this turn so no move has been selected
				# id == -2 could mean "use struggle" in the future
		remove_child(move_dialog)
	$TextDialog.visible = true
	var opponent_chosen = 0
	
	# Calculates the order of the turn
	var order = []
	if action_priority:
		order.append(player_opmon)
		order.append(opponent_opmon)
	else:
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
		_player_in_action = opmon == player_opmon
		if _player_in_action:
			move = id
			opponent = opponent_opmon
		else:
			move = opponent_chosen
			opponent = player_opmon
		if move >= 0:
			opmon.moves[move].move(self, opmon, opponent)
		if opmon.is_ko() or opponent.is_ko():
			ko()
			break
	_next_action()

# Calls the next action to show, and ends the turn if there is no more actions to show
func _next_action():
	if _action_queue.is_empty():
		# call_deferred to allow a pause between the interaction action of closing the
		# eventual dialog and the one of choosing "move" in the main battle menu
		call_deferred("show_base_dialog")
		$TextDialog.visible = false
	else:
		var action = _action_queue.pop_front()
		self.callv(action["method"], action["parameters"])

func show_base_dialog():
	$BaseDialog.visible = true

func _update_hp_label():
	$PlayerInfobox/HPLabel.text = String.num($PlayerInfobox/HP.value) + " / " + String.num(player_opmon.stats[Stats.HP])

# Executed when one on the OpMons is KO
func ko():
	if player_opmon.is_ko():
		add_dialog([tr("BATTLE_KO").replace("{opmon}", player_opmon.get_effective_name())])
	else:
		add_dialog([tr("BATTLE_KO").replace("{opmon}", opponent_opmon.get_effective_name())])
	_action_queue.append({"method": "_ko", "parameters":[]})


###################
###################
# Methods queuing actions
###################
###################


# The "text" parameter must be an array of Strings where one element is printed on one dialog.
# Make sure the text is not too long to be shown.
func add_dialog(text: Array):
	_action_queue.append({"method": "_dialog", "parameters": [text]})
	
# is_self: if the updated hp has to be the acting opmon’s bar (true) or the opponent’s one (false)
# new value: the new value of the hp bar.
func update_hp(is_self: bool, new_value: int):
	_action_queue.append({"method": "_update_hp", "parameters": [is_self == _player_in_action, new_value]})
	

const stat_names = {
	Stats.ATK : "STAT_CHANGE_ATK",
	Stats.DEF : "STAT_CHANGE_DEF",
	Stats.ATKSPE : "STAT_CHANGE_ATKSPE",
	Stats.DEFSPE : "STAT_CHANGE_DEFSPE",
	Stats.SPE : "STAT_CHANGE_SPE",
	Stats.EVA : "STAT_CHANGE_EVA",
	Stats.HP : "STAT_CHANGE_HP",
	Stats.ACC : "STAT_CHANGE_ACC"
}

# Note: good idea to add lines for every possible changes
# but you forgot to take into account the fact that
# it can change from -12 to +12 if the stats
# has already been modified
# Todo: take this into account later
# const change_texts = {
#	-6 : "reached rock bottom",
#	-5 : "completely dropped",
#	-4 : "has drastically lowered",
#	-3 : "has hugely lowered",
#	-2 : "has highly lowered",
#	-1 : "has lowered",
#	0 : "is inchanged",
#	1 : "has increased",
#	2 : "has highly increased",
#	3 : "has hugely increased",
#	4 : "has drastically increased",
#	5 : "has exploded",
#	6 : "breached the roof"
#}

func stat_changed(target: OpMon, stat, change):
	var changed_string = tr("STAT_CHANGE_DIALOG").replace("{opmon}", target.get_effective_name()).replace("{stat}", tr(stat_names[stat])).replace("{change}", tr(("STAT_CHANGE_LOWER" if change < 0 else "STAT_CHANGE_HIGHER")))
	add_dialog([changed_string])
	
func move_failed():
	add_dialog([tr("BATTLE_MOVE_FAILED")])

const effectiveness_texts = {
	0.0 : "MOVE_EFFECTIVENESS_NONE",
	0.25 : "MOVE_EFFECTIVENESS_VERYLOW",
	0.5 : "MOVE_EFFECTIVENESS_LOW",
	2.0 : "MOVE_EFFECTIVENESS_HIGH",
	4.0 : "MOVE_EFFECTIVENESS_VERYHIGH"
}

func effectiveness(factor: float):
	if factor != 1.0:
		add_dialog([tr(effectiveness_texts[factor])])


func animate_move(transforms: Array):

	# Go through the list of sequential stages of the animation
	for transform in transforms:
		_action_queue.append({"method": "_animate_move", "parameters": [_player_in_action, transform]})

func close():
	_action_queue.append({"method": "_close", "parameters": []})

func switch_opmon(new_opmon: int):
	var old_opmon_name = player_opmon.get_effective_name() if _player_in_action else opponent_opmon.get_effective_name()
	var team = player_team if _player_in_action else opponent_team
	add_dialog([tr("BATTLE_OPMON_CHANGE").replace("{opmon1}", old_opmon_name).replace("{opmon2}", team.get_opmon(new_opmon).get_effective_name())])
	_action_queue.append({"method": "_switch_opmon", "parameters": [_player_in_action, new_opmon, team.get_opmon(new_opmon).hp]})

###################
###################
# Methods executing actions
# Every action must, by one way or another, call back _next_action to continue the chain
###################
###################


# Calls _next_action via $TextDialog whose signal "dialog_over" is connected to _next_action
func _dialog(text: Array):
	$TextDialog.reset()
	$TextDialog.set_dialog_lines(text)
	$TextDialog.go()

func _animate_move(player: bool, transform: Array):

	var active_opmon_rect: TextureRect
	var active_opmon_animation_player: AnimationPlayer

	var invert_transform = !player

	var animation := Animation.new()
	var animlib := AnimationLibrary.new()
	var track_index

	# Map from generic transform type used in Move class to property used for OpMon container property
	var transform_property_map = {
		"TRANSLATE":"position",
		"ROTATE":"rotation",
		"SCALE":"scale"
		}

	# Determine whose OpMon is being animated
	if player:
		active_opmon_rect = $PlayerOpMon
		active_opmon_animation_player = $PlayerOpMon/AnimationPlayer
	else:
		active_opmon_rect = $OpponentOpMon
		active_opmon_animation_player = $OpponentOpMon/AnimationPlayer

	# Go through the list of simultaneous transformations to play at once
	# TODO: Check if its possible to have a library of animations for each move
	for transform_component in transform:

		var pre_animation_value
		var post_animation_value = transform_component["value"]

		track_index = animation.add_track(Animation.TYPE_VALUE)

		# Save the default value for this transformation, and determine correct inversion value if necessary
		if transform_component["transform"] == "TRANSLATE":
			pre_animation_value = active_opmon_rect.position
			if invert_transform:
				post_animation_value = post_animation_value * Vector2(-1,1)
			post_animation_value = pre_animation_value + post_animation_value

		elif transform_component["transform"] == "ROTATE":
			pre_animation_value = active_opmon_rect.rotation
			if invert_transform:
				post_animation_value = post_animation_value * -1
			post_animation_value = post_animation_value

		elif transform_component["transform"] == "SCALE":
			pre_animation_value = active_opmon_rect.scale
			post_animation_value = post_animation_value

		animation.track_set_path(track_index, ".:" + transform_property_map[transform_component["transform"]])
		animation.length = 2

		animation.track_insert_key (track_index, 0, pre_animation_value)
		animation.track_insert_key (track_index, 1, post_animation_value)
		animation.track_insert_key (track_index, 2, pre_animation_value)

		active_opmon_animation_player.speed_scale = transform_component["speed"]

	# Add animation object to the scene
	if active_opmon_animation_player.has_animation("opmon_rect"):
		active_opmon_animation_player.remove_animation_library("")
	animlib.add_animation("opmon_rect", animation)
	active_opmon_animation_player.add_animation_library("", animlib)

	# Run the animation and advance the queue
	active_opmon_animation_player.play("opmon_rect")
	if active_opmon_animation_player.is_playing():
		await active_opmon_animation_player.animation_finished

	_next_action()

# Calls _next_action via the animation player whose signal "animation_finished" is connected to "_health_bar_stop"
func _update_hp(player: bool, new_value: int):
	var hpbar:TextureProgressBar = $PlayerInfobox/HP if player else $OpponentInfobox/HP
	var tween := create_tween()
	tween.tween_property(hpbar, "value", new_value, 1)
	tween.tween_callback(_health_bar_stop)
	_hp_bar_animated = true
	tween.play()
	
# Calls _next_action for _update_hp
func _health_bar_stop():
	_hp_bar_animated = false
	_next_action()
	
# Always the last action by construction since added after the calculations
# and stops them if added
func _ko():
	if player_team.is_ko() or opponent_team.is_ko():
		emit_signal("closed")
	else:
		if player_opmon.is_ko():
			if opmon_selector == null:
				_load_opmon_selector(SelectorMode.KO)
			else:
				_set_selector_mode(SelectorMode.KO)
				opmon_selector.visible = true
			# _next_action is called by next_opmon_chosen_after_ko, when
			# the player selected a new OpMon
		else:
			_load_opmon(opponent_team.next_available(), false)
			_next_action()

# Called by the "choice" signal of the team manager screen called by _ko()
func next_opmon_chosen_after_ko(opmon: int):
	_load_opmon(opmon_selector.team.get_opmon(opmon), true)
	opmon_selector.visible = false
	opmon_selector.reset()
	_next_action()

func _switch_opmon(_player_in_action: bool, new_opmon: int, hp: int):
	var team = player_team if _player_in_action else opponent_team
	_load_opmon(team.get_opmon(new_opmon), _player_in_action, hp)
	_next_action()
	
func _close():
	emit_signal("closed")
