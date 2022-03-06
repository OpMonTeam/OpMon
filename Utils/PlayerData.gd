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
	var bot_nature = load("res://Data/GodotResources/Natures/Bot.tres")
	var popmon = OpMon.new("", load("res://Data/GodotResources/Species/Furnurus.tres"), 10,
	[tackle, growl, null, null], bot_nature)
	team = OpTeam.new([popmon, null, null, null, null, null])
