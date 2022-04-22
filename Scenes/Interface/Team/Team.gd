# The main features of the team screen. Specific features according to the different
# possible uses of this screen will be put in inherited classes
extends Interface

# All the different possible modes of the team manager screen
enum Mode {
	MANAGER, # The classic manager screen from the game menu
	CHOSER, # Screen to chose one OpMon from the team
	REORDER # Switches the position of two OpMons
}

var mode = Mode.MANAGER

var curcolor_reorder = Color("68abfae4")
var curcolor_normal = Color("68fbcaca")

var opmons := []

var team: OpTeam

var selection := 0

# Prevents the ui_accept action of the Submenu from reactivating the submenu at
# the same time as closing it
var accept_cooldown := 0

# Currently selected OpMon for the reorder mode
var reorder_selection := -1

signal choice(id)

func _update_labels():
	for i in range(6):
		if team.get_opmon(i) != null:
			opmons[i].get_node("Name").text = team.get_opmon(i).get_effective_name()
			opmons[i].get_node("Pict").texture = team.get_opmon(i).species.front_texture
		else:
			opmons[i].get_node("Name").text = ""
			opmons[i].get_node("Name").text = ""

func _ready():
	team = _map_manager.player_data.team
	opmons.append($Mon1)
	opmons.append($Mon2)
	opmons.append($Mon3)
	opmons.append($Mon4)
	opmons.append($Mon5)
	opmons.append($Mon6)
	_update_labels()

func _quit_reorder_mode():
	if mode == Mode.REORDER:
		$ReorderRect.visible = false
		reorder_selection = -1
		$Selrect.color = curcolor_normal
		mode = Mode.MANAGER
		
func _reorder_select(r_selection: int):
	reorder_selection = r_selection
	$ReorderRect.rect_position = opmons[reorder_selection].rect_position
	$ReorderRect.visible = true

func _input(event):
	if not $Submenu.visible and accept_cooldown == 0:
		# Conditions on selection are here to avoid warping
		if event.is_action_pressed("ui_down") and selection != 4:
			selection += 2
		elif event.is_action_pressed("ui_up") and selection != 1:
			selection -= 2
		elif event.is_action_pressed("ui_left") and selection % 2 == 1:
			selection -= 1
		elif event.is_action_pressed("ui_right") and selection % 2 == 0:
			selection += 1
		elif event.is_action_pressed("ui_accept"):
			accept_cooldown = 5
			if mode == Mode.REORDER and reorder_selection != selection:
						team.switch(reorder_selection, selection)
						_update_labels()
						_quit_reorder_mode()
			elif mode != Mode.REORDER:
				$Submenu.visible = true
		elif event.is_action_pressed("ui_cancel"):
			if mode == Mode.REORDER:
				_quit_reorder_mode()
			else:
				emit_signal("closed")
		if selection < 0:
				selection = 0
		elif selection > (team.size() - 1):
			selection = team.size() - 1
		$Selrect.rect_position = opmons[selection].rect_position

func _process(_delta):
	if accept_cooldown != 0:
		accept_cooldown -= 1
		

func _submenu_selection(selection):
	$Submenu.visible = false
	if $Submenu.curpos == 0:
		mode = Mode.REORDER
		$Selrect.color = curcolor_reorder
		_reorder_select(self.selection)
	$Submenu.curpos = 0
	accept_cooldown = 5
