extends Node2D
class_name Map

const PsycheScene = preload("uid://cjy685rokwo4q")
const EarthScene = preload("uid://d27qiheuudmom")
const PsycheAsteroidScene = preload("uid://of3br6vte6xu")
const ScenarioScene = preload("uid://brf8psrjkpbsh")
const UnknownScenarioScene = preload("uid://bhmwabijgly1l")

# want to find a better way to do this, make more flexible
const TOTAL_NODES = 9
const NODE_COORDS := [
	Vector2(120, 540),
	Vector2(225, 315),
	Vector2(450, 510),
	Vector2(405, 150),
	Vector2(510, 315),
	Vector2(735, 540),
	Vector2(734, 210),
	Vector2(900, 375),
	Vector2(1005, 120),
]
const CONNECTIONS := [
	[0,1], [0,2], [1,3], [1,4],
	[2,4], [2,5], [3,6], [4,6],
	[4,7], [5,7], [6,8], [7,8]
]

var scenarios = []
var unknown_scenarios = []
var earth_node : Node2D
var asteroid_node : Node2D
var psyche_node : Node2D
var lines = []
var line_connections: Array = []
var psyche_anticipated_location : Vector2
var psyche_anticipated_index : int
var psyche_previous_index := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gen_lines()
	gen_scenarios()
	update_line_colors()
	#$Camera2D.position = Vector2(1920/2, 1080/2)
	#$Camera2D.zoom = Vector2(1152.0/1920.0, 648.0/1080.0)
	#var uniform_scale = min(1152.0/1920.0, 648.0/1080.0)
	#self.position = Vector2(1920/2, 1080/2)
	#self.scale = Vector2(uniform_scale, uniform_scale)
	#self.scale = Vector2(0.6, 0.6)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called whenever a scenario is successfully completed
# and the player returns to the map
func advance_position():
	psyche_previous_index = psyche_node.get_meta("index")
	psyche_node.position = psyche_anticipated_location
	psyche_node.set_meta("index", psyche_anticipated_index)
	
	#var new_index = get_node_index_from_position(psyche_anticipated_location)
	var new_index = psyche_anticipated_index
	if new_index == -1:
		return
		
	# Disable previously active scenario nodes
	for scenario in scenarios:
		if !scenario.is_disabled:
			scenario.disable()

	# Convert all unknown nodes to known adjacent to new location
	var neighbors = get_connected_nodes(new_index)
	for unknown in unknown_scenarios.duplicate():
		var idx = unknown.get_meta("index")
		if neighbors.has(idx):
			convert_unknown_to_scenario(unknown, idx)
			
	# Update line colors according to new location
	update_line_colors()
	
	# if psyche_anticipated_location == end node, you win
	var asteroid_neighbors = get_connected_nodes(TOTAL_NODES - 1)
	if asteroid_neighbors.has(new_index):
		get_tree().change_scene_to_file("res://Model/ScreenData/WinScreen.tscn")
		self.visible = false
	
	self.visible = true

# Recieves signal from scenario node when clicked on
# Then sets selected scenario and anticipated location
func _on_child_interacted(clicked_scenario):
	psyche_anticipated_location = clicked_scenario.position
	psyche_anticipated_index = clicked_scenario.get_meta("index")
	print("Anticipated location set")
	self.visible = false

# LOGIC #

# Called in advance_position to get node's index in NODE_COORDS
func get_node_index_from_position(pos: Vector2) -> int:
	for i in range(NODE_COORDS.size()):
		if NODE_COORDS[i] == pos:
			return i
	return -1

# Called in advance_position and update_line_colors to get indices
# of nodes connected to node at index
func get_connected_nodes(index: int) -> Array:
	var result := []
	for pair in CONNECTIONS:
		if pair[0] == index:
			result.append(pair[1])
		elif pair[1] == index:
			result.append(pair[0])
	return result

