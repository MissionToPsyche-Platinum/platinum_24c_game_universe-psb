extends Node2D
class_name MapView

signal node_clicked(index: int)

@export var scenario_scene: PackedScene
@export var unknown_scene: PackedScene
@export var psyche_scene: PackedScene
@export var earth_scene: PackedScene
@export var asteroid_scene: PackedScene

var node_views := {}          # index -> Node2D
var line_views := []          # Line2D
var line_connections := []    # Vector2i (from, to)

var psyche_view: Node2D


# --------------------
# BUILD (static layout)
# --------------------

func build(layout: MapLayout):
	_clear()

	# Lines first (drawn under nodes)
	for c in layout.connections:
		_add_line(
			layout.node_positions[c.x],
			layout.node_positions[c.y]
		)
		line_connections.append(c)

	# Placeholder nodes (real scenes assigned in update)
	for i in layout.node_positions.size():
		var placeholder := Node2D.new()
		add_child(placeholder)
		placeholder.position = layout.node_positions[i]
		placeholder.set_meta("index", i)
		node_views[i] = placeholder


# --------------------
# UPDATE (from model)
# --------------------

func update_from_model(model: MapModel):
	_update_nodes(model)
	_update_psyche(model)
	_update_lines(model)
	

func _update_psyche(model: MapModel):
	if psyche_view == null:
		psyche_view = psyche_scene.instantiate()
		add_child(psyche_view)
		psyche_view.z_index = 100

	var pos := model.layout.node_positions[model.current_index]
	psyche_view.position = pos



func _update_nodes(model: MapModel):
	for i in node_views.keys():
		var scene: PackedScene = null

		# Earth
		if i == model.layout.start_index:
			scene = earth_scene

		# Asteroid
		elif i == model.layout.end_index:
			scene = asteroid_scene

		# Known scenario
		elif model.known_nodes.has(i):
			scene = scenario_scene

		# Unknown scenario
		else:
			scene = unknown_scene

		var node := _replace_node(i, scene)

		# Interaction only for known scenarios (not current node)
		if scene == scenario_scene:
			if !node.is_connected("interacted", Callable(self, "_on_node_interacted")):
				node.connect("interacted", Callable(self, "_on_node_interacted"))

		# Psyche visuals
		if scene == psyche_scene:
			psyche_view = node
			psyche_view.z_index = 100


func _update_lines(model: MapModel):
	for idx in range(line_views.size()):
		var line = line_views[idx]
		var pair = line_connections[idx]
		var a = pair.x
		var b = pair.y

		# White only if:
		# - Psyche is at one end
		# - The other end is known
		if (
			(a == model.current_index and model.known_nodes.has(b)) or
			(b == model.current_index and model.known_nodes.has(a))
		):
			line.default_color = Color.WHITE
		else:
			line.default_color = Color(0.5, 0.5, 0.5)


# --------------------
# HELPERS
# --------------------

func _replace_node(index: int, scene: PackedScene) -> Node2D:
	var old = node_views[index]

	# If already the same scene, keep it
	if old and old.scene_file_path == scene.resource_path:
		return old

	var pos = old.position
	old.queue_free()

	var inst := scene.instantiate()
	add_child(inst)
	inst.position = pos
	inst.set_meta("index", index)

	node_views[index] = inst
	return inst



func _add_line(a: Vector2, b: Vector2):
	var l := Line2D.new()
	add_child(l)
	l.add_point(a)
	l.add_point(b)
	l.width = 5
	l.default_color = Color(0.5, 0.5, 0.5)
	line_views.append(l)


func _on_node_interacted(node):
	node_clicked.emit(node.get_meta("index"))


func _clear():
	for c in get_children():
		c.queue_free()
	node_views.clear()
	line_views.clear()
	line_connections.clear()
	psyche_view = null
