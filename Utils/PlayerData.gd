extends Node
# This singleton contains player-related data like name, id, or team
# This is this class that will be saved and loaded

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
	print("Items loaded. All resources are now loaded.")

func _ready():
	_load_resources()
	var tackle = load("res://Data/GodotResources/Moves/Tackle.tres")
	var growl = load("res://Data/GodotResources/Moves/Growl.tres")
	var ember = load("res://Data/GodotResources/Moves/Ember.tres")
	var vine_whip = load("res://Data/GodotResources/Moves/VineWhip.tres")
	var water_gun = load("res://Data/GodotResources/Moves/WaterGun.tres")
	var bot_nature = load("res://Data/GodotResources/Natures/Bot.tres")
	var furnurus = OpMon.new("", load("res://Data/GodotResources/Species/Furnurus.tres"), 10,
	[tackle, growl, ember, null], bot_nature)
	var nanolphin = OpMon.new("", load("res://Data/GodotResources/Species/Nanolphin.tres"), 10, 
	[tackle, growl, water_gun, null], bot_nature)
	var rosarin = OpMon.new("", load("res://Data/GodotResources/Species/Rosarin.tres"), 10, 
	[tackle, growl, vine_whip, null], bot_nature)
	team = OpTeam.new([rosarin, furnurus, nanolphin, null, null, null])
	bag[load("res://Data/GodotResources/Item/Potion.tres")] = 3
	bag[load("res://Data/GodotResources/Item/XAttack.tres")] = 2

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