# Called in _ready and advance_position to update line colors
func update_line_colors():
	#var current_index = get_node_index_from_position(psyche_node.position)
	var current_index = psyche_node.get_meta("index")
	if current_index == -1:
		return

	for i in range(lines.size()):
		var line = lines[i]
		var pair = line_connections[i]
		var a = pair[0]
		var b = pair[1]

		# line is white onky if psyche is on this node and
		# the other end is a known scenario node
		if (a == current_index and is_known_scenario(b)) \
		or (b == current_index and is_known_scenario(a)):
			line.default_color = Color.WHITE
		else:
			line.default_color = Color(0.5, 0.5, 0.5)

# Called in advance_position to convert an unknown node to a known node
func convert_unknown_to_scenario(unknown_node: Node2D, idx: int):
	var pos = unknown_node.position

	unknown_scenarios.erase(unknown_node)
	unknown_node.queue_free()

	add_scenario(pos.x, pos.y, idx)

# Called in update_line_colors to validate if a scenario at index is known
func is_known_scenario(index: int) -> bool:
	for scenario in scenarios:
		if scenario.get_meta("index") == index and !scenario.is_disabled:
			return true
	return false

# GEN HELPERS #

# Called in _ready() to add lines between scenario nodes
func gen_lines():
	for pair in CONNECTIONS:
		add_line(NODE_COORDS[pair[0]], NODE_COORDS[pair[1]])
		line_connections.append(pair)

# Called in _ready() to populate map with scenarios
#    this probably sucks
func gen_scenarios():
	for i in range(TOTAL_NODES):
		if i == 0: # first node is earth + psyche
			add_earth(NODE_COORDS[i].x, NODE_COORDS[i].y)
			add_psyche(NODE_COORDS[i].x, NODE_COORDS[i].y, i)
			psyche_anticipated_location = psyche_node.position
			psyche_anticipated_index = 0
			# make psyche frontmost
			psyche_node.z_index = 100
		elif i == TOTAL_NODES-1: # last node is the asteroid
			add_asteroid(NODE_COORDS[i].x, NODE_COORDS[i].y)
		elif i == 1 or i == 2: # first two adj nodes are known
			add_scenario(NODE_COORDS[i].x, NODE_COORDS[i].y, i)
		else: # all else unknown
			add_unknown_scenario(NODE_COORDS[i].x, NODE_COORDS[i].y, i)
	
# ADD HELPERS #

# Call in gen_scenarios() to add Psyche spacecraft to map
func add_psyche(x: int, y: int, i := -1):
	var inst = PsycheScene.instantiate()
	add_child(inst)
	inst.position = Vector2(x, y)
	inst.set_meta("index", i)
	psyche_node = inst

# Call in gen_scenarios() to add battle scenarios to map
func add_scenario(x: int, y: int, i := -1):
	var inst = ScenarioScene.instantiate()
	add_child(inst)
	inst.position = Vector2(x, y)
	inst.set_meta("index", i)
	inst.connect("interacted", Callable(self, "_on_child_interacted"))
	scenarios.append(inst)

# Call in gen_scenarios() to add unknown (?) scenarios to map
func add_unknown_scenario(x: int, y: int, i := -1):
	var inst = UnknownScenarioScene.instantiate()
	add_child(inst)
	inst.position = Vector2(x, y)
	inst.set_meta("index", i)
	unknown_scenarios.append(inst)

# Call in gen_scenarios() to add Earth to map
func add_earth(x: int, y: int):
	var inst = EarthScene.instantiate()
	add_child(inst)
	inst.position = Vector2(x, y)
	earth_node = inst

# Call in gen_scenarios() to add Psyche Asteroid to map
func add_asteroid(x: int, y: int):
	var inst = PsycheAsteroidScene.instantiate()
	add_child(inst)
	inst.position = Vector2(x, y)
	asteroid_node = inst

func add_line(start: Vector2, end: Vector2) -> Line2D:
	var inst = Line2D.new()
	add_child(inst)
	inst.add_point(start)
	inst.add_point(end)
	inst.default_color = Color(0.5, 0.5, 0.5)
	inst.width = 5
	#inst.texture = LineTexture
	lines.append(inst)
	return inst
