extends Interface

# The number of items the list can show. In reality, the list can show one more item,
# but the twelfth item implies by its placement that there is more items below, so
# it must not be present at the end of the list.
const LIST_SIZE := 10

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

# Updates the list with the currently shown items
func _update_items():
	# Range: either the limit is the shown list size or the full item size.
	for i in range(_first_item, min(_first_item + LIST_SIZE + 1, _all_items.size())):
		_item_boxes[i].get_child(0).text = "ITEMNAME_" + _all_items[i]
		_item_boxes[i].get_child(1).text = "x" + String.num(PlayerData.bag[_all_items[i]])
		_item_boxes[i].visible = true

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
		$List/Items/Item10
	]
	_all_items = PlayerData.bag.keys()
	_all_items.sort()
	_update_items()

func _input(event):
	if event.is_action_pressed("ui_up"):
		if _cur_pos_rel == 0 and _first_item > 0:
			_first_item -= 1
			_update_items()
		elif _cur_pos_rel > 0:
			_cur_pos_rel -= 1
	elif event.is_action_pressed("ui_down"):
		if _cur_pos_rel == LIST_SIZE - 1 and _first_item + LIST_SIZE < _all_items.size():
			_first_item += 1
			_update_items()
		elif _cur_pos_rel < LIST_SIZE:
			_cur_pos_rel += 1
	
	$List/Selector.position = Vector2($List/Selector.position.x, 8 + _cur_pos_rel*40)

func _process(delta):
	pass
