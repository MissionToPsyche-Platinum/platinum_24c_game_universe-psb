extends Node2D
class_name MapView

signal node_clicked(index: int)

@export var scenario_scene: PackedScene
@export var unknown_scene: PackedScene
@export var psyche_scene: PackedScene
@export var earth_scene: PackedScene
@export var asteroid_scene: PackedScene

var node_views := {}
var line_views := []
var visited_nodes := {}
var line_connections := []

var psyche_view: Node2D
var psyche_last_index := -1
var deactivated := []


# -------------------------
# BUILD
# -------------------------
func build(layout: MapLayout):
	_clear()

	for c in layout.connections:
		_add_line(layout.node_positions[c.x], layout.node_positions[c.y])
		line_connections.append(c)

	for i in layout.node_positions.size():
		var placeholder = Node2D.new()
		add_child(placeholder)
		placeholder.position = layout.node_positions[i]
		placeholder.set_meta("index", i)
		node_views[i] = placeholder


# -------------------------
# UPDATE
# -------------------------
func update_from_model(model: MapModel):
	if model.has_won:
		# Win path returns before the deferred psyche sync below; still move Psyche
		# to the final index so callers (and tests) see a consistent position.
		_sync_psyche(model)
		GameManager.stats.store_attributes()
		get_tree().change_scene_to_file("res://Model/ScreenData/WinScreen.tscn")
		return

	var layout = model.layout
	var current_index = model.current_index

	for i in node_views.keys():
		var scene: PackedScene

		if i == layout.start_index:
			scene = earth_scene
		elif i == layout.end_index:
			scene = asteroid_scene
		elif model.is_node_active(i):
			scene = scenario_scene
		elif visited_nodes.has(i):
			scene = scenario_scene
		else:
			scene = unknown_scene

		var node: Node2D = node_views[i]
		if node == null:
			continue

		# -------------------------
		# SAFE SIGNAL CONNECTION
		# -------------------------
		if scene == scenario_scene:
			if node.has_signal("interacted"):
				if not node.is_connected("interacted", Callable(self, "_on_node_interacted")):
					var err = node.connect("interacted", Callable(self, "_on_node_interacted"))
					if err != OK:
						push_warning("Failed to connect signal for node " + str(i))

	# mark visited
	visited_nodes[current_index] = true

	psyche_last_index = current_index

	# -------------------------
	# FIX: DEFER PSYCHE UPDATE (IMPORTANT)
	# -------------------------
	call_deferred("_sync_psyche", model)

	# -------------------------
	# LINE UPDATE
	# -------------------------
	for idx in range(line_views.size()):
		var line = line_views[idx]
		var pair = line_connections[idx]
		var a = pair.x
		var b = pair.y

		if (a == current_index and model.is_node_active(b)) or \
		   (b == current_index and model.is_node_active(a)):
			line.default_color = Color.WHITE
		else:
			line.default_color = Color(0.5, 0.5, 0.5)


# -------------------------
# FIXED PSYCHE SYNC
# -------------------------
func _sync_psyche(model: MapModel) -> void:
	if psyche_view == null:
		psyche_view = psyche_scene.instantiate()
		add_child(psyche_view)
		psyche_view.z_index = 100

	var pos: Vector2 = model.layout.node_positions[model.current_index]
	psyche_view.position = pos


# -------------------------
# SAFE REPLACE (kept minimal, no instability)
# -------------------------
func _replace_node(index: int, scene: PackedScene) -> Node2D:
	var old = node_views.get(index)
	if old == null:
		return null

	var pos = old.position
	old.queue_free()

	var inst = scene.instantiate()
	add_child(inst)
	inst.position = pos
	inst.set_meta("index", index)
	node_views[index] = inst
	return inst


# -------------------------
# LINE HELPERS
# -------------------------
func _add_line(a: Vector2, b: Vector2):
	var l = Line2D.new()
	add_child(l)
	l.add_point(a)
	l.add_point(b)
	l.width = 5
	l.default_color = Color(0.5, 0.5, 0.5)
	line_views.append(l)


# -------------------------
# SIGNAL HANDLER
# -------------------------
func _on_node_interacted(node):
	if node == null:
		return
	node_clicked.emit(node.get_meta("index"))


# -------------------------
# CLEANUP (FIXED SIGNAL SAFETY)
# -------------------------
func _clear():
	for node in node_views.values():
		if node and node.is_connected("interacted", Callable(self, "_on_node_interacted")):
			node.disconnect("interacted", Callable(self, "_on_node_interacted"))

	for c in get_children():
		c.queue_free()

	node_views.clear()
	line_views.clear()
	line_connections.clear()
	visited_nodes.clear()
	psyche_view = null
