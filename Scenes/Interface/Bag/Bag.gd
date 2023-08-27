extends Interface

# The number of items the list can show. In reality, the list can show one more item,
# but the twelfth item implies by its placement that there is more items below, so
# it must not be present at the end of the list.
const LIST_SIZE := 11

const Stats = preload("res://Objects/Enumerations.gd").Stats

# The different modes of the bag
enum Mode {
	OVERWORLD, # If the bag is opened from the game menu
	BATTLE # If the bag is opened during a battle
}
var _mode := Mode.OVERWORLD

var _item_boxes: Array[HBoxContainer] # each container contains the name and quantity of an item
var _all_items: Array # an array of all the items in the bag (items IDs)

var _cur_pos_rel := 0 # Cursor position on the current screen
var _first_item := 0 # Position of the first item in the shown list in the item array
var _current_list_size := 0 # Number of items currently shown on the list

var _opmon_selection := false # true if in opmon selection mode
var _opmon_selection_curpos := 0
var _opmon_selection_item: Item

# Prevents the ui_accept action of the Submenu from reactivating the submenu at
# the same time as closing it
var _accept_cooldown = 5

var _battle_scene: BattleScene

# Locks inputs while items execute
var _locked := false

# Updates the list with the currently shown items
func _update_items():
	_all_items = PlayerData.bag.keys().filter(func(item): return PlayerData.bag[item] > 0)
	_all_items.sort()
	_current_list_size = 0
	for i in range(_first_item, _first_item + LIST_SIZE + 1):
		if i < _all_items.size(): # There is still items
			_item_boxes[i - _first_item].get_child(0).text = "ITEMNAME_" + _all_items[i]
			_item_boxes[i - _first_item].get_child(1).text = "x" + String.num(PlayerData.bag[_all_items[i]])
			_item_boxes[i - _first_item].visible = true
			_current_list_size += 1
		else: # No items left
			_item_boxes[i - _first_item].visible = false
	_update_description()

func _update_description():
	$ItemDescription/Description.text = "ITEMDESC_" + _all_items[_cur_pos_rel + _first_item]

func _load_opmons():
	for i in range(6):
		var opmon = PlayerData.team.get_opmon(i)
		if opmon != null:
			get_node("Mons/Container/Mon" + str(i+1) + "/Sprite").texture = opmon.species.front_texture
			get_node("Mons/Container/Mon" + str(i+1) + "/Data/Name").text = opmon.get_effective_name()
			get_node("Mons/Container/Mon" + str(i+1) + "/Data/HP").max_value = opmon.stats[Stats.HP]
			get_node("Mons/Container/Mon" + str(i+1) + "/Data/HP").value = opmon.hp
			get_node("Mons/Container/Mon" + str(i+1)).visible = true

func _update_opmons_hp():
	for i in range(6):
		var opmon = PlayerData.team.get_opmon(i)
		if opmon != null:
			get_node("Mons/Container/Mon" + str(i+1) + "/Data/HP").max_value = opmon.stats[Stats.HP]
			get_node("Mons/Container/Mon" + str(i+1) + "/Data/HP").value = opmon.hp

func _ready():
	_item_boxes = [
		$List/Items/Item0, 
		$List/Items/Item1, 
		$List/Items/Item2,
		$List/Items/Item3,
		$List/Items/Item4,
		$List/Items/Item5,
		$List/Items/Item6,
		$List/Items/Item7,
		$List/Items/Item8,
		$List/Items/Item9,
		$List/Items/Item10,
		$List/Items/Item11
	]
	
	_update_items()
	_load_opmons()
	$Submenu.connect("choice", _submenu_selection)

