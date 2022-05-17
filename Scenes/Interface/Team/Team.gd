# The main features of the team screen. Specific features according to the different
# possible uses of this screen will be put in inherited classes
extends Interface

# All the different possible modes of the team manager screen
enum Mode {
	MANAGER, # The classic manager screen from the game menu
	SELECTOR, # Screen to chose one OpMon from the team
	REORDER # Switches the position of two OpMons
}

const SUBMENU_CHOICES := {
	Mode.MANAGER: ["TEAMMANAGER_ORDER","MENU_BACK"],
	Mode.SELECTOR: ["TEAMMANAGER_SELECT", "MENU_BACK"]
}

var mode = Mode.MANAGER

var curcolor_reorder = Color("68abfae4")
var curcolor_normal = Color("68fbcaca")

var opmons_rects := []

var team: OpTeam

var _selection := 0

# Prevents the ui_accept action of the Submenu from reactivating the submenu at
# the same time as closing it
var _accept_cooldown := 5

# Currently selected OpMon for the reorder mode
var _reorder_selection := -1

# Allow choosing KO OpMons
var selector_allow_ko := false

signal choice(id)

func _update_labels():
	for i in range(6):
		if team.get_opmon(i) != null:
			opmons_rects[i].get_node("Name").text = team.get_opmon(i).get_effective_name()
			opmons_rects[i].get_node("Pict").texture = team.get_opmon(i).species.front_texture
		else:
			opmons_rects[i].get_node("Name").text = ""
			opmons_rects[i].get_node("Name").text = ""

func _ready():
	team = _map_manager.player_data.team
	opmons_rects.append($Mon1)
	opmons_rects.append($Mon2)
	opmons_rects.append($Mon3)
	opmons_rects.append($Mon4)
	opmons_rects.append($Mon5)
	opmons_rects.append($Mon6)
	_update_labels()
	$Submenu.set_choices(SUBMENU_CHOICES[mode])

# Resets cursor positions to zero in case of reutilisation of the object
func reset():
	_selection = 0
	_accept_cooldown = 5
	_reorder_selection = -1

func _quit_reorder_mode():
	if mode == Mode.REORDER:
		$ReorderRect.visible = false
		_reorder_selection = -1
		$Selrect.color = curcolor_normal
		mode = Mode.MANAGER
		
func _reorder_select(r_selection: int):
	_reorder_selection = r_selection
	$ReorderRect.rect_position = opmons_rects[_reorder_selection].rect_position
	$ReorderRect.visible = true

func _input(event):
	if not $Submenu.visible and _accept_cooldown == 0 and self.visible:
		# Conditions on selection are here to avoid warping
		if event.is_action_pressed("ui_down") and _selection != 4:
			_selection += 2
		elif event.is_action_pressed("ui_up") and _selection != 1:
			_selection -= 2
		elif event.is_action_pressed("ui_left") and _selection % 2 == 1:
			_selection -= 1
		elif event.is_action_pressed("ui_right") and _selection % 2 == 0:
			_selection += 1
		elif event.is_action_pressed("ui_accept"):
			_accept_cooldown = 5
			if mode == Mode.REORDER and _reorder_selection != _selection:
						team.switch(_reorder_selection, _selection)
						_update_labels()
						_quit_reorder_mode()
			elif mode != Mode.REORDER:
				$Submenu.visible = true
		elif event.is_action_pressed("ui_cancel"):
			if mode == Mode.REORDER:
				_quit_reorder_mode()
			else:
				emit_signal("closed")
		if _selection < 0:
				_selection = 0
		elif _selection > (team.size() - 1):
			_selection = team.size() - 1
		$Selrect.rect_position = opmons_rects[_selection].rect_position

func _process(_delta):
	if _accept_cooldown != 0:
		_accept_cooldown -= 1
		

func _submenu_selection(selection):
	$Submenu.visible = false
	if selection == 0:
		if mode == Mode.MANAGER:
			mode = Mode.REORDER
			$Selrect.color = curcolor_reorder
			_reorder_select(self._selection)
		elif mode == Mode.SELECTOR:
			# Should not be null since the cursor can’t stand on a null OpMon
			if not team.get_opmon(self._selection).is_ko():
				emit_signal("choice", self._selection)
			else:
				$Nope.play()
	# If selection == 1, it’s the back button so #Submenu.visible = false is enough
	_accept_cooldown = 5
