extends Node
# This singleton contains player-related data like name, id, or team
# It also contains some resources (OpMon species, moves, natures, items)

var player_name: String

var team: OpTeam

# Lists of loaded resources
# Keys: IDs (String)
var res_species: Dictionary
var res_move: Dictionary
var res_nature: Dictionary
var res_item: Dictionary

# Keys: Item ID (String)
# Values: Quantity (int)
var bag: Dictionary

# Loads every resource in a given directory.
# Warning: don’t forget to include "/" at the end of the directory.
func _load_dir(path: String) -> Array[Resource]:
	var dir = DirAccess.open(path)
	var files := dir.get_files()
	var ret: Array[Resource] = []
	for file in files:
		if file.ends_with(".tres"):
			ret.append(load(path + file))
	return ret

func _load_resources():
	print("Loading resources...")
	for species in _load_dir("res://Data/GodotResources/Species/"):
		res_species[species.id] = species
	print("Species loaded.")
	for move in _load_dir("res://Data/GodotResources/Moves/"):
		res_move[move.id] = move
	print("Moves loaded.")
	for nature in _load_dir("res://Data/GodotResources/Natures/"):
		res_nature[nature.id] = nature
	print("Natures loaded.")
	for item in _load_dir("res://Data/GodotResources/Items/"):
		res_item[item.id] = item
	#TODO: Temporary filling the player’s inventory for testing purposes. Don’t
	# forget to delete
	for i in range(20):
		res_item["DUMMY_" + String.num(i)] = Item.new("DUMMY_" + String.num(i))
		bag["DUMMY_" + String.num(i)] = i
	print("Items loaded. All resources are now loaded.")

func _ready():
	_load_resources()
	var furnurus = OpMon.new("", res_species["FURNURUS"], 10,
	[res_move["TACKLE"], res_move["GROWL"], res_move["EMBER"], null], res_nature["BOT"])
	var nanolphin = OpMon.new("", res_species["NANOLPHIN"], 10, 
	[res_move["TACKLE"], res_move["GROWL"], res_move["WATER_GUN"], null], res_nature["BOT"])
	var rosarin = OpMon.new("", res_species["ROSARIN"], 10, 
	[res_move["TACKLE"], res_move["GROWL"], res_move["VINE_WHIP"], null], res_nature["BOT"])
	team = OpTeam.new([rosarin, furnurus, nanolphin, null, null, null])
	bag["POTION"] = 3
	bag["XATTACK"] = 2

func save() -> Dictionary:
	return {
		"current_map" : {
			"name" : null, # Filled by MapManager
			"data" : null # Filled by MapManager
		},
		"player_character" : null, # Filled by MapManager
		"team" : team.save(),
		"player_name" : player_name,
		"bag": bag
	}

func load_save(data: Dictionary) -> void:
	team = OpTeam.new()
	team.load_save(data["team"])
	player_name = data["player_name"]
	bag = data["bag"]
