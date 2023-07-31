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
var _cur_pos_abs := 0 # Cursor position on the full list of items
var _current_list_size := 0 # Number of items currently shown on the list

func _init_items():
	_all_items = PlayerData.bag.keys()
	_all_items.sort()
	
	var i := 0
	
	for item in _all_items:
		if i > LIST_SIZE:
			break
		_item_boxes[i].get_child(0).text = "ITEMNAME_" + item
		_item_boxes[i].get_child(1).text = "x" + String.num(PlayerData.bag[item])
		_item_boxes[i].visible = true
		i+=1

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
	_init_items()

func _process(delta):
	pass
