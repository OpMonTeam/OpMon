extends Node
# This singleton contains player-related data like name, id, or team
# This is this class that will be saved and loaded

var player_name: String

var team: OpTeam

# Keys: Item
# Values: Quantity (int)
var bag: Dictionary

func _ready():
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