func _input(event):
	if not $Submenu.visible and _accept_cooldown == 0 and self.visible and not _locked:
		if not _opmon_selection:
			if event.is_action_pressed("ui_up"):
				if _cur_pos_rel == 0 and _first_item > 0:
					_first_item -= 1
					_update_items()
					_update_description()
				elif _cur_pos_rel > 0:
					_cur_pos_rel -= 1
					_update_description()
			elif event.is_action_pressed("ui_down"):
				if _cur_pos_rel == LIST_SIZE - 1 and _first_item + LIST_SIZE < _all_items.size():
					_first_item += 1
					_update_items()
					_update_description()
				elif _cur_pos_rel != LIST_SIZE - 1 and _cur_pos_rel != _current_list_size - 1:
					_cur_pos_rel += 1
					_update_description()
			elif event.is_action_pressed("ui_accept"):
				_accept_cooldown = 5
				$Submenu.visible = true
			elif event.is_action_pressed("ui_cancel"):
				emit_signal("closed")
			
			$List/Selector.position = Vector2($List/Selector.position.x, 8 + _cur_pos_rel*40)
		else:
			if event.is_action_pressed("ui_up"):
				if _opmon_selection_curpos != 0:
					_opmon_selection_curpos -= 1
					$Mons/Selector.position.y -= 80
			elif event.is_action_pressed("ui_down"):
				if _opmon_selection_curpos != PlayerData.team.size() - 1:
					_opmon_selection_curpos += 1
					$Mons/Selector.position.y += 80
			elif event.is_action_pressed("ui_cancel"):
				_quit_opmon_selection()
			elif event.is_action_pressed("ui_accept"):
				_use_item(_opmon_selection_item)
		

func _quit_opmon_selection():
	if _opmon_selection:
		_opmon_selection = false
		$Mons/Selector.visible = false
		_opmon_selection_item = null
		_opmon_selection_curpos = 0
		$Mons/Selector.position = Vector2(8, 25)

func _process(delta):
	if _accept_cooldown != 0 and not $Submenu.visible:
		_accept_cooldown -= 1

func _unlock():
	_locked = false
	_accept_cooldown = 5
	
func _use_item(item: Item):
	_locked = true
	var valid_use: bool
	match [_mode, item.applies_to_opmon]:
		[Mode.OVERWORLD, false]:
			valid_use = item.apply_overworld(_map_manager)
		[Mode.BATTLE, false]:
			valid_use = item.apply_battle(_battle_scene)
		[Mode.OVERWORLD, true]:
			valid_use = item.apply_opmon_overworld(_map_manager, PlayerData.team.get_opmon(_opmon_selection_curpos))
		[Mode.BATTLE, true]:
			valid_use = item.apply_opmon_battle(_battle_scene, PlayerData.team.get_opmon(_opmon_selection_curpos), _battle_scene.opponent_opmon)
		_:
			print("Warning: unknown clause (Bag._use_item)")
	if item.dialog != null: # If dialog is not null it means a dialog is shown by the item
		item.dialog.connect("dialog_over", Callable(self, "_unlock"))
	elif valid_use: # if no dialog but valid use, no need to maintain the lock
		_unlock()
	if valid_use and item.consumes:
		PlayerData.bag[_all_items[_first_item + _cur_pos_rel]] -= 1
		_update_items()
	elif not valid_use:
		var dialog := _map_manager.load_dialog("BAG_CANTUSE")
		dialog.connect("dialog_over", Callable(self, "_unlock"))
		dialog.go()
	_update_opmons_hp()
	# If there is no item left of the same type, can't use it on another OpMon
	if _opmon_selection and Mode.OVERWORLD and PlayerData.bag[item.id] == 0:
		_quit_opmon_selection()

func _submenu_selection(selection):
	$Submenu.visible = false
	match selection:
		0:
			var item: Item = PlayerData.res_item[_all_items[_first_item + _cur_pos_rel]]
			if item.applies_to_opmon:
				_opmon_selection = true
				$Mons/Selector.visible = true
				_opmon_selection_item = item
				_accept_cooldown = 5
			else:
				_use_item(item)
	
