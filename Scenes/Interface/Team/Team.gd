# The main features of the team screen. Specific features according to the different
# possible uses of this screen will be put in inherited classes
extends Interface

var opmons := []

var team: OpTeam

var selection := 0

# Avoid the ui_accept action of the Submenu to reactivate the submenu at the same time as closing it
var accept_cooldown := 0

signal choice(id)

func _ready():
	team = _map_manager.player_data.team
	opmons.append($Mon1)
	opmons.append($Mon2)
	opmons.append($Mon3)
	opmons.append($Mon4)
	opmons.append($Mon5)
	opmons.append($Mon6)
	for i in range(6):
		if team.get_opmon(i) != null:
			opmons[i].get_node("Name").text = team.get_opmon(i).get_effective_name()
			opmons[i].get_node("Pict").texture = team.get_opmon(i).species.front_texture
		else:
			opmons[i].get_node("Name").text = ""

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
			$Submenu.visible = true
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
	$Submenu.curpos = 0
	accept_cooldown = 5
