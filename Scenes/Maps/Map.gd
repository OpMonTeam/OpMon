@tool
extends Node2D

const PlayerObject = preload("res://Scenes/Events/Interactable/Player.gd")

signal map_loaded
signal map_entered(map)

const _constants = preload("res://Utils/Constants.gd")

@export var adjacent_maps_names := []:
	set(new_adjacent_maps_names):
		adjacent_maps_names = new_adjacent_maps_names
		if Engine.is_editor_hint() and do_show_adjacent_maps:
			show_adjacent_maps(self, _adjacent_maps)

@export var adjacent_maps_positions := []: 
	set(new_adjacent_maps_positions):
		adjacent_maps_positions = new_adjacent_maps_positions
		if Engine.is_editor_hint() and do_show_adjacent_maps:
			show_adjacent_maps(self, _adjacent_maps)

# Only used in editor to toogle the adjacent maps
# If the adjacent maps are shown, it is possible the map can't be saved (circular dependancies)
# This has no effect outside of the editor
@export var do_show_adjacent_maps := false:
	set(new_sam):
		do_show_adjacent_maps = new_sam
		if do_show_adjacent_maps:
			show_adjacent_maps(self, _adjacent_maps)
		else:
			clear_adjacent_maps()

var _adjacent_maps := {}

var zone: Area2D

# The parameters differ according to the situation
# In editor, they are the map and its _adjacent_maps container
# In game, they are the map manager and its maps container
func show_adjacent_maps(parent, container):
	if not(adjacent_maps_names.size() == adjacent_maps_positions.size()):
		if not Engine.is_editor_hint():
			assert(adjacent_maps_names.size() == adjacent_maps_positions.size())
		return
	# Checks for map addition / Shows the maps
	for map in adjacent_maps_names:
		if not container.has(map):
			container[map] = load(_constants.PATH_MAP_SCENE + map + "/" + map + ".tscn").instantiate()
			container[map].position = adjacent_maps_positions[adjacent_maps_names.find(map)] * (_constants.TILE_SIZE) + (position if not Engine.is_editor_hint() else Vector2.ZERO)
			if Engine.is_editor_hint():
				container[map].modulate = Color(0.5,0.5,0.5,0.5)
			else:
				container[map].connect("map_entered", Callable(self, "_on_adjacent_entered"))
			parent.call_deferred("add_child",container[map])

	# Checks for map deletion
	var keys = container.keys()
	for map in keys:
		if not adjacent_maps_names.has(map):
			if container[map] != self:
				container[map].call_deferred("queue free")
				container.erase(map)
	# Updates positions
	for map in container:
		if container[map] != self:
			container[map].position = adjacent_maps_positions[adjacent_maps_names.find(map)] * (_constants.TILE_SIZE) + (position if not Engine.is_editor_hint() else Vector2.ZERO)

# Called when switched to adjacent mode: the map doesn’t have the player in it
# and has to notify the main map when the player enters in it.
func adjacent_mode(map_manager, main_map):
	self.disconnect("map_entered", Callable(map_manager, "map_entered"))
	self.connect("map_entered", Callable(main_map, "_on_adjacent_entered"))
	
# Called when the main map changed but the current map is still not the main map
func switch_main_map(old_main_map, new_main_map):
	self.disconnect("map_entered", Callable(old_main_map, "_on_adjacent_entered"))
	self.connect("map_entered", Callable(new_main_map, "_on_adjacent_entered"))

# Called when switched to main mode: the map is the main one and has the player in it.
# It has to be notified when the player enters an adjacent map.
func main_mode(map_manager, maps, old_main_map):
	self.disconnect("map_entered", Callable(old_main_map, "_on_adjacent_entered"))
	self.connect("map_entered", Callable(map_manager, "map_entered"))
	show_adjacent_maps(map_manager, maps)
	for map in maps:
		if maps[map] != self and maps[map] != old_main_map:
			maps[map].switch_main_map(old_main_map, self)
	emit_signal("map_loaded")
	
func clear_adjacent_maps():
	var keys = _adjacent_maps.keys()
	for map in keys:
		_adjacent_maps[map].queue_free()
		_adjacent_maps.erase(map)
		
func _ready():
	# Do not show adjacent maps if not in editor: MapManager will handle it.
	if not Engine.is_editor_hint():
		clear_adjacent_maps()
		zone = $MapZone

func _on_map_entered(body: Node):
	if body is PlayerObject:
		emit_signal("map_entered",self)

func _on_adjacent_entered(map):
	emit_signal("map_entered", map)
	
func save_events() -> Dictionary:
	var data = {}
	for child in get_children():
		if child.is_in_group("Persist") and child.has_method("save"):
			data[child.get_name()] = child.save()
		elif child.is_in_group("Persist"):
			printerr("Warning: Node in groupe Persist named \"" + child.get_name() + "\" in \"" + get_name() + "\" does not have save() method.")
	return data
	
func load_events(data: Dictionary) -> void:
	for child in get_children():
		if child.is_in_group("Persist") and child.has_method("load_save") and data.has(child.get_name()):
			child.load_save(data[child.get_name()])
