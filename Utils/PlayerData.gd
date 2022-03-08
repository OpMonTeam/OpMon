extends Node
# This singleton contains player-related data like name, id, or team
# This is this class that will be saved and loaded

var player_name: String

var team: OpTeam

var current_map: String

var current_position: Vector2

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
