tool
extends YSort

signal map_loaded

const _constants = preload("res://Utils/Constants.gd")

export(Array, String) var adjacent_maps := [] setget set_adjacent_maps
export(Array, Vector2) var adjacent_maps_positions := [] setget set_adjacent_maps_positions

var adjacent_maps_editor := {}

var zone: Area2D

func set_adjacent_maps(new_adjacent_maps):
	if Engine.editor_hint:
		adjacent_maps = new_adjacent_maps
		update_editor_maps()
		

func set_adjacent_maps_positions(new_adjacent_maps_positions):
	if Engine.editor_hint:
		adjacent_maps_positions = new_adjacent_maps_positions
		update_editor_maps()
		
func update_editor_maps():
	if not(adjacent_maps.size() == adjacent_maps_positions.size()):
		return
	# Checks for map addition
	for map in adjacent_maps:
		if not adjacent_maps_editor.has(map):
			adjacent_maps_editor[map] = load(_constants.PATH_MAP_SCENE + map + "/" + map + ".tscn").instance()
			adjacent_maps_editor[map].position = adjacent_maps_positions[adjacent_maps.find(map)] * (_constants.TILE_SIZE)
			adjacent_maps_editor[map].modulate = Color(0.5,0.5,0.5,0.5)
			add_child(adjacent_maps_editor[map])
	# Checks for map deletion
	var keys = adjacent_maps_editor.keys()
	for map in keys:
		if not adjacent_maps.has(map):
			adjacent_maps_editor[map].queue_free()
			adjacent_maps_editor.erase(map)
	# Updates positions
	for map in adjacent_maps_editor:
		adjacent_maps_editor[map].position = adjacent_maps_positions[adjacent_maps.find(map)] * (_constants.TILE_SIZE)
		
		
func _ready():
	# Do not show adjacent maps if not in editor: MapManager will handle it.
	if not Engine.editor_hint:
		var keys = adjacent_maps_editor.keys()
		for map in keys:
			adjacent_maps_editor[map].queue_free()
			adjacent_maps_editor.erase(map)
		zone = $MapZone
