extends Interface

# The number of items the list can show. In reality, the list can show one more item,
# but the twelfth item implies by its placement that there is more items below, so
# it must not be present at the end of the list.
const LIST_SIZE := 11

# The different modes of the bag
enum Mode {
	OVERWORLD, # If the bag is opened from the game menu
	BATTLE # If the bag is opened during a battle
}

var _item_boxes: Array[HBoxContainer] # each container contains the name and quantity of an item
var _all_items: Array # an array of all the items in the bag (items IDs)


var _cur_pos_rel := 0 # Cursor position on the current screen
var _first_item := 0 # Position of the first item in the shown list in the item array
var _current_list_size := 0 # Number of items currently shown on the list

# Prevents the ui_accept action of the Submenu from reactivating the submenu at
# the same time as closing it
var _accept_cooldown = 5

# Updates the list with the currently shown items
func _update_items():
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
	_all_items = PlayerData.bag.keys().filter(func(item): return PlayerData.bag[item] > 0)
	_all_items.sort()
	_update_items()
	$Submenu.connect("choice", _submenu_selection)

func _input(event):
	if not $Submenu.visible and _accept_cooldown == 0 and self.visible:
		if event.is_action_pressed("ui_up"):
			if _cur_pos_rel == 0 and _first_item > 0:
				_first_item -= 1
				_update_items()
			elif _cur_pos_rel > 0:
				_cur_pos_rel -= 1
			_update_description()
		elif event.is_action_pressed("ui_down"):
			if _cur_pos_rel == LIST_SIZE - 1 and _first_item + LIST_SIZE < _all_items.size():
				_first_item += 1
				_update_items()
			elif _cur_pos_rel < LIST_SIZE - 1 and _cur_pos_rel < _current_list_size:
				_cur_pos_rel += 1
			_update_description()
		elif event.is_action_pressed("ui_accept"):
			_accept_cooldown = 5
			$Submenu.visible = true
		elif event.is_action_pressed("ui_cancel"):
			emit_signal("closed")
		
		$List/Selector.position = Vector2($List/Selector.position.x, 8 + _cur_pos_rel*40)

func _process(delta):
	if _accept_cooldown != 0:
		_accept_cooldown -= 1

func _submenu_selection(selection):
	$Submenu.visible = false
	_accept_cooldown = 5
