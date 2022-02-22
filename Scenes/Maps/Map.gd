tool
extends YSort

const PlayerObject = preload("res://Scenes/Events/Interactable/Player.gd")

signal map_loaded
signal map_entered(map)

const _constants = preload("res://Utils/Constants.gd")

export(Array, String) var adjacent_maps_names := [] setget set_adjacent_maps_names
export(Array, Vector2) var adjacent_maps_positions := [] setget set_adjacent_maps_positions

# Only used in editor to toogle the adjacent maps
# If the adjacent maps are shown, it is possible the map can't be saved (circular dependancies)
# This has no effect outside of the editor
export(bool) var show_adjacent_maps := false setget set_show_adjacent_maps

var _adjacent_maps := {}


var zone: Area2D

func set_show_adjacent_maps(new_sam):
	show_adjacent_maps = new_sam
	if show_adjacent_maps:
		show_adjacent_maps()
	else:
		clear_adjacent_maps()

func set_adjacent_maps_names(new_adjacent_maps_names):
	adjacent_maps_names = new_adjacent_maps_names
	if Engine.editor_hint and show_adjacent_maps:
		show_adjacent_maps()
		

func set_adjacent_maps_positions(new_adjacent_maps_positions):
	adjacent_maps_positions = new_adjacent_maps_positions
	if Engine.editor_hint and show_adjacent_maps:
		show_adjacent_maps()
		
func show_adjacent_maps():
	if not(adjacent_maps_names.size() == adjacent_maps_positions.size()):
		if not Engine.editor_hint:
			assert(adjacent_maps_names.size() == adjacent_maps_positions.size())
		return
	# Checks for map addition / Shows the maps
	for map in adjacent_maps_names:
		if not _adjacent_maps.has(map):
			_adjacent_maps[map] = load(_constants.PATH_MAP_SCENE + map + "/" + map + ".tscn").instance()
			_adjacent_maps[map].position = adjacent_maps_positions[adjacent_maps_names.find(map)] * (_constants.TILE_SIZE)
			if Engine.editor_hint:
				_adjacent_maps[map].modulate = Color(0.5,0.5,0.5,0.5)
			else:
				_adjacent_maps[map].connect("map_entered", self, "_on_adjacent_entered")
			add_child(_adjacent_maps[map])
	if Engine.editor_hint:
		# Checks for map deletion if in editor
		var keys = _adjacent_maps.keys()
		for map in keys:
			if not adjacent_maps_names.has(map):
				_adjacent_maps[map].queue_free()
				_adjacent_maps.erase(map)
		# Updates positions if in editor
		for map in _adjacent_maps:
			_adjacent_maps[map].position = adjacent_maps_positions[adjacent_maps_names.find(map)] * (_constants.TILE_SIZE)

func clear_adjacent_maps():
	var keys = _adjacent_maps.keys()
	for map in keys:
		_adjacent_maps[map].queue_free()
		_adjacent_maps.erase(map)
		
func _ready():
	# Do not show adjacent maps if not in editor: MapManager will handle it.
	if not Engine.editor_hint:
		clear_adjacent_maps()
		zone = $MapZone

func _on_map_entered(body: Node):
	if body is PlayerObject:
		emit_signal("map_entered",self)

func _on_adjacent_entered(map):
	emit_signal("map_entered", map)
