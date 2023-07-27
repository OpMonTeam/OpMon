@tool
extends ColorRect

class_name Submenu

# Returns the identifier of the option chosen. Returns -1 if no option chosen (submenu closed)
signal choice(curpos)

@export var choices: Array: set = set_choices
@export var cursor_texture: Texture2D: set = set_cursor_texture

var choices_nodes: Array
var cursor_positions: Array
var cursor_sizes: Array
var cursor := TextureRect.new()

var curpos: int

func set_choices(new_choices: Array):
	choices = new_choices
	# Clears old nodes
	for choice_node in choices_nodes:
		self.remove_child(choice_node)
	choices_nodes.clear()
	cursor_positions.clear()
	cursor_sizes.clear()
	# Keeps track of the current y position of the label to position them
	var y := 5
	# Keeps track of the largest label to expand the ColorRect background
	var max_x := 0
	for choice in choices:
		choices_nodes.append(Label.new())
		var node: Label = choices_nodes.back()
		node.set_text(choice)
		self.add_child(node)
		node.position = Vector2(25, y) # 25: Leaves place for the cursor
		cursor_positions.append(Vector2(5, y))
		cursor_sizes.append(Vector2(15, node.size.y))
		y += node.size.y + 10 # + 10: Leaves place for the next label
		if max_x < node.size.x:
			max_x = node.size.x
		
		
	self.size = Vector2(35 + max_x, y)
	self.pivot_offset = Vector2(0, self.size.y)

func set_cursor_texture(new_texture: Texture2D):
	cursor_texture = new_texture
	cursor.texture = cursor_texture

func _enter_tree():
	add_child(cursor)
	cursor.expand = true
	cursor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	set_choices(choices)
	set_cursor_texture(cursor_texture)
	if choices.size() > 0:
		cursor.position = cursor_positions[0]
		cursor.size = cursor_sizes[0]
	self.color = Color.WHITE_SMOKE

func _input(event):
	if not Engine.is_editor_hint() and visible:
		if event.is_action_pressed("ui_accept"):
			emit_signal("choice", curpos)
			curpos = 0
		elif event.is_action_pressed("menu"):
			emit_signal("choice", -1)
			curpos = 0
		elif event.is_action_pressed("ui_down") and curpos != (choices.size() - 1):
			curpos += 1
		elif event.is_action_pressed("ui_up") and curpos != 0:
			curpos -= 1
		cursor.position = cursor_positions[curpos]
		cursor.size = cursor_sizes[curpos]
