extends Node2D
class_name MapView

signal node_clicked(index: int)

@export var scenario_scene: PackedScene
@export var unknown_scene: PackedScene
@export var psyche_scene: PackedScene
@export var earth_scene: PackedScene
@export var asteroid_scene: PackedScene

var node_views := {} 
var line_views := []      # Line2D
var visited_nodes := {}
var line_connections := [] # Vector2i
var psyche_view: Node2D

var psyche_last_index := -1
var deactivated := []

func build(layout: MapLayout):
	_clear()
	# Draw lines first
	for c in layout.connections:
		_add_line(layout.node_positions[c.x], layout.node_positions[c.y])
		line_connections.append(c)

	# Create placeholders for all nodes
	for i in layout.node_positions.size():
		var placeholder = Node2D.new()
		add_child(placeholder)
		placeholder.position = layout.node_positions[i]
		placeholder.set_meta("index", i)
		node_views[i] = placeholder

func update_from_model(model: MapModel):
	if model.has_won == true:
		get_tree().change_scene_to_file("res://Model/ScreenData/WinScreen.tscn")
	else:
		for i in node_views.keys():
			var scene: PackedScene = null

			if i == model.layout.start_index:
				scene = earth_scene
			elif i == model.layout.end_index:
				scene = asteroid_scene
			elif model.is_node_active(i):
				scene = scenario_scene
			elif visited_nodes.has(i):
				# If previously visited, keep scenario_scene (disabled) instead of unknown
				scene = scenario_scene
			else:
				scene = unknown_scene

			var node = _replace_node(i, scene)

			# Only active scenario nodes get interaction
			if scene == scenario_scene and not node.is_connected("interacted", Callable(self, "_on_node_interacted")):
				node.connect("interacted", Callable(self, "_on_node_interacted"))
			
			# Disable previously enabled nodes
			if psyche_last_index != -1:
				if get_proceeding_neighbors(psyche_last_index, model.layout).has(i):
						node = _replace_node(i, scenario_scene)
						if node.has_method("disable") and node != null:
							node.disable()
							deactivated.append(i)
		
		# end of for loop
		psyche_last_index = model.current_index
		
		# Mark the current node as visited
		visited_nodes[model.current_index] = true

		# Update Psyche
		if psyche_view == null:
			psyche_view = psyche_scene.instantiate()
			add_child(psyche_view)
			psyche_view.z_index = 100

		psyche_view.position = model.layout.node_positions[model.current_index]

		# Update lines
		for idx in range(line_views.size()):
			var line = line_views[idx]
			var pair = line_connections[idx]
			var a = pair.x
			var b = pair.y

			if (a == model.current_index and model.is_node_active(b)) or \
			   (b == model.current_index and model.is_node_active(a)):
				line.default_color = Color.WHITE
			else:
				line.default_color = Color(0.5, 0.5, 0.5)

# Helper functions:

func _replace_node(index: int, scene: PackedScene) -> Node2D:
	var old = node_views[index]
	#if old and old.scene_file_path == scene.resource_path:
	# Stops disabled nodes from being replaced w/ unknown
	if old and deactivated.has(index):
		return old
	
	# If old node is a disabled scenario, do NOT replace it
	#if old is Scenario and old.is_disabled:
		#return old

	var pos = old.position
	old.queue_free()

	#var inst = scene.instantiate()
	#add_child(inst)
	#inst.position = pos
	#inst.set_meta("index", index)
	#node_views[index] = inst
	#return inst
	var inst = scene.instantiate()
	add_child(inst)
	inst.position = pos
	inst.set_meta("index", index)

	# Assign fixed demo scenarios
	if inst.has_method("load_scenario_type"):
		match index:
			1: inst.scenario_path = "res://Model/ScenarioData/Scenarios/Sc_AlienFungus.tscn"
			2: inst.scenario_path = "res://Model/ScenarioData/Scenarios/BattleSceneTest1.tscn"
			3: inst.scenario_path = "res://Model/ScenarioData/Scenarios/MeteorMinigame.tscn"
			4: inst.scenario_path = "res://Model/ScenarioData/Scenarios/DestroyerMinigame.tscn"
			5: inst.scenario_path = "res://Model/ScenarioData/Scenarios/ShootingMinigame.tscn"
		inst.load_scenario_type()
		inst.set_sprite()

	node_views[index] = inst
	return inst

func _add_line(a: Vector2, b: Vector2):
	var l = Line2D.new()
	add_child(l)
	l.add_point(a)
	l.add_point(b)
	l.width = 5
	l.default_color = Color(0.5,0.5,0.5)
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

func get_proceeding_neighbors(index: int, layout: MapLayout) -> Array[int]:
	var neighbors: Array[int] = []
	for c in layout.connections:
		if c.x == index:
			neighbors.append(c.y)
	return neighbors
