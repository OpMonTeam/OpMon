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

var _items_boxes: Array[HBoxContainer] # each container contains the name and quantity of an item
var _items: Array[Item]

var _cur_pos := 0 # Cursor position
var _current_list_size := 0 # Number of items currently shown on the list

func _init_items():
	var items := _map_manager.player_data.bag.keys()
	for item in items:
		

func _ready():
	pass

func _process(delta):
	pass
